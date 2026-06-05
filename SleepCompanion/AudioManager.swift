import Foundation
import Combine
import AVFoundation

final class AudioManager: ObservableObject {
    @Published private(set) var activeSession: CompanionSession?
    @Published private(set) var isPlaying = false
    @Published private(set) var remainingSeconds = 0
    @Published private(set) var totalSeconds = 0

    private var timer: Timer?
    private var player: AVAudioPlayer?

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(totalSeconds - remainingSeconds) / Double(totalSeconds)
    }

    var remainingTimeText: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func prepare(session: CompanionSession) {
        guard activeSession?.id != session.id else { return }
        let wasPlaying = isPlaying

        if wasPlaying {
            fadeOutCurrentAudio()
        } else {
            player?.stop()
        }

        activeSession = session
        totalSeconds = session.durationMinutes * 60
        remainingSeconds = totalSeconds
        stopTimer()
        configurePlayer(for: session)
        isPlaying = false

        if wasPlaying {
            playPreparedAudio(resetTime: true)
            isPlaying = true
            startTimer()
        }
    }

    func play(session: CompanionSession) {
        if activeSession?.id != session.id {
            prepare(session: session)
        }

        guard remainingSeconds > 0 else {
            reset(to: session.durationMinutes)
            return
        }

        isPlaying = true
        playPreparedAudio(resetTime: false)
        startTimer()
    }

    func pause() {
        isPlaying = false
        player?.pause()
        stopTimer()
    }

    func toggle(session: CompanionSession) {
        isPlaying ? pause() : play(session: session)
    }

    func adjustMinutes(by minutes: Int) {
        let updatedSeconds = max(5 * 60, remainingSeconds + minutes * 60)
        remainingSeconds = updatedSeconds
        totalSeconds = max(totalSeconds, updatedSeconds)
    }

    func reset(to minutes: Int) {
        pause()
        totalSeconds = minutes * 60
        remainingSeconds = totalSeconds
    }

    func stop() {
        pause()
        remainingSeconds = 0
        player?.currentTime = 0
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }

            if remainingSeconds > 0 {
                remainingSeconds -= 1
            }

            if remainingSeconds == 0 {
                pause()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func configurePlayer(for session: CompanionSession) {
        guard let audioName = audioResourceName(for: session),
              let url = Bundle.main.url(forResource: audioName, withExtension: "m4a") else {
            player = nil
            return
        }

        do {
            let sessionCategory = AVAudioSession.sharedInstance()
            try sessionCategory.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try sessionCategory.setActive(true)

            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.numberOfLoops = -1
            audioPlayer.prepareToPlay()
            player = audioPlayer
        } catch {
            player = nil
            print("Failed to prepare audio: \(error)")
        }
    }

    private func audioResourceName(for session: CompanionSession) -> String? {
        switch session.soundscape {
        case "篝火": "campfire"
        case "海洋": "ocean"
        case "森林": "forest"
        case "雨天": "rain"
        default: nil
        }
    }

    private func playPreparedAudio(resetTime: Bool) {
        guard let player else { return }

        if resetTime {
            player.currentTime = 0
        }

        player.volume = 0
        player.play()
        player.setVolume(1, fadeDuration: 0.35)
    }

    private func fadeOutCurrentAudio() {
        guard let player else { return }
        player.setVolume(0, fadeDuration: 0.2)
        let fadingPlayer = player
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            fadingPlayer.stop()
        }
    }
}
