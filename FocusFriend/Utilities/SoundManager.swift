import Foundation
import AppKit

class SoundManager {
    static let shared = SoundManager()

    private init() {}

    func playSound(named name: String) {
        if let sound = NSSound(named: NSSound.Name(name)) {
            sound.play()
        }
    }

    func playCompletionSound(soundName: String) {
        playSound(named: soundName)
    }

    func previewSound(named name: String) {
        playSound(named: name)
    }
}
