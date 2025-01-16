//
//  SoundPlayground.swift
//  Puppestro
//
//  Created by Αλέξανδρος Σαμωνάκης on 16/1/25.
//

import SwiftUI
import AVFoundation

struct SoundPlayground: View {
    @State var audioPlayer: AVAudioPlayer?
    let engine = AVAudioEngine()
    let speedControl = AVAudioUnitVarispeed()
    @State var pitchControl = AVAudioUnitTimePitch()
    var body: some View {
        Text("Shimmy shimmy yawn")
            .task {
              while true { // replace true with variable if you want to stop it
                  let sound = Bundle.main.path(forResource: "aaaa", ofType: "m4a")
                  try! play(URL(fileURLWithPath: sound!))
                  try? await Task.sleep(for: .seconds(4))
              }
            }
            .onAppear {
                let sound = Bundle.main.path(forResource: "aaaa", ofType: "m4a")
                try! play(URL(fileURLWithPath: sound!))
            }
        Slider(value: $pitchControl.pitch, in: -1200...1200)
    }

    func play(_ url: URL) throws {
        // 1: load the file
        let file = try AVAudioFile(forReading: url)

        // 2: create the audio player
        let audioPlayer = AVAudioPlayerNode()

        // 3: connect the components to our playback engine
        engine.attach(audioPlayer)
        engine.attach(pitchControl)
        engine.attach(speedControl)

        // 4: arrange the parts so that output from one is input to another
        engine.connect(audioPlayer, to: speedControl, format: nil)
        engine.connect(speedControl, to: pitchControl, format: nil)
        engine.connect(pitchControl, to: engine.mainMixerNode, format: nil)

        // 5: prepare the player to play its file from the beginning
        audioPlayer.scheduleFile(file, at: nil)

        // 6: start the engine and player
        try engine.start()
        audioPlayer.play()
    }
}


#Preview {
    SoundPlayground()
}
