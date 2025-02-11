import SwiftUI
import AVFoundation

class AudioManager: ObservableObject {
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    @Published var pitchControl = AVAudioUnitTimePitch()
    private var audioBuffer: AVAudioPCMBuffer?

    init(fileName: String, fileExtension: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print("Audio file not found.")
            return
        }
        pitchControl.pitch = -94
        setupAudio(url)
    }

    private func setupAudio(_ fileURL: URL) {
        do {
            let file = try AVAudioFile(forReading: fileURL)
            let format = file.processingFormat  
            let frameCount = AVAudioFrameCount(file.length)

            audioBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)
            try file.read(into: audioBuffer!)

            engine.attach(playerNode)
            engine.attach(pitchControl)

            engine.connect(playerNode, to: pitchControl, format: format)
            engine.connect(pitchControl, to: engine.mainMixerNode, format: format)

            try engine.start()
        } catch {
            print("Error setting up audio: \(error)")
        }
    }

    func startPlayback() {
        guard let buffer = audioBuffer else { return }
        playerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
        playerNode.play()
    }

    func stopPlayback() {
        playerNode.stop()
    }
}

struct AudioManagerPlayground: View {
    @StateObject private var audioManager = AudioManager(fileName: "default", fileExtension: ".m4a")
    @State var isPlaying = false

    var body: some View {
        VStack {
            Text("Real-Time Pitch Control")
                .font(.headline)
                .padding()

            Slider(value: $audioManager.pitchControl.pitch, in: -2400...2400, step: 1)
                .padding()
            Stepper(value: $audioManager.pitchControl.pitch, in: -2400...2400, step: 100) {
                Text("Step a semitone")
            }
            Stepper(value: $audioManager.pitchControl.pitch, step: 1200)
            {
                Text("Step an octave")
            }

            Text("Pitch: \(Int(audioManager.pitchControl.pitch)) cents")
                .font(.subheadline)
        }
        Button {
            isPlaying.toggle()
            if isPlaying {
                audioManager.startPlayback()
            }
            else {
                audioManager.stopPlayback()
            }
        } label: {
            Text("Toggle playback")
                .font(.headline)
        }

    }
}

#Preview {
    AudioManagerPlayground()
}
