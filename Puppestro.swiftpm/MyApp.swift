import SwiftUI

@main
struct MyApp: App {
    @StateObject var database = Database()
    var body: some Scene {
        WindowGroup {
            NavigationView {
                List {
                    NavigationLink(destination: CalibrationView()) {
                        Text("Calibrate")
                    }
                    NavigationLink(destination:ContentView()) {
                        Text("Play")
                    }
                }
                
                ContentView()
            }
                .environmentObject(database)
                .navigationBarBackButtonHidden(true)
        }
    }
}
