import Foundation
import SwiftUI

class RangeToMusic {
    static func returnCorrectNote(allNotes: Bool, minimumValue: Float, maximumValue: Float, currentValue: Float, pitchOffset: Int, octaves: Int, startingOctave: Int) -> (String, Float){
        let baseNotes = ["C": 0, "D": 200, "E": 400, "F": 500, "G": 700 ,"A" : 900, "B": 1100, "none": 0]
        let fullNotes = ["C": 0, "C#": 100, "D": 200, "D#": 300, "E": 400, "F": 500, "F#": 600, "G": 700, "G#": 800, "A": 900, "A#": 1000, "B": 1100, "none": 0]
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
        var NewValue = 0
        if OldRange != 0{
            NewValue = Int((((correctedValue - minimumValue) * Float(NewRange)) / OldRange) + 0)
        }
        else{
            NewValue = 0
        }

        var currentOctave = startingOctave
        while NewValue > notesPerOctave {
            NewValue -= notesPerOctave
            currentOctave += 1
        }
        let noteName = allNotes ? fullNoteNames[NewValue] : baseNoteNames[NewValue]
        var notePitch = allNotes ? fullNotes[noteName] ?? 0 : baseNotes[noteName] ?? 0
        notePitch = notePitch + (1200*currentOctave)
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
