import SwiftUI

struct WelcomeScreen: View {
    @EnvironmentObject var database: Database
    var body: some View {
        NavigationStack{
            VStack{
                Text("Welcome to Puppestro!")
                    .font(.largeTitle)
                    .padding(10)
                    .bold()
                Text("Puppestro is a musical game where you play notes with you hand, like if it was a puppet! Choose to enter the tutorial if you haven't played before, otherwise start playing!")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 50)
            .background(Color.primary.opacity(0.2))
            .shadow(color: Color.secondary.opacity(0.1), radius: 10, x: 0, y: 5) // Add shadow
            ScrollView{
                let rows = [
                    GridItem(.adaptive(minimum: 230))
                ]
                LazyVGrid(columns: rows, spacing: 20)
                {
                    NavigationLink(destination: Tutorial()){
                        VStack{
                            Image(systemName: "graduationcap.fill")
                                .frame(width: 210, height: 170)
                                .background(Color.green)
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .font(.largeTitle)
                            Text("Tutorial")
                                .font(.caption)
                        }
                        
                    }.buttonStyle(PlainButtonStyle())
                    NavigationLink(destination: CalibrateSwitcher(isCalibrated: (database.maximumDistance != 0))){
                        VStack{
                            Image(systemName: "music.mic")
                                .frame(width: 210, height: 170)
                                .background(Color.yellow)
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .font(.largeTitle)
                            Text("Freeplay")
                                .font(.caption)
                        }
                        
                    }.buttonStyle(PlainButtonStyle())
                }.padding(50)
            }
            Spacer()
        }.navigationBarBackButtonHidden(true)
    }
}

#Preview {
    WelcomeScreen()
}
