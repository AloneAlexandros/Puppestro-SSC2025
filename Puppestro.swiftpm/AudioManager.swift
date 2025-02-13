import SwiftUI
import AVFoundation

class AudioManager: ObservableObject {
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    @Published var pitchControl = AVAudioUnitTimePitch()
    private var audioBuffer: AVAudioPCMBuffer?
    @Published var pitchOffset: Float = -94
    var isPlaying = false

    init(fileName: String, fileExtension: String, offset: Float) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print("Audio file not found.")
            return
        }
        setupAudio(url)
        pitchOffset = offset
        startPlayback()
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
        isPlaying = true
    }

    func stopPlayback() {
        playerNode.stop()
        isPlaying = false
    }
    
    func setPitch(_ pitch: Float){
        pitchControl.pitch = pitch + pitchOffset
        if (pitch == 0){
            stopPlayback()
        }
        else if (!isPlaying){
            startPlayback()
        }
    }
}

struct AudioManagerPlayground: View {
    @StateObject private var audioManager = AudioManager(fileName: "default", fileExtension: ".m4a", offset: -94)
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
