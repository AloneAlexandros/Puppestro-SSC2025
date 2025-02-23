import SwiftUI
import Foundation

struct CalibrationView: View {
    @EnvironmentObject var database : Database
    @State var thumbPoint: CGPoint = .zero
    @State var fingerAvaragePoint: CGPoint = .zero
    @State var wristPoint: CGPoint = .zero
    @State var calibrationPoint: CGPoint = .zero
    @State var noteName: String = "none"
    @State var notePoint: CGPoint = .zero
    @State var showOverlay: Bool = false
    @State var showSheet = true
    @State var countdown: Int = 5
    @State var counter = 0
    @State var maxCounter = 30
    @State var barColor = Color.accentColor
    @State var showOtherSheet: Bool = false
    @Binding var nextScreen: Bool
    var body: some View {
        let distance = CGTools.distanceSquared(from: thumbPoint, to: fingerAvaragePoint)
        let calibrationDistance = CGTools.distanceSquared(from: wristPoint, to: calibrationPoint)
        let calibratedDistance = distance/calibrationDistance
        ZStack{
            HandRecognitionSimpleOverlay(thumbPoint: $thumbPoint, fingerAvaragePoint: $fingerAvaragePoint, wristPoint: $wristPoint, calibrationPoint: $calibrationPoint, scale: $database.scale, color: $database.color, showOverlay: $showOverlay, eyeScale: $database.eyeScale, eyeColor: $database.eyeColor)
                .onChange(of: thumbPoint) {
                    if showSheet == false{
                        showOtherSheet = true
                    }
                    var pitch: Float
                    (noteName, pitch) = RangeToMusic.returnCorrectNote(allNotes: false, minimumValue: database.minimumDistance, maximumValue: database.maximumDistance, currentValue: Float(calibratedDistance), pitchOffset: 0, octaves: 1, startingOctave: 0)
                    if noteName == "C" || noteName == "B"{
                        noteName = "maximum distance"
                        counter = 0
                    } else if noteName == "none"{
                        noteName = "minimum distance"
                        if counter <= maxCounter{
                            counter += 1
                        }
                        if counter >= maxCounter{
                            countdown = 5
                            showSheet = true
                        }
                    } else{
                        noteName = "in between"
                        counter = 0
                    }
                    notePoint = CGTools.avarage([thumbPoint, fingerAvaragePoint])
                    if countdown < 1{
                        if Float(calibratedDistance) < database.minimumDistance{
                            database.minimumDistance = Float(calibratedDistance)
                        }
                        if Float(calibratedDistance) > database.maximumDistance{
                            database.maximumDistance = Float(calibratedDistance)
                        }
                    }
                }
            ZStack{
                if thumbPoint != .zero{
                    CircularProgressView(barColor: $barColor, progress: $counter, maxProgress: $maxCounter)
                        .frame(width: 200, height: 200)
                    Text(noteName)
                        .font(.largeTitle)
                }
            }.position(x: notePoint.x, y: notePoint.y)
            if(countdown>0)
            {
                Text("\(countdown)")
                    .font(.largeTitle)
                    .frame(width: 150, height: 150)
                    .background(.green.opacity(0.5))
                    .cornerRadius(180)
            }
        }
        .sheet(isPresented: $showSheet){
            VStack{
                if !showOtherSheet{
                        VStack{
                            Text("Let's callibrate your hand to be able to play!")
                                .multilineTextAlignment(.center)
                                .padding(10)
                                .font(.title)
                                .bold(true)
                            Text("After pressing Continue, close your hand in the form of a puppet. Then open it as wide as you can, and close it again.")
                                .padding(10)
                                .multilineTextAlignment(.center)
                            HStack{
                                Image("closedHand")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 120)
                                    .background(.gray)
                                    .cornerRadius(40)
                                    .padding(10)
                                Image(systemName: "arrowshape.right.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 10, height: 10)
                                Image("openHand")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 120)
                                    .background(.gray)
                                    .cornerRadius(40)
                                    .padding(10)
                                Image(systemName: "arrowshape.right.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 10, height: 10)
                                Image("closedHand")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 120)
                                    .background(.gray)
                                    .cornerRadius(40)
                                    .padding(10)
                            }
                            Button(action:{
                                showSheet = false
                                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                                    if countdown > 0 {
                                        countdown -= 1
                                    } else {
                                        timer.invalidate() // Stop the timer when countdown reaches 0
                                    }
                                }
                            },label:{
                                Image(systemName: "arrowshape.right.fill")
                                Text("Continue")
                            }).font(.largeTitle)
                        }
                            .interactiveDismissDisabled(true)
                } else{
                    VStack{
                        Image(systemName: "checkmark")
                            .font(nil ?? .system(size: 100, weight: .bold, design: .default))
                            .foregroundColor(.green)
                            .padding(10)
                        Text("Done! You are now properly calibrated!")
                            .bold(true)
                            .font(.largeTitle)
                            .padding(10)
                            .multilineTextAlignment(.center)
                        Text("If you can't reach high notes or you feel like something is wrong, press the Callibrate button in the top right to callibrate again!")
                            .multilineTextAlignment(.center)
                        Button(action:{
                            nextScreen = false
                        },label:{
                            Image(systemName: "arrowshape.right.fill")
                            Text("Continue")
                        })
                            .font(.largeTitle)
                            .padding(10)
                            .foregroundStyle(Color.accentColor)
                    }
                        .interactiveDismissDisabled(true)
                }
            }
        }
        .toolbar{
            ToolbarItem(placement:.topBarLeading){
                NavigationStack{
                    NavigationLink(destination: WelcomeScreen()) {
                        Image(systemName: "house.fill")
                    }.buttonStyle(PlainButtonStyle()).foregroundColor(.accentColor)
                }
            }
        }
        .onAppear{
            database.minimumDistance = 1000000
            database.maximumDistance = 0
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct CircularProgressView: View {
    @Binding var barColor: Color
    @Binding var progress: Int
    @Binding var maxProgress: Int
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    barColor.opacity(0.5),
                    lineWidth: 30
                )
            Circle()
                .trim(from: 0, to: Double(progress)/Double(maxProgress)) // 1
                .stroke(
                    barColor,
                    style: StrokeStyle(
                        lineWidth: 30,
                        lineCap: .round
                    )
                ).rotationEffect(.degrees(-90))
        }
    }
}
