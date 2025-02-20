import SwiftUI

@main
struct MyApp: App {
    @StateObject var database = Database()
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                List {
                    NavigationLink(destination: CalibrationView()) {
                        Text("Calibrate")
                    }
                }
            }.environmentObject(database)
        }
    }
}
