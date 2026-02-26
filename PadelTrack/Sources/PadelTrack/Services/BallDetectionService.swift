#if canImport(SwiftUI)
import Foundation
import AVFoundation
import Vision
import CoreGraphics
import PadelTrackCore

/// Detects and classifies whether a padel ball lands in or out of court boundaries
/// using the device camera and the Vision framework.
///
/// Usage:
/// 1. Call `configure(session:)` with an `AVCaptureSession` to attach the video output.
/// 2. Subscribe to `onDetection` to receive per-frame ball detection results.
public final class BallDetectionService: NSObject {

    // MARK: - Types

    /// Result of a single frame's ball detection.
    public struct DetectionResult {
        /// Normalized ball centre in the camera frame (Vision coordinates: bottom-left origin).
        public let ballCenter: CGPoint
        /// Confidence score of the object detection (0–1).
        public let confidence: Float
        /// Whether the ball is within the detected court boundaries.
        public let isIn: Bool
        /// Estimated ball speed in km/h based on displacement between frames (nil when unavailable).
        public let speedKmH: Double?
    }

    // MARK: - Public properties

    /// Called on the main queue whenever a detection result is available.
    public var onDetection: ((DetectionResult) -> Void)?

    // MARK: - Private state

    private let videoDataQueue = DispatchQueue(label: "com.padeltrack.balldetection", qos: .userInteractive)
    private var requests: [VNRequest] = []
    /// Bounding boxes of the detected court lines (updated periodically).
    private var courtBoundingBox: CGRect = CGRect(x: 0.1, y: 0.1, width: 0.8, height: 0.8)
    /// Previous ball position used to estimate speed.
    private var previousBallCenter: CGPoint?
    private var previousTimestamp: Double?

    // MARK: - Setup

    /// Attaches a pixel-buffer output to the given `AVCaptureSession`.
    public func configure(session: AVCaptureSession) {
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: videoDataQueue)
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        setupVisionRequests()
    }

    // MARK: - Vision requests

    private func setupVisionRequests() {
        // Use VNDetectRectanglesRequest to identify the court outline.
        let courtRequest = VNDetectRectanglesRequest { [weak self] request, _ in
            self?.handleCourtDetection(request)
        }
        courtRequest.minimumAspectRatio = 0.3
        courtRequest.maximumAspectRatio = 0.6
        courtRequest.minimumSize = 0.3
        courtRequest.maximumObservations = 1

        // Use a generic object tracking request (rectangle) to track the ball.
        // In production this should be replaced with a CoreML model trained on padel balls.
        let ballRequest = VNDetectRectanglesRequest { [weak self] request, _ in
            self?.handleBallDetection(request)
        }
        ballRequest.minimumAspectRatio = 0.8
        ballRequest.maximumAspectRatio = 1.0
        ballRequest.minimumSize = 0.01
        ballRequest.maximumSize = 0.08
        ballRequest.maximumObservations = 1

        requests = [courtRequest, ballRequest]
    }

    // MARK: - Detection handlers

    private func handleCourtDetection(_ request: VNRequest) {
        guard let results = request.results as? [VNRectangleObservation],
              let rect = results.first else { return }
        courtBoundingBox = rect.boundingBox
    }

    private func handleBallDetection(_ request: VNRequest) {
        // No-op: handled in the combined pipeline below via `handleBallObservation(_:timestamp:)`.
    }

    /// Processes a detected ball bounding box alongside the current frame timestamp.
    private func handleBallObservation(_ observation: VNRectangleObservation, timestamp: Double) {
        let center = CGPoint(
            x: observation.boundingBox.midX,
            y: observation.boundingBox.midY
        )
        let isIn = courtBoundingBox.contains(center)
        let speed = estimateSpeed(newCenter: center, timestamp: timestamp)
        let result = DetectionResult(
            ballCenter: center,
            confidence: observation.confidence,
            isIn: isIn,
            speedKmH: speed
        )
        DispatchQueue.main.async { [weak self] in
            self?.onDetection?(result)
        }
        previousBallCenter = center
        previousTimestamp = timestamp
    }

    // MARK: - Speed estimation

    /// Estimates speed in km/h from consecutive ball positions.
    ///
    /// Assumes the court is approximately 10 m wide when fully visible.
    private func estimateSpeed(newCenter: CGPoint, timestamp: Double) -> Double? {
        guard let prev = previousBallCenter, let prevTime = previousTimestamp else { return nil }
        let dt = timestamp - prevTime
        guard dt > 0 else { return nil }
        let dx = newCenter.x - prev.x
        let dy = newCenter.y - prev.y
        let pixelDistance = sqrt(dx * dx + dy * dy)
        // Rough conversion: full frame width ≈ 10 m court width.
        let metersPerUnit = 10.0
        let distanceMeters = Double(pixelDistance) * metersPerUnit
        let speedMs = distanceMeters / dt
        return speedMs * 3.6
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension BallDetectionService: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let timestamp = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform(requests)
            // Retrieve ball observations from the second request (index 1).
            if let ballReq = requests.last as? VNDetectRectanglesRequest,
               let ballObs = ballReq.results?.first as? VNRectangleObservation {
                handleBallObservation(ballObs, timestamp: timestamp)
            }
        } catch {
            // Detection errors are non-fatal; skip this frame.
        }
    }
}
#endif
