#if canImport(SwiftUI)
import SwiftUI
import AVFoundation

/// Shows a live camera preview for the electronic line judge.
///
/// Wraps `AVCaptureVideoPreviewLayer` inside a `UIViewRepresentable`.
public struct CameraPreviewView: UIViewRepresentable {

    let session: AVCaptureSession

    public init(session: AVCaptureSession) {
        self.session = session
    }

    public func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    public func updateUIView(_ uiView: PreviewUIView, context: Context) {}

    // MARK: - Inner UIView

    public final class PreviewUIView: UIView {
        public override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        public var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            // swiftlint:disable:next force_cast
            layer as! AVCaptureVideoPreviewLayer
        }
    }
}
#endif
