import Foundation
import Combine
import AVFoundation

@MainActor
final class AudioManager: ObservableObject {
    @Published private(set) var activeSession: CompanionSession?
    @Published private(set) var isPlaying = false
    @Published private(set) var remainingSeconds = 0
    @Published private(set) var totalSeconds = 0

    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private var currentBuffer: AVAudioPCMBuffer?
    private var timer: Timer?
    private var fadeTimer: Timer?
    init() {
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: nil)
        engine.mainMixerNode.outputVolume = 1
    }

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
            fadeOutCurrentAudio {
                self.load(session: session)
                self.startPlayback(resetTime: true, fadeDuration: 0.8)
            }
        } else {
            stopNode(resetTimeline: true)
            load(session: session)
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

        startPlayback(resetTime: false, fadeDuration: 0.8)
    }

    func pause() {
        isPlaying = false
        fadeTimer?.invalidate()
        fadeTimer = nil

        guard playerNode.isPlaying else {
            stopTimer()
            return
        }

        let currentLevel = playerNode.volume
        fadeVolume(from: currentLevel, to: 0.0, duration: 0.35) { [weak self] in
            guard let self else { return }
            self.playerNode.pause()
            self.stopTimer()
        }
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
        stopNode(resetTimeline: true)
    }

    private func load(session: CompanionSession) {
        activeSession = session
        totalSeconds = session.durationMinutes * 60
        remainingSeconds = totalSeconds
        stopTimer()
        currentBuffer = makeBuffer(for: session)
        playerNode.volume = 0
        scheduleCurrentBuffer()
    }

    private func startPlayback(resetTime: Bool, fadeDuration: TimeInterval) {
        guard currentBuffer != nil else { return }

        do {
            try configureAudioSession()
            try startEngineIfNeeded()
        } catch {
            print("Failed to start audio engine: \(error)")
            return
        }

        if resetTime {
            remainingSeconds = totalSeconds
            stopNode(resetTimeline: true)
            scheduleCurrentBuffer()
        }

        guard !playerNode.isPlaying else {
            isPlaying = true
            return
        }

        playerNode.play()
        isPlaying = true
        startTimer()
        fadeVolume(
            from: playerNode.volume,
            to: playbackVolume(for: activeSession),
            duration: fadeDuration,
            completion: nil
        )
    }

    private func scheduleCurrentBuffer() {
        guard let currentBuffer else { return }
        playerNode.stop()
        playerNode.scheduleBuffer(currentBuffer, at: nil, options: .loops, completionHandler: nil)
    }

    private func stopNode(resetTimeline: Bool) {
        fadeTimer?.invalidate()
        fadeTimer = nil
        playerNode.stop()
        playerNode.volume = 0

        if resetTimeline {
            stopTimer()
        }
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }

                if self.remainingSeconds > 0 {
                    self.remainingSeconds -= 1
                }

                if self.remainingSeconds == 0 {
                    self.pause()
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func makeBuffer(for session: CompanionSession) -> AVAudioPCMBuffer? {
        guard let audioName = audioResourceName(for: session),
              let url = Bundle.main.url(forResource: audioName, withExtension: "m4a") else {
            return nil
        }

        do {
            let file = try AVAudioFile(forReading: url)
            let frameCount = AVAudioFrameCount(file.length)

            guard let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: frameCount) else {
                return nil
            }

            try file.read(into: buffer)
            return buffer
        } catch {
            print("Failed to create audio buffer: \(error)")
            return nil
        }
    }

    private func configureAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try audioSession.setActive(true)
    }

    private func startEngineIfNeeded() throws {
        if !engine.isRunning {
            try engine.start()
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

    private func playbackVolume(for session: CompanionSession?) -> Float {
        guard let session else { return 0.62 }

        switch session.soundscape {
        case "篝火":
            return 0.7
        case "海洋":
            return 0.58
        case "森林":
            return 0.6
        case "雨天":
            return 0.6
        default:
            return 0.62
        }
    }

    private func fadeOutCurrentAudio(completion: @escaping @MainActor () -> Void) {
        guard playerNode.isPlaying else {
            stopNode(resetTimeline: false)
            completion()
            return
        }

        let currentLevel = playerNode.volume
        fadeVolume(from: currentLevel, to: 0.0, duration: 0.35) { [weak self] in
            guard let self else { return }
            self.stopNode(resetTimeline: false)
            completion()
        }
    }

    private func fadeVolume(
        from startVolume: Float,
        to endVolume: Float,
        duration: TimeInterval,
        completion: (@MainActor () -> Void)?
    ) {
        fadeTimer?.invalidate()

        guard duration > 0 else {
            playerNode.volume = endVolume
            completion?()
            return
        }

        let stepInterval = 0.05
        let steps = max(1, Int(duration / stepInterval))
        var currentStep = 0

        playerNode.volume = startVolume
        fadeTimer = Timer.scheduledTimer(withTimeInterval: stepInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else {
                    return
                }

                currentStep += 1
                let progress = min(1, Float(currentStep) / Float(steps))
                let easedProgress = 1 - pow(1 - progress, 2)
                self.playerNode.volume = startVolume + (endVolume - startVolume) * easedProgress

                if progress >= 1 {
                    self.fadeTimer?.invalidate()
                    self.fadeTimer = nil
                    self.playerNode.volume = endVolume
                    completion?()
                }
            }
        }
    }
}
