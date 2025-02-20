import SwiftUI
import Foundation

struct CalibrationView: View {
    @EnvironmentObject var database : Database
    @StateObject private var audioManager = AudioManager(fileName: "clarinet", fileExtension: ".m4a", offset: 0)
    @State var thumbPoint: CGPoint = .zero
    @State var fingerAvaragePoint: CGPoint = .zero
    @State var wristPoint: CGPoint = .zero
    @State var calibrationPoint: CGPoint = .zero
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
                    (noteName, pitch) = RangeToMusic.returnCorrectNote(allNotes: false, minimumValue: database.minimumDistance, maximumValue: database.maximumDistance, currentValue: Float(calibratedDistance), pitchOffset: 0, octaves: 1, startingOctave: 0)
                    audioManager.setPitch(pitch)
                    if noteName == "none"{
                        audioManager.stopPlayback()
                    }
                    else{
                        audioManager.startPlayback()
                    }
                    //edit the notePoint to change the position of the note text
                    notePoint = CGTools.avarage([thumbPoint, fingerAvaragePoint])
                    
                    //set new minimums and maximums
                    if Float(calibratedDistance) < database.minimumDistance{
                        database.minimumDistance = Float(calibratedDistance)
                    }
                    if Float(calibratedDistance) > database.maximumDistance{
                        database.maximumDistance = Float(calibratedDistance)
                    }
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
        .onAppear{
            database.minimumDistance = 1000000
            database.maximumDistance = -1000000
        }
    }
}

#Preview {
    CalibrationView()
}
