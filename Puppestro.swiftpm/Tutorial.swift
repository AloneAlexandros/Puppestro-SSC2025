import SwiftUI

struct Tutorial: View {
    var body: some View {
        ScrollView{
                HStack{
                    Image(systemName: "info.bubble.fill")
                    Text("Preperation")
                }.font(.title)
                    .frame(width: 230, height: 70)
                    .background(.orange)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
                    .padding(30)
            Text("Place your ipad on some kind of stand facing towards you. Make sure it can only see ONE hand, two hands will confuse the hand recognition")
                .padding(10)
                .font(.title3)
                .multilineTextAlignment(.center)
                .bold(true)
            HStack{
                Image("ipad")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .background(.gray)
                    .cornerRadius(40)
                    .padding(10)
                Image("backpad")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .background(.gray)
                    .cornerRadius(40)
                    .padding(10)
            }
                Text("Make sure you don't wear anything on your hand, as it will mess with the hand recognition. No gloves and absolutely no socks!")
                    .padding(10)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .bold(true)
                HStack{
                    ZStack{
                        Image("wrongHand")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 230, height: 300)
                            .background(.red)
                            .cornerRadius(40)
                            .padding(10)
                        Image(systemName:"xmark")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundStyle(.white)
                            .offset(x: 80, y: 80)
                    }
                    ZStack{
                        Image("correctHand")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 230, height: 300)
                            .background(.green)
                            .cornerRadius(40)
                            .padding(10)
                        Image(systemName:"checkmark")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundStyle(.white)
                            .offset(x: 80, y: 80)
                    }
                }
            Text("Form a puppet with your hand. Make it face sideways, not towards the screen!")
                .padding(20)
                .font(.title3)
                .multilineTextAlignment(.center)
                .bold(true)
            HStack{
                ZStack{
                    Image("wrongPuppet")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 230, height: 200)
                        .background(.red)
                        .cornerRadius(40)
                        .padding(10)
                    Image(systemName:"xmark")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundStyle(.white)
                        .offset(x: 60, y: 50)
                }
                ZStack{
                    Image("correctPuppet")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 230, height: 200)
                        .background(.green)
                        .cornerRadius(40)
                        .padding(10)
                    Image(systemName:"checkmark")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundStyle(.white)
                        .offset(x: 60, y: 50)
                }
            }
            Text("Make sure you have good lighting-not too bright not too dark-as it will seriously mess with the hand recognition")
                .padding(20)
                .font(.title3)
                .multilineTextAlignment(.center)
                .bold(true)
            HStack{
                ZStack{
                    Image("darkHand")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 230, height: 200)
                        .background(.red)
                        .cornerRadius(40)
                        .padding(10)
                    Image(systemName:"xmark")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundStyle(.white)
                        .offset(x: 60, y: 50)
                }
                ZStack{
                    Image("lightHand")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 230, height: 200)
                        .background(.red)
                        .cornerRadius(40)
                        .padding(10)
                    Image(systemName:"xmark")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundStyle(.white)
                        .offset(x: 60, y: 50)
                }
                ZStack{
                    Image("correctPuppet")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 230, height: 200)
                        .background(.green)
                        .cornerRadius(40)
                        .padding(10)
                    Image(systemName:"checkmark")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundStyle(.white)
                        .offset(x: 60, y: 50)
                }
            }
            HStack{
                Image(systemName: "questionmark.bubble.fill")
                Text("How to play")
            }.font(.title)
                .frame(width: 230, height: 70)
                .background(.green)
                .foregroundStyle(.white)
                .cornerRadius(10)
                .padding(30)
            Text("It's really simple! Just open your hand wider to play a higher note and close it for a lower note. It's just like playing with a sock puppet!")
                .padding(20)
                .font(.title3)
                .multilineTextAlignment(.center)
                .bold(true)
            HStack{
                Image("closedHand")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 230, height: 200)
                    .background(.gray)
                    .cornerRadius(40)
                    .padding(10)
                Image("halfopenHand")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 230, height: 200)
                    .background(.gray)
                    .cornerRadius(40)
                    .padding(10)
                Image("openHand")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 230, height: 200)
                    .background(.gray)
                    .cornerRadius(40)
                    .padding(10)
            }
            Text("By default you can only play notes from the one octave (From C to B). You can edit that in the in-game settings on the top right corner of the screen!")
                .padding(20)
                .font(.title3)
                .multilineTextAlignment(.center)
                .bold(true)
            NavigationStack{
                NavigationLink(destination: CalibrateSwitcher()){
                    HStack{
                        Image(systemName: "arrowshape.right.fill")
                        Text("Continue to calibration")
                    }
                }.buttonStyle(PlainButtonStyle()).font(.title).foregroundStyle(Color.accentColor).padding(30)
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
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    Tutorial()
}
