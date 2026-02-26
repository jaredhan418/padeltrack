#if canImport(SwiftUI)
import SwiftUI
import AVFoundation
import PadelTrackCore

/// Electronic line judge view – uses the device camera and the Vision framework
/// to detect whether the ball lands in or out, similar to Swing Vision.
public struct LineJudgeView: View {

    @StateObject private var viewModel = LineJudgeViewModel()

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                // Camera preview fills the screen.
                if viewModel.isCameraReady {
                    CameraPreviewView(session: viewModel.captureSession)
                        .ignoresSafeArea()
                } else {
                    Color.black.ignoresSafeArea()
                    if let error = viewModel.permissionError {
                        Text(error)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else {
                        ProgressView("Starting camera…")
                            .tint(.white)
                    }
                }

                // Overlay
                VStack {
                    Spacer()
                    detectionBanner
                        .padding(.bottom, 32)
                }
            }
            .navigationTitle("Line Judge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.toggleDetection()
                    } label: {
                        Label(
                            viewModel.isDetecting ? "Stop" : "Start",
                            systemImage: viewModel.isDetecting ? "stop.circle.fill" : "play.circle.fill"
                        )
                        .foregroundStyle(viewModel.isDetecting ? .red : .green)
                    }
                }
            }
            .onAppear { viewModel.requestCameraAccess() }
            .onDisappear { viewModel.stopSession() }
        }
    }

    // MARK: - Sub-views

    private var detectionBanner: some View {
        Group {
            if let result = viewModel.latestResult {
                VStack(spacing: 4) {
                    Text(result.isIn ? "IN" : "OUT")
                        .font(.system(size: 48, weight: .black))
                        .foregroundStyle(result.isIn ? .green : .red)
                    HStack(spacing: 16) {
                        Label(
                            String(format: "%.0f%%", result.confidence * 100),
                            systemImage: "waveform"
                        )
                        if let speed = result.speedKmH {
                            Label(String(format: "%.0f km/h", speed), systemImage: "speedometer")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.white)
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }
}

// MARK: - ViewModel

/// Manages camera session and ball detection lifecycle.
@MainActor
final class LineJudgeViewModel: ObservableObject {

    @Published var isCameraReady = false
    @Published var isDetecting = false
    @Published var latestResult: BallDetectionService.DetectionResult?
    @Published var permissionError: String?

    let captureSession = AVCaptureSession()
    private let detectionService = BallDetectionService()

    // MARK: - Camera setup

    func requestCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                Task { @MainActor in
                    if granted { self?.setupCamera() }
                    else { self?.permissionError = "Camera access is required for line judging." }
                }
            }
        default:
            permissionError = "Camera access denied. Enable it in Settings."
        }
    }

    private func setupCamera() {
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              captureSession.canAddInput(input) else {
            permissionError = "Failed to access camera hardware."
            return
        }
        captureSession.addInput(input)
        captureSession.sessionPreset = .hd1280x720
        detectionService.configure(session: captureSession)
        detectionService.onDetection = { [weak self] result in
            self?.latestResult = result
        }
        isCameraReady = true
    }

    // MARK: - Session control

    func toggleDetection() {
        if isDetecting {
            captureSession.stopRunning()
        } else {
            Task.detached(priority: .userInitiated) { [weak self] in
                self?.captureSession.startRunning()
            }
        }
        isDetecting.toggle()
    }

    func stopSession() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
        isDetecting = false
    }
}
#endif
