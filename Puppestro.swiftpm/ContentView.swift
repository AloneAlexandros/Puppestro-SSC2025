import SwiftUI
import Foundation

struct ContentView: View {
    @StateObject private var audioManager = AudioManager(fileName: "clarinet", fileExtension: ".m4a", offset: 0)
    @State var thumbPoint: CGPoint = .zero
    @State var fingerAvaragePoint: CGPoint = .zero
    @State var wristPoint: CGPoint = .zero
    @State var calibrationPoint: CGPoint = .zero
    var minimumDistance: Float = 0
    var maximumDisrance: Float = 3.0
    @State var noteName: String = "none"
    @State var notePoint: CGPoint = .zero
    var body: some View {
        let distance = CGTools.distanceSquared(from: thumbPoint, to: fingerAvaragePoint)
        let calibrationDistance = CGTools.distanceSquared(from: wristPoint, to: calibrationPoint)
        let calibratedDistance = distance/calibrationDistance
        ZStack{
            HandRecognitionSimpleOverlay(thumbPoint: $thumbPoint, fingerAvaragePoint: $fingerAvaragePoint, wristPoint: $wristPoint, calibrationPoint: $calibrationPoint)
                .onChange(of: thumbPoint) {
                    var pitch: Float
                    (noteName, pitch) = RangeToMusic.returnCorrectNote(allNotes: false, minimumValue: minimumDistance, maximumValue: maximumDisrance, currentValue: Float(calibratedDistance), pitchOffset: 0, octaves: 1, startingOctave: 0)
                    audioManager.setPitch(pitch)
                    if noteName == "none"{
                        audioManager.stopPlayback()
                    }
                    else{
                        audioManager.startPlayback()
                    }
                    //edit the notePoint to change the position of the note text
                    notePoint = CGTools.avarage([thumbPoint, fingerAvaragePoint])
                }
            Text(noteName)
                .position(x: notePoint.x, y: notePoint.y)
                .font(.largeTitle)
            VStack{
                Spacer()
                Text("\(calibratedDistance)")
                Text("\(audioManager.pitchControl.pitch)")
            }
            
        }
    }
}

#Preview {
    ContentView()
}
