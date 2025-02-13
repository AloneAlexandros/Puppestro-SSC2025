import SwiftUI
import Foundation

struct ContentView: View {
    @StateObject private var audioManager = AudioManager(fileName: "default", fileExtension: ".m4a", offset: -534)
    @State var thumbPoint: CGPoint = .zero
    @State var fingerAvaragePoint: CGPoint = .zero
    @State var wristPoint: CGPoint = .zero
    @State var calibrationPoint: CGPoint = .zero
    var minimumDistance: Float = 0
    var maximumDisrance: Float = 6.0
    @State var noteName: String = ""
    var body: some View {
        let distance = CGTools.distanceSquared(from: thumbPoint, to: fingerAvaragePoint)
        let calibrationDistance = CGTools.distanceSquared(from: wristPoint, to: calibrationPoint)
        let calibratedDistance = distance/calibrationDistance
        HandRecognitionSimpleOverlay(thumbPoint: $thumbPoint, fingerAvaragePoint: $fingerAvaragePoint, wristPoint: $wristPoint, calibrationPoint: $calibrationPoint)
            .onChange(of: thumbPoint) {
                var pitch: Float
                (noteName, pitch) = RangeToMusic.returnCorrectNote(allNotes: false, minimumValue: minimumDistance, maximumValue: maximumDisrance, currentValue: Float(calibratedDistance), pitchOffset: 0, octaves: 1, startingOctave: 1)
                audioManager.setPitch(pitch)
            }
        Text("\(calibratedDistance)")
        Text(noteName)
        Text("\(audioManager.pitchControl.pitch)")
    }
}

#Preview {
    ContentView()
}
