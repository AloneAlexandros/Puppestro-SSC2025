import Foundation
import SwiftUI

class MusicToPitch: NSObject {
    let baseNotes = ["C": 261, "D": 293, "E": 329, "F": 349, "G": 392 ,"A" : 440, "B": 493]
    let allNotes = ["C": 261, "C#": 277, "D": 293, "D#": 311, "E": 329, "F": 349, "F#": 367, "G": 392, "G#": 415, "A": 440, "A#": 466, "B": 493, "empty": 0]
    let baseNoteNumbers = ["empty", "C", "D", "E", "F", "G", "A", "B"]
    let allNoteNumbers = ["empty", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    func returnCorrectNote(allNotes: Bool, minimumValue: Float, maximumValue: Float, currentValue: Float) -> String{
        let notesPerOctave = allNotes ? 13 : 8
        let totalNotes = notesPerOctave
        let OldRange = (maximumValue - minimumValue)
        let NewRange = (totalNotes - 0)
        let NewValue = (((currentValue - minimumValue) * Float(NewRange)) / OldRange) + 0
        return allNotes ? allNoteNumbers[Int(NewValue)] : baseNoteNumbers[Int(NewValue)]
    }
}
struct RangeTest: View {
    @State var sliderValue: Float = 0
    @State var noteName: String = ""
    @State var noteFrequency: Int = 0
    var body: some View {
        Text(noteName)
        Text(String(sliderValue))
        Slider(value: $sliderValue)
        Button("Reload", action: {
            noteName = MusicToPitch().returnCorrectNote(allNotes: true, minimumValue: 0, maximumValue: 1, currentValue: sliderValue)
        })
    }
}

#Preview {
    RangeTest()
}
