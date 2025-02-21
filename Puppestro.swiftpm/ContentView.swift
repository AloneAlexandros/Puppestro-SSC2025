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
            HandRecognitionSimpleOverlay(thumbPoint: $thumbPoint, fingerAvaragePoint: $fingerAvaragePoint, wristPoint: $wristPoint, calibrationPoint: $calibrationPoint, scale: $database.scale, color: $database.color, showOverlay: $database.showOverlay, eyeScale: $database.eyeScale, eyeColor: $database.eyeColor)
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
            ToolbarItem(placement:.topBarLeading){
                NavigationStack{
                    NavigationLink(destination: WelcomeScreen()) {
                        Image(systemName: "house.fill")
                    }.buttonStyle(PlainButtonStyle()).foregroundColor(.accentColor)
                }
            }
            ToolbarItem{
                NavigationStack{
                    NavigationLink(destination: CalibrationView()) {
                        Image(systemName: "hand.raised.palm.facing.fill")
                        Text("Calibrate")
                    }.buttonStyle(PlainButtonStyle()).foregroundColor(.accentColor)
                }
            }
            ToolbarItem{
                Button(action: {
                    sheetShown.toggle()
                }, label: {
                    Image(systemName: "slider.vertical.3")
                })
            }
        }
        .onDisappear {
            audioManager.stopPlayback() // Stop sound when leaving view
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $sheetShown){
            VStack{
                Text("Settings")
                    .font(.largeTitle)
                Spacer()
                List{
                    Section(header: Text("Notes")){
                        Toggle(isOn: $database.allNotes, label:{
                            Text("All notes")
                            Text("Allows you to play the sharp notes too, not only the 7 base notes")
                                .font(.caption)
                        })
                        Stepper(value: $database.octaves, in: 1...2-database.startingOctave) {
                            Text("Octaves: \(database.octaves)")
                            Text("Making this higher will make playing notes harder, since it needs more precission")
                                .font(.caption)
                        }
                        Stepper(value: $database.startingOctave, in: -2...1){
                            Text("Starting octave: \(database.startingOctave)")
                            Text("0 is the 4th octave, with A at 440Hz")
                                .font(.caption)
                        }
                    }
                    Section(header: Text("Puppet overlay")){
                        Toggle(isOn: $database.showOverlay, label:{
                            Text("Show puppet overlay")
                        })
                        if database.showOverlay
                        {
                            HStack{
                                Text("Puppet scale")
                                Slider(value: $database.scale, in: 0...3)
                            }
                            HStack{
                                Text("Eye scale")
                                Slider(value: $database.eyeScale, in: 0...3)
                            }
                            ColorPicker("Puppet color", selection: $database.color)
                            ColorPicker("Eye color", selection: $database.eyeColor)
                        }
                    }
                    
                }
            }.padding(10)
        }
    }
    
}

#Preview {
    ContentView()
}
