import SwiftUI

struct SessionPlayerView: View {
    let session: CompanionSession
    @EnvironmentObject private var audioManager: AudioManager
    @AppStorage("backgroundVolume") private var backgroundVolume = 0.7
    @AppStorage("voiceVolume") private var voiceVolume = 0.55
    @AppStorage("nightBrightness") private var nightBrightness = 0.25

    init(session: CompanionSession) {
        self.session = session
    }

    var body: some View {
        ZStack {
            ScreenBackground()

            ScrollView {
                VStack(spacing: 24) {
                    header
                    timerDial
                    playerControls
                    volumeStatus
                    currentStageCard
                    stagesList
                }
                .padding(.top, 22)
                .padding(.bottom, 24)
            }
        }
        .overlay {
            Color.black
                .opacity(nightOverlayOpacity)
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
        .onAppear {
            audioManager.prepare(session: session)
        }
        .sleepInlineNavigationTitle()
    }

    private var header: some View {
        VStack(spacing: 10) {
            Text(session.type.rawValue)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.warmGold)

            Text(session.title)
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text(session.subtitle)
                .font(.body)
                .foregroundStyle(.white.opacity(0.65))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.horizontal, 20)
    }

    private var timerDial: some View {
        ZStack {
            BreathingOrb(isActive: audioManager.isPlaying)
                .frame(width: 170, height: 170)
                .clipShape(Circle())

            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 18)

            Circle()
                .trim(from: 0, to: max(0.04, audioManager.progress))
                .stroke(Color.warmGold, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: audioManager.progress)

            VStack(spacing: 8) {
                Text(audioManager.remainingTimeText)
                    .font(.system(size: 46, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)

                Text(audioManager.isPlaying ? "陪伴中" : "暂停中")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.56))
            }
        }
        .frame(width: 210, height: 210)
        .padding(.vertical, 10)
    }

    private var playerControls: some View {
        HStack(spacing: 18) {
            Button {
                audioManager.adjustMinutes(by: -5)
            } label: {
                Image(systemName: "minus")
                    .frame(width: 48, height: 48)
            }
            .buttonStyle(PlayerRoundButtonStyle())

            Button {
                audioManager.toggle(session: session)
            } label: {
                Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                    .font(.title2)
                    .frame(width: 68, height: 68)
            }
            .buttonStyle(PrimaryPlayerButtonStyle())

            Button {
                audioManager.adjustMinutes(by: 5)
            } label: {
                Image(systemName: "plus")
                    .frame(width: 48, height: 48)
            }
            .buttonStyle(PlayerRoundButtonStyle())
        }
    }

    private var currentStageCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "现在")

            HStack(alignment: .top, spacing: 12) {
                Image(systemName: stageIconName)
                    .font(.headline)
                    .foregroundStyle(Color.nightInk)
                    .frame(width: 34, height: 34)
                    .background(Color.warmGold)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 8) {
                    Text(currentStage.title)
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text(currentCompanionLine)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.76))
                        .fixedSize(horizontal: false, vertical: true)

                    Text(currentStage.note)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.52))
                }

                Spacer()
            }
        }
        .padding(16)
        .background(Color.mistPanel)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .padding(.horizontal, 20)
    }

    private var stagesList: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "流程")

            ForEach(session.stages) { stage in
                StageRow(stage: stage, isActive: stage.id == currentStage.id)
            }
        }
        .padding(16)
        .background(Color.mistPanel)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .padding(.horizontal, 20)
    }

    private var volumeStatus: some View {
        HStack(spacing: 16) {
            Label("\(Int(backgroundVolume * 100))%", systemImage: "speaker.wave.2.fill")
            Label("\(Int(voiceVolume * 100))%", systemImage: "person.wave.2.fill")
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(.white.opacity(0.58))
    }

    private var currentStage: SessionStage {
        guard !session.stages.isEmpty else {
            return SessionStage(title: "安静陪伴", minutes: session.durationMinutes, note: "只需要待在这里。")
        }

        let elapsedSeconds = max(0, audioManager.totalSeconds - audioManager.remainingSeconds)
        var accumulatedSeconds = 0

        for stage in session.stages {
            accumulatedSeconds += stage.minutes * 60
            if elapsedSeconds < accumulatedSeconds {
                return stage
            }
        }

        return session.stages.last ?? session.stages[0]
    }

    private var currentCompanionLine: String {
        switch session.type {
        case .sleepOnset:
            "不用努力睡着。先让身体知道，今天已经可以慢慢收尾了。"
        case .anxiety:
            "现在醒着也不代表失败。我们先把紧绷感放低一点。"
        case .midnightAwake:
            "先别急着判断这一晚。你只是醒来了，我们重新安静一会儿。"
        case .silent:
            "我会尽量少打扰你，只留下一点稳定的声音。"
        case .mindUnload:
            "事情已经被放到旁边。现在不用继续解决它。"
        }
    }

    private var stageIconName: String {
        switch session.type {
        case .sleepOnset: "bed.double.fill"
        case .anxiety: "hand.raised.fill"
        case .midnightAwake: "moon.zzz.fill"
        case .silent: "speaker.wave.2.fill"
        case .mindUnload: "tray.and.arrow.down.fill"
        }
    }

    private var nightOverlayOpacity: Double {
        max(0, min(0.38, 0.38 - nightBrightness * 0.45))
    }
}

struct BreathingOrb: View {
    let isActive: Bool
    @State private var isExpanded = false

    var body: some View {
        Circle()
            .fill(Color.softBlue.opacity(isActive ? 0.16 : 0.08))
            .scaleEffect(isExpanded && isActive ? 1.02 : 0.86)
            .blur(radius: 12)
            .animation(
                isActive ? .easeInOut(duration: 4).repeatForever(autoreverses: true) : .easeOut(duration: 0.4),
                value: isExpanded
            )
            .onAppear {
                isExpanded = true
            }
            .onChange(of: isActive) { _, newValue in
                isExpanded = newValue
            }
    }
}

struct StageRow: View {
    let stage: SessionStage
    let isActive: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(stage.minutes)")
                .font(.caption.weight(.bold))
                .foregroundStyle(isActive ? Color.nightInk : Color.white.opacity(0.72))
                .frame(width: 28, height: 28)
                .background(isActive ? Color.warmGold : Color.white.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(stage.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isActive ? .white : .white.opacity(0.76))

                Text(stage.note)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(isActive ? 0.66 : 0.46))
            }

            Spacer()
        }
        .padding(.vertical, 2)
    }
}

struct PlayerRoundButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white.opacity(0.88))
            .background(Color.white.opacity(configuration.isPressed ? 0.18 : 0.10))
            .clipShape(Circle())
    }
}

struct PrimaryPlayerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.nightInk)
            .background(configuration.isPressed ? Color.warmGold.opacity(0.82) : Color.warmGold)
            .clipShape(Circle())
    }
}

#Preview {
    NavigationStack {
        SessionPlayerView(session: SampleData.sessions[0])
            .environmentObject(AudioManager())
    }
}
