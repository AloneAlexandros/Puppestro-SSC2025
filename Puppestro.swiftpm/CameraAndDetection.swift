import SwiftUI
import AVFoundation
import Vision

struct ScannerView: UIViewControllerRepresentable {
    @Binding var fingerAvaragePoint: CGPoint
    @Binding var wristPoint: CGPoint
    @Binding var thumbPoint: CGPoint
    @Binding var calibrationPoint: CGPoint
    
    let captureSession = AVCaptureSession()
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput) else {
            return viewController
        }
        
        captureSession.addInput(videoInput)
        
        let videoOutput = AVCaptureVideoDataOutput()
        if captureSession.canAddOutput(videoOutput) {
            videoOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))
            captureSession.addOutput(videoOutput)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewController.view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { _ in
            DispatchQueue.main.async {
                previewLayer.frame = viewController.view.bounds
                if let connection = previewLayer.connection {
                    connection.videoOrientation = UIDevice.current.orientation.videoOrientation
                }
            }
        }
        
        Task {
            captureSession.startRunning()
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: ScannerView

        init(_ parent: ScannerView) {
            self.parent = parent
        }

        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                return
            }
            self.detectHandPose(in: pixelBuffer)
        }

        func detectHandPose(in pixelBuffer: CVPixelBuffer) {
            let orientation: CGImagePropertyOrientation
            switch UIDevice.current.orientation {
            case .portrait:
                orientation = .leftMirrored
            case .landscapeLeft:
                orientation = .downMirrored
            case .landscapeRight:
                orientation = .upMirrored
            case .portraitUpsideDown:
                orientation = .rightMirrored
            default:
                orientation = .upMirrored
            }

            let request = VNDetectHumanHandPoseRequest { (request, error) in
                guard let observations = request.results as? [VNHumanHandPoseObservation], !observations.isEmpty else {
                    DispatchQueue.main.async {
                        self.parent.fingerAvaragePoint = .zero
                        self.parent.thumbPoint = .zero
                        self.parent.wristPoint = .zero
                    }
                    return
                }
                
                if let observation = observations.first {
                    let fingerJoints: [VNHumanHandPoseObservation.JointName] = [
                        .indexTip, .middleTip, .ringTip, .littleTip
                    ]
                    
                    var avaragePoint: CGPoint = .zero
                    var jointsChecked: [CGPoint] = []
                    for joint in fingerJoints {
                        if let recognizedPoint = try? observation.recognizedPoint(joint), recognizedPoint.confidence > 0.8 {
                            jointsChecked.append(recognizedPoint.location)
                        }
                    }
                    if jointsChecked.count > 0 {
                        avaragePoint = CGTools.avarage(jointsChecked)
                    }
                    
                    DispatchQueue.main.async {
                        self.parent.fingerAvaragePoint = self.convertVisionPoint(avaragePoint)
                        if let thumb = try? observation.recognizedPoint(.thumbTip), thumb.confidence > 0.8 {
                            self.parent.thumbPoint = self.convertVisionPoint(thumb.location)
                        }
                        if let wrist = try? observation.recognizedPoint(.wrist), wrist.confidence > 0.8 {
                            self.parent.wristPoint = self.convertVisionPoint(wrist.location)
                        }
                        if let calibration = try? observation.recognizedPoint(.indexMCP), calibration.confidence > 0.8 {
                            self.parent.calibrationPoint = self.convertVisionPoint(calibration.location)
                        }
                    }
                }
            }
            request.maximumHandCount = 1
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
            try? handler.perform([request])
        }
        
        func convertVisionPoint(_ point: CGPoint) -> CGPoint {
            let screenSize = UIScreen.main.bounds.size
            let x = point.x * screenSize.width
            let y = (1 - point.y) * screenSize.height
            return CGPoint(x: x, y: y)
        }
    }
}

extension UIDeviceOrientation {
    var videoOrientation: AVCaptureVideoOrientation {
        switch self {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeRight // Mirrored for landscape left
        case .landscapeRight: return .landscapeLeft // Mirrored for landscape right
        default: return .portrait
        }
    }
}

extension AVCaptureVideoPreviewLayer {
    func applyMirroring(for orientation: UIDeviceOrientation) {
        switch orientation {
        case .portrait:
            self.setAffineTransform(CGAffineTransform(rotationAngle: .pi)) // Rotate 180 degrees for portrait
        case .portraitUpsideDown:
            self.setAffineTransform(CGAffineTransform(rotationAngle: .pi)) // Rotate 180 degrees for upside down portrait
        case .landscapeLeft:
            self.setAffineTransform(CGAffineTransform(rotationAngle: -.pi / 2)) // Rotate 90 degrees for landscape
        case .landscapeRight:
            self.setAffineTransform(CGAffineTransform(rotationAngle: .pi / 2)) // Rotate -90 degrees for landscape
        default:
            self.setAffineTransform(.identity) // No transformation for unknown orientations
        }
    }
}


struct HandRecognitionSimpleOverlay: View {
    @Binding var thumbPoint: CGPoint
    @Binding var fingerAvaragePoint: CGPoint
    @Binding var wristPoint: CGPoint
    @Binding var calibrationPoint: CGPoint
    
    var body: some View {
        ZStack {
            ScannerView(fingerAvaragePoint: $fingerAvaragePoint, wristPoint: $wristPoint, thumbPoint: $thumbPoint, calibrationPoint: $calibrationPoint)
            Circle().fill(.green).frame(width: 20).position(x: thumbPoint.x, y: thumbPoint.y)
            Circle().fill(.green).frame(width: 20).position(x: fingerAvaragePoint.x, y: fingerAvaragePoint.y)
        }
    }
}

struct HandRecognitionTest: View {
    @State private var thumbPoint: CGPoint = .zero
    @State private var fingerAvaragePoint: CGPoint = .zero
    @State private var wristPoint: CGPoint = .zero
    @State private var calibrationPoint: CGPoint = .zero
    
    var body: some View {
        HandRecognitionSimpleOverlay(thumbPoint: $thumbPoint, fingerAvaragePoint: $fingerAvaragePoint, wristPoint: $wristPoint, calibrationPoint: $calibrationPoint)
    }
}

#Preview {
    HandRecognitionTest()
}
