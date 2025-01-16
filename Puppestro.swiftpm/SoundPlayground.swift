import SwiftUI
import AVFoundation

class AudioManager: ObservableObject {
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let pitchControl = AVAudioUnitTimePitch()
    private var audioBuffer: AVAudioPCMBuffer?

    @Published var pitch: Float = 0.0 // Pitch in cents (-2400 to +2400)

    init() {
        setupAudio()
    }

    private func setupAudio() {
        guard let fileURL = Bundle.main.url(forResource: "aaaa", withExtension: "m4a") else {
            print("Audio file not found.")
            return
        }

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
        engine.stop()
    }

    func setPitch(_ value: Float) {
        pitchControl.pitch = value
    }
}

struct SoundPlayerView: View {
    @StateObject private var audioManager = AudioManager()

    var body: some View {
        VStack {
            Text("Real-Time Pitch Control")
                .font(.headline)
                .padding()

            Slider(value: $audioManager.pitch, in: -2400...2400, step: 1)
                .padding()
                .onChange(of: audioManager.pitch) { newPitch in
                    audioManager.setPitch(newPitch)
                }

            Text("Pitch: \(Int(audioManager.pitch)) cents")
                .font(.subheadline)
        }
        .onAppear {
            audioManager.startPlayback()
        }
        .onDisappear {
            audioManager.stopPlayback()
        }
    }
}

#Preview {
    SoundPlayerView()
}
