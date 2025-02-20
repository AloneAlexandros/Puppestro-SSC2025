import SwiftUI
import Foundation

struct ContentView: View {
    @EnvironmentObject var database : Database
    @StateObject private var audioManager = AudioManager(fileName: "clarinet", fileExtension: ".m4a", offset: 0)
    @State var thumbPoint: CGPoint = .zero
    @State var fingerAvaragePoint: CGPoint = .zero
    @State var wristPoint: CGPoint = .zero
    @State var calibrationPoint: CGPoint = .zero
    @State var noteName: String = "none"
    @State var notePoint: CGPoint = .zero
    @State var sheetShown: Bool = false
    var body: some View {
        let distance = CGTools.distanceSquared(from: thumbPoint, to: fingerAvaragePoint)
        let calibrationDistance = CGTools.distanceSquared(from: wristPoint, to: calibrationPoint)
        let calibratedDistance = distance/calibrationDistance
        ZStack{
            HandRecognitionSimpleOverlay(thumbPoint: $thumbPoint, fingerAvaragePoint: $fingerAvaragePoint, wristPoint: $wristPoint, calibrationPoint: $calibrationPoint)
                .onChange(of: thumbPoint) {
                    var pitch: Float
                    (noteName, pitch) = RangeToMusic.returnCorrectNote(allNotes: database.allNotes, minimumValue: database.minimumDistance, maximumValue: database.maximumDistance, currentValue: Float(calibratedDistance), pitchOffset: 0, octaves: database.octaves, startingOctave: database.startingOctave)
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
        }
        .toolbar{
            NavigationStack{
                NavigationLink(destination: CalibrationView()) {
                    Image(systemName: "hand.raised.palm.facing.fill")
                    Text("Calibrate")
                }.buttonStyle(PlainButtonStyle())
            }
            Button(action: {
                sheetShown.toggle()
            }, label: {
                Image(systemName: "slider.vertical.3")
                    .foregroundColor(.white)
            })
        }
        .onDisappear {
            audioManager.stopPlayback() // Stop sound when leaving view
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $sheetShown){
            VStack{
                Toggle(isOn: $database.allNotes, label:{
                                Text("All notes")
                            })
            }
                .padding(10)
        }
    }
    
}

#Preview {
    ContentView()
}
