import SwiftUI
import AVFoundation
import Vision

struct ScannerView: UIViewControllerRepresentable {
    @Binding var fingerAvaragePoint: CGPoint
    @Binding var wristPoint: CGPoint
    @Binding var thumbPoint: CGPoint
    @Binding var calibrationPoint: CGPoint
    @Binding var overlayPoints: [CGPoint]
    @Binding var eyePoint: CGPoint
    
    let captureSession = AVCaptureSession()
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput) else {
            NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { _ in
                self.captureSession.stopRunning()
            }
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
        
        if let connection = previewLayer.connection {
            connection.videoOrientation = UIDevice.current.orientation.videoOrientation // Set initial video orientation
        }
        
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { _ in
            DispatchQueue.main.async {
                previewLayer.frame = viewController.view.bounds
                if let connection = previewLayer.connection {
                    connection.videoOrientation = UIDevice.current.orientation.videoOrientation
                }
            }
        }
        
        Task {
            DispatchQueue.global(qos: .userInitiated).async {
                captureSession.startRunning()
            }
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
                    let pipJoints: [VNHumanHandPoseObservation.JointName] = [
                        .indexPIP, .middlePIP, .ringPIP, .littlePIP
                    ]
                    let mcpJoints: [VNHumanHandPoseObservation.JointName] = [
                        .indexMCP, .middleMCP, .ringMCP, .littleMCP
                    ]
                    let dipJoints: [VNHumanHandPoseObservation.JointName] = [
                        .indexDIP, .middleDIP, .ringDIP, .littleDIP
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
                    
                    var avaragePIP: CGPoint = .zero
                    jointsChecked = []
                    for joint in pipJoints {
                        if let recognizedPoint = try? observation.recognizedPoint(joint), recognizedPoint.confidence > 0.8 {
                            jointsChecked.append(recognizedPoint.location)
                        }
                    }
                    if jointsChecked.count > 0 {
                        avaragePIP = CGTools.avarage(jointsChecked)
                    }
                    
                    var avarageMCP: CGPoint = .zero
                    jointsChecked = []
                    for joint in mcpJoints {
                        if let recognizedPoint = try? observation.recognizedPoint(joint), recognizedPoint.confidence > 0.8 {
                            jointsChecked.append(recognizedPoint.location)
                        }
                    }
                    if jointsChecked.count > 0 {
                        avarageMCP = CGTools.avarage(jointsChecked)
                    }
                    
                    var avarageDIP: CGPoint = .zero
                    jointsChecked = []
                    for joint in dipJoints {
                        if let recognizedPoint = try? observation.recognizedPoint(joint), recognizedPoint.confidence > 0.8 {
                            jointsChecked.append(recognizedPoint.location)
                        }
                    }
                    if jointsChecked.count > 0 {
                        avarageDIP = CGTools.avarage(jointsChecked)
                    }
                    
                    jointsChecked = []
                    for joint in fingerJoints {
                        if let recognizedPoint = try? observation.recognizedPoint(joint), recognizedPoint.confidence > 0.8 {
                            jointsChecked.append(recognizedPoint.location)
                        }
                    }
                    if jointsChecked.count > 0 {
                        avaragePoint = CGTools.avarage(jointsChecked)
                    }
                    DispatchQueue.main.async {
                        var overlayPoints : [CGPoint] = []
                        self.parent.fingerAvaragePoint = self.convertVisionPoint(avaragePoint)
                        if let thumb = try? observation.recognizedPoint(.thumbTip), thumb.confidence > 0.8 {
                            self.parent.thumbPoint = self.convertVisionPoint(thumb.location)
                            overlayPoints.append(self.convertVisionPoint(thumb.location))
                        }
                        if let thumb = try? observation.recognizedPoint(.thumbIP), thumb.confidence > 0.8 {
                            overlayPoints.append(self.convertVisionPoint(thumb.location))
                        }
                        if let thumb = try? observation.recognizedPoint(.thumbIP), thumb.confidence > 0.8 {
                            overlayPoints.append(self.convertVisionPoint(thumb.location))
                        }
                        if let thumb = try? observation.recognizedPoint(.thumbCMC), thumb.confidence > 0.8 {
                            overlayPoints.append(self.convertVisionPoint(thumb.location))
                        }
                        if let wrist = try? observation.recognizedPoint(.wrist), wrist.confidence > 0.8 {
                            self.parent.wristPoint = self.convertVisionPoint(wrist.location)
                            overlayPoints.append(self.convertVisionPoint(wrist.location))
                        }
                        overlayPoints.append(self.convertVisionPoint(avarageMCP))
                        overlayPoints.append(self.convertVisionPoint(avaragePIP))
                        overlayPoints.append(self.convertVisionPoint(avarageDIP))
                        self.parent.eyePoint = self.convertVisionPoint(avarageDIP)
                        overlayPoints.append(self.convertVisionPoint(avaragePoint))
                        overlayPoints.append(CGTools.avarage([self.parent.thumbPoint, self.parent.wristPoint,self.parent.fingerAvaragePoint]))
                        self.parent.overlayPoints = overlayPoints
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
    @State private var overlayPoints: [CGPoint] = []
    @State private var eyePoint: CGPoint = .zero
    @Binding var scale: CGFloat
    @Binding var color: Color
    @Binding var showOverlay: Bool
    @Binding var eyeScale: CGFloat
    @Binding var eyeColor: Color
    
    var body: some View {
        ZStack {
            ScannerView(fingerAvaragePoint: $fingerAvaragePoint, wristPoint: $wristPoint, thumbPoint: $thumbPoint, calibrationPoint: $calibrationPoint, overlayPoints: $overlayPoints, eyePoint: $eyePoint)
            if !showOverlay && thumbPoint != .zero{
                Circle().fill(.green).frame(width: 20).position(x: thumbPoint.x, y: thumbPoint.y)
                Circle().fill(.green).frame(width: 20).position(x: fingerAvaragePoint.x, y: fingerAvaragePoint.y)
            }else if thumbPoint != .zero{
                HandPolygon(points: overlayPoints, scale: scale)
                                .foregroundStyle(color)
                Circle().fill(.white).frame(width: 100*eyeScale).position(x: eyePoint.x, y: eyePoint.y)
                    .offset(x:50*eyeScale, y: -50*eyeScale)
                Circle().fill(eyeColor).frame(width: 30*eyeScale).position(x: eyePoint.x, y: eyePoint.y)
                    .offset(x:50*eyeScale, y: -50*eyeScale)
                Circle().fill(.white).frame(width: 100*eyeScale).position(x: eyePoint.x, y: eyePoint.y)
                Circle().fill(eyeColor).frame(width: 30*eyeScale).position(x: eyePoint.x, y: eyePoint.y)
            }
        }
    }
}

struct HandRecognitionTest: View {
    @State private var thumbPoint: CGPoint = .zero
    @State private var fingerAvaragePoint: CGPoint = .zero
    @State private var wristPoint: CGPoint = .zero
    @State private var calibrationPoint: CGPoint = .zero
    @State private var overlayPoints: [CGPoint] = []
    @State private var eyePoint: CGPoint = .zero
    
    var body: some View {
        ScannerView(fingerAvaragePoint: $fingerAvaragePoint, wristPoint: $wristPoint, thumbPoint: $thumbPoint, calibrationPoint: $calibrationPoint, overlayPoints: $overlayPoints, eyePoint: $eyePoint)
    }
}

#Preview {
    HandRecognitionTest()
}
