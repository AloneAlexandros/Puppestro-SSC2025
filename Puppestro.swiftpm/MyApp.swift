import SwiftUI

@main
struct MyApp: App {
    @StateObject var database = Database()
    var body: some Scene {
        WindowGroup {
            WelcomeScreen()
                .environmentObject(database)
                .navigationTitle("Welcome")
        }
    }
}
