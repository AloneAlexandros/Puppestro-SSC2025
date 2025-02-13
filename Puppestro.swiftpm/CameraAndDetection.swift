import SwiftUI
import AVFoundation
import Vision


//Implementing the view responsible for detecting the hand pose
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
        
        Task {
            captureSession.startRunning()
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // 3. Implementing the Coordinator class
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
                        // Loop through all recognized points for each finger, including wrist
                        let fingerJoints: [VNHumanHandPoseObservation.JointName] = [
                            .indexTip, // Index finger joints
                            .middleTip, // Middle finger joints
                            .ringTip,     // Ring finger joints
                            .littleTip // Little finger joints
                        ]
                        let thumbJoint: [VNHumanHandPoseObservation.JointName] = [.thumbTip]
                        let wristJoint: [VNHumanHandPoseObservation.JointName] = [.wrist]
                        let calibrationJoint: [VNHumanHandPoseObservation.JointName] = [.thumbMP]
                        var avaragePoint: CGPoint = CGPoint(x: 0,y: 0)
                        var jointsChecked = 0
                        for joint in fingerJoints {
                            if let recognizedPoint = try? observation.recognizedPoint(joint), recognizedPoint.confidence > 0.8 {
                                avaragePoint = CGPoint(x: recognizedPoint.location.x + avaragePoint.x, y: recognizedPoint.location.y + avaragePoint.y)
                                jointsChecked += 1
                            }
                        }
                        if jointsChecked != 0
                        {
                            avaragePoint = CGPoint(x: avaragePoint.x/CGFloat(jointsChecked), y: avaragePoint.y/CGFloat(jointsChecked))
                        }
                        for joint in thumbJoint {
                            if let recognizedPoint = try? observation.recognizedPoint(joint), recognizedPoint.confidence > 0.8 {
                                self.parent.thumbPoint = self.convertVisionPoint(recognizedPoint.location)
                            }
                        }
                        for joint in wristJoint {
                            if let recognizedPoint = try? observation.recognizedPoint(joint), recognizedPoint.confidence > 0.8 {
                                self.parent.wristPoint = self.convertVisionPoint(recognizedPoint.location)
                            }
                        }
                        for joint in calibrationJoint {
                            if let recognizedPoint = try? observation.recognizedPoint(joint), recognizedPoint.confidence > 0.8 {
                                self.parent.calibrationPoint = self.convertVisionPoint(recognizedPoint.location)
                            }
                        }
                        // Convert normalized Vision points to screen coordinates and update coordinates
                        self.parent.fingerAvaragePoint = self.convertVisionPoint(avaragePoint)
                    }
                }

                request.maximumHandCount = 1

                let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .leftMirrored, options: [:])
                do {
                    try handler.perform([request])
                } catch {
                    print("Hand pose detection failed: \(error)")
                }
            }

            // Convert Vision's normalized coordinates to screen coordinates
            func convertVisionPoint(_ point: CGPoint) -> CGPoint {
                let screenSize = UIScreen.main.bounds.size
                let y = point.x * screenSize.height
                let x = point.y * screenSize.width
                return CGPoint(x: x, y: y)
            }
        }
    

}

struct HandRecognitionTest: View {
    
    @State private var thumbPoint: CGPoint = .zero
    @State private var fingerAvaragePoint: CGPoint = .zero
    @State private var wristPoint: CGPoint = .zero
    @State private var calibrationPoint: CGPoint = .zero
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScannerView(fingerAvaragePoint: $fingerAvaragePoint, wristPoint: $wristPoint, thumbPoint: $thumbPoint, calibrationPoint: $calibrationPoint)
            // Draw circles for the hand points, including the wrist
            Circle()
                .fill(.green)
                .frame(width: 20)
                .position(x: thumbPoint.x, y: thumbPoint.y)
            Circle()
                .fill(.green)
                .frame(width: 20)
                .position(x: fingerAvaragePoint.x, y: fingerAvaragePoint.y)
            Circle()
                .fill(.red)
                .frame(width: 15)
                .position(x: wristPoint.x, y: wristPoint.y)
            Circle()
                .fill(.red)
                .frame(width: 15)
                .position(x: calibrationPoint.x, y: calibrationPoint.y)
        }
    }
}

struct HandRecognitionSimpleOverlay: View {
    
    @Binding var thumbPoint: CGPoint
    @Binding var fingerAvaragePoint: CGPoint
    @Binding var wristPoint: CGPoint
    @Binding var calibrationPoint: CGPoint
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScannerView(fingerAvaragePoint: $fingerAvaragePoint, wristPoint: $wristPoint, thumbPoint: $thumbPoint, calibrationPoint: $calibrationPoint)
            // Draw circles for the hand points, including the wrist
            Circle()
                .fill(.green)
                .frame(width: 20)
                .position(x: thumbPoint.x, y: thumbPoint.y)
            Circle()
                .fill(.green)
                .frame(width: 20)
                .position(x: fingerAvaragePoint.x, y: fingerAvaragePoint.y)
        }
    }
}
#Preview {
    HandRecognitionTest()
}
