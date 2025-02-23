import SwiftUI

struct CalibrateSwitcher: View {
    @State var firstViewIsShown: Bool = true
    @EnvironmentObject var database : Database
    @State var isCalibrated : Bool = false
    var body: some View {
        if firstViewIsShown && !isCalibrated{
            CalibrationView(nextScreen: $firstViewIsShown)
        } else {
            ContentView()
        }
    }
}

