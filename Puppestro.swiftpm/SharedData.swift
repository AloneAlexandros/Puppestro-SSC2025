import SwiftUI

class Database : ObservableObject {
    @Published var minimumDistance: Float = 1000
    @Published var maximumDistance: Float = -1000
    @Published var allNotes = false
    @Published var octaves = 1
    @Published var startingOctave = 0
    @Published var scale: CGFloat = 1.3
    @Published var color = Color.red
    @Published var showOverlay: Bool = true
    @Published var eyeScale: CGFloat = 1
    @Published var eyeColor: Color = Color.black
}
