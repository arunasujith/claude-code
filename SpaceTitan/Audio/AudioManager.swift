import AVFoundation
import SpriteKit

class AudioManager {
    static let shared = AudioManager()

    private var backgroundPlayer: AVAudioPlayer?
    private(set) var isMuted: Bool = false

    private init() {}

    func playBackgroundMusic(filename: String = "background_music.mp3") {
        guard !isMuted,
              let url = Bundle.main.url(forResource: filename, withExtension: nil) else { return }
        do {
            backgroundPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundPlayer?.numberOfLoops = -1
            backgroundPlayer?.volume = 0.4
            backgroundPlayer?.prepareToPlay()
            backgroundPlayer?.play()
        } catch {
            // Missing audio file — graceful no-op
        }
    }

    func stopBackgroundMusic() {
        backgroundPlayer?.stop()
        backgroundPlayer = nil
    }

    func pauseBackgroundMusic() {
        backgroundPlayer?.pause()
    }

    func resumeBackgroundMusic() {
        guard !isMuted else { return }
        backgroundPlayer?.play()
    }

    func playSFX(named name: String, on node: SKNode) {
        guard !isMuted else { return }
        node.run(SKAction.playSoundFileNamed(name, waitForCompletion: false))
    }

    func toggleMute() {
        isMuted.toggle()
        if isMuted {
            backgroundPlayer?.volume = 0
        } else {
            backgroundPlayer?.volume = 0.4
        }
    }
}
