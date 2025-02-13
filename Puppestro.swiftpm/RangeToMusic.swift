import Foundation
import SwiftUI

class RangeToMusic {
    static func returnCorrectNote(allNotes: Bool, minimumValue: Float, maximumValue: Float, currentValue: Float, pitchOffset: Int, octaves: Int, startingOctave: Int) -> (String, Float){
        let baseNotes = ["C": 261, "D": 293, "E": 329, "F": 349, "G": 392 ,"A" : 440, "B": 493, "none": 0]
        let fullNotes = ["C": 261, "C#": 277, "D": 293, "D#": 311, "E": 329, "F": 349, "F#": 367, "G": 392, "G#": 415, "A": 440, "A#": 466, "B": 493, "none": 0]
        let baseNoteNames = ["none", "C", "D", "E", "F", "G", "A", "B"]
        let fullNoteNames = ["none", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let notesPerOctave = allNotes ? 12 : 7
        let totalNotes = notesPerOctave * octaves + 1
        let OldRange = (maximumValue - minimumValue)
        let NewRange = (totalNotes - 0)
        var correctedValue:Float = 0
        if currentValue >= maximumValue {
            correctedValue = maximumValue
        } else if currentValue <= minimumValue {
            correctedValue = minimumValue
        } else {
            correctedValue = currentValue
        }
        var NewValue = Int((((correctedValue - minimumValue) * Float(NewRange)) / OldRange) + 0)
        var currentOctave = startingOctave
        while NewValue > notesPerOctave {
            NewValue -= notesPerOctave
            currentOctave += 1
        }
        let noteName = allNotes ? fullNoteNames[NewValue] : baseNoteNames[NewValue]
        var notePitch = allNotes ? fullNotes[noteName] ?? 0 : baseNotes[noteName] ?? 0
        notePitch = notePitch * Int(pow(2.0, Double(currentOctave)))
        return (noteName, Float(notePitch-pitchOffset))
    }
}
struct RangeTest: View {
    @State var sliderValue: Float = 0
    @State var noteName: String = ""
    @State var noteFrequency: Float = 0
    let allNotesUsed = false
    var body: some View {
        Text(noteName)
        Text(String(sliderValue))
        Text(String(noteFrequency))
        Slider(value: $sliderValue)
        .onChange(of: sliderValue) {
            (noteName, noteFrequency) = RangeToMusic.returnCorrectNote(allNotes: allNotesUsed, minimumValue: 0, maximumValue: 1, currentValue: sliderValue, pitchOffset: -94, octaves: 3, startingOctave: 0)
        }
    }
}

#Preview {
    RangeTest()
}
