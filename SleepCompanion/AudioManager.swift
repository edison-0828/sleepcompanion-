import Foundation
import Combine

final class AudioManager: ObservableObject {
    @Published private(set) var activeSession: CompanionSession?
    @Published private(set) var isPlaying = false
    @Published private(set) var remainingSeconds = 0
    @Published private(set) var totalSeconds = 0

    private var timer: Timer?

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
        activeSession = session
        totalSeconds = session.durationMinutes * 60
        remainingSeconds = totalSeconds
        isPlaying = false
        stopTimer()
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
        startTimer()
    }

    func pause() {
        isPlaying = false
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
}
