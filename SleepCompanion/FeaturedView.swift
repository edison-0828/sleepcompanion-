import SwiftUI
import AVFoundation

struct FeaturedView: View {
    @EnvironmentObject private var audioManager: AudioManager
    @State private var selectedSceneID = HomeSoundScene.scenes[0].id
    @State private var isSceneTitleVisible = true

    private var selectedScene: HomeSoundScene {
        HomeSoundScene.scenes.first(where: { $0.id == selectedSceneID }) ?? HomeSoundScene.scenes[0]
    }

    private let weekdaySymbols = ["一", "二", "三", "四", "五", "六", "日"]

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let bottomBarReserve = geometry.safeAreaInsets.bottom + 106

                ZStack(alignment: .topLeading) {
                    sceneBackdrop

                    VStack(alignment: .leading, spacing: 0) {
                        topSection
                        Spacer()
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, max(18, geometry.safeAreaInsets.top + 4))

                    sceneTitleOverlay
                        .padding(.horizontal, 18)
                        .padding(.bottom, bottomBarReserve + 96)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                .ignoresSafeArea()
                .background(Color.black)
            }
            .homeNavigationHidden()
            .contentShape(Rectangle())
            .simultaneousGesture(sceneSwipeGesture)
            .onTapGesture {
                audioManager.toggle(session: selectedScene.session)
            }
            .onAppear {
                audioManager.prepare(session: selectedScene.session)
                revealSceneTitleTemporarily()
            }
            .onChange(of: selectedSceneID) { _, newValue in
                guard let scene = HomeSoundScene.scenes.first(where: { $0.id == newValue }) else { return }
                audioManager.prepare(session: scene.session)
                revealSceneTitleTemporarily()
            }
        }
    }

    private var topSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 10) {
                Text(greetingText)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 4)

                weekdayStrip
            }

            Spacer()

            sceneControls
                .padding(.top, 6)
                .padding(.trailing, 74)
        }
    }

    private var weekdayStrip: some View {
        HStack(spacing: 12) {
            ForEach(Array(displayWeekdays.enumerated()), id: \.offset) { index, item in
                Text(item.title)
                    .font(.system(size: 15, weight: item.isToday ? .bold : .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(item.isToday ? 0.94 : 0.42))
            }
        }
    }

    private var displayWeekdays: [WeekdayItem] {
        weekdaySymbols.enumerated().map { index, symbol in
            WeekdayItem(title: index == todayWeekdayIndex ? "今" : symbol, isToday: index == todayWeekdayIndex)
        }
    }

    private var todayWeekdayIndex: Int {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return (weekday + 5) % 7
    }

    private var sceneControls: some View {
        HStack(spacing: 0) {
            Button {
                audioManager.toggle(session: selectedScene.session)
            } label: {
                Image(systemName: audioManager.isPlaying && audioManager.activeSession?.id == selectedScene.session.id ? "pause.fill" : "speaker.wave.2")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 54)
            }
            .buttonStyle(.plain)

            Divider()
                .frame(height: 24)
                .overlay(.white.opacity(0.16))

            Button {
                moveScene(by: 1)
            } label: {
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 54)
            }
            .buttonStyle(.plain)
        }
        .background(.white.opacity(0.10))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        }
        .clipShape(Capsule())
    }

    private var sceneTitleOverlay: some View {
        VStack(spacing: 4) {
            ForEach(Array(selectedScene.title), id: \.self) { character in
                Text(String(character))
                    .font(.system(size: 34, weight: .light, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))
                    .shadow(color: .black.opacity(0.14), radius: 12, x: 0, y: 6)
            }
        }
        .opacity(isSceneTitleVisible ? 1 : 0)
        .scaleEffect(isSceneTitleVisible ? 1 : 0.96)
        .blur(radius: isSceneTitleVisible ? 0 : 4)
        .animation(.easeOut(duration: 0.32), value: isSceneTitleVisible)
    }

    private var sceneBackdrop: some View {
        ZStack {
            ForEach(HomeSoundScene.scenes) { scene in
                SceneBackdropLayer(scene: scene, isSelected: scene.id == selectedSceneID)
                    .ignoresSafeArea()
                    .scaleEffect(scene.id == selectedSceneID ? 1.0 : 1.04)
                    .offset(x: sceneOffset(for: scene))
                    .opacity(scene.id == selectedSceneID ? 1 : 0)
                    .animation(.easeInOut(duration: 0.52), value: selectedSceneID)
            }

            LinearGradient(
                colors: [
                    .white.opacity(0.08),
                    .clear,
                    Color.black.opacity(0.12)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
        .animation(.easeInOut(duration: 0.38), value: selectedSceneID)
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 5 && hour < 12 ? "早上好" : "晚上好"
    }

    private var sceneSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 12, coordinateSpace: .local)
            .onEnded { value in
                let horizontal = value.translation.width
                let vertical = value.translation.height

                guard abs(horizontal) > abs(vertical), abs(horizontal) > 24 else { return }

                if horizontal < 0 {
                    moveScene(by: 1)
                } else {
                    moveScene(by: -1)
                }
            }
    }

    private func moveScene(by delta: Int) {
        guard let currentIndex = HomeSoundScene.scenes.firstIndex(where: { $0.id == selectedSceneID }) else { return }
        let lastIndex = HomeSoundScene.scenes.count - 1
        let nextIndex = min(max(currentIndex + delta, 0), lastIndex)
        selectedSceneID = HomeSoundScene.scenes[nextIndex].id
    }

    private func sceneOffset(for scene: HomeSoundScene) -> CGFloat {
        let delta = sceneIndex(for: scene.id) - sceneIndex(for: selectedSceneID)
        if scene.id == selectedSceneID { return 0 }
        return CGFloat(delta) * 28
    }

    private func sceneIndex(for id: HomeSoundScene.ID) -> Int {
        HomeSoundScene.scenes.firstIndex(where: { $0.id == id }) ?? 0
    }

    private func revealSceneTitleTemporarily() {
        let currentSceneID = selectedSceneID
        isSceneTitleVisible = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            guard selectedSceneID == currentSceneID else { return }
            withAnimation(.easeOut(duration: 0.32)) {
                isSceneTitleVisible = false
            }
        }
    }
}

private struct WeekdayItem {
    let title: String
    let isToday: Bool
}

private struct HomeSoundScene: Identifiable {
    let id = UUID()
    let title: String
    let defaultTime: String
    let imageName: String
    let videoResourceName: String?
    let session: CompanionSession

    static let scenes: [HomeSoundScene] = [
        HomeSoundScene(
            title: "篝火",
            defaultTime: "45:00",
            imageName: "HomeCampfire",
            videoResourceName: "campfire-loop",
            session: CompanionSession(
                title: "篝火守夜",
                subtitle: "微弱火声持续陪伴，适合慢慢躺平。",
                type: .silent,
                durationMinutes: 45,
                soundscape: "篝火",
                stages: [
                    SessionStage(title: "火苗底噪", minutes: 45, note: "稳定的火声持续到结束。")
                ]
            )
        ),
        HomeSoundScene(
            title: "海洋",
            defaultTime: "30:00",
            imageName: "HomeOcean",
            videoResourceName: nil,
            session: CompanionSession(
                title: "海浪靠岸",
                subtitle: "海浪规律起伏，适合让节奏慢下来。",
                type: .silent,
                durationMinutes: 30,
                soundscape: "海洋",
                stages: [
                    SessionStage(title: "海浪声", minutes: 30, note: "规律海浪从近到远循环播放。")
                ]
            )
        ),
        HomeSoundScene(
            title: "森林",
            defaultTime: "35:00",
            imageName: "HomeForest",
            videoResourceName: nil,
            session: CompanionSession(
                title: "林间夜色",
                subtitle: "树叶和微风保持轻微变化，不会太单调。",
                type: .silent,
                durationMinutes: 35,
                soundscape: "森林",
                stages: [
                    SessionStage(title: "林间氛围", minutes: 35, note: "风声、虫鸣和树叶声轻微交替。")
                ]
            )
        ),
        HomeSoundScene(
            title: "雨天",
            defaultTime: "40:00",
            imageName: "HomeRain",
            videoResourceName: nil,
            session: CompanionSession(
                title: "窗边细雨",
                subtitle: "有层次的雨声，像远远落在窗外。",
                type: .silent,
                durationMinutes: 40,
                soundscape: "雨天",
                stages: [
                    SessionStage(title: "雨声铺底", minutes: 40, note: "细雨和屋檐水声保持稳定。")
                ]
            )
        )
    ]
}

private struct SceneBackdropLayer: View {
    let scene: HomeSoundScene
    let isSelected: Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Image(scene.imageName)
                    .resizable()
                    .scaledToFill()

                if let videoResourceName = scene.videoResourceName {
                    LoopingBackgroundVideoView(
                        resourceName: videoResourceName,
                        isPlaying: isSelected
                    )
                    .scaleEffect(1.02)
                    .frame(width: geometry.size.width * 0.62, height: geometry.size.height * 0.34)
                    .offset(y: geometry.size.height * 0.04)
                    .opacity(isSelected ? 0.42 : 0)
                    .mask(campfireMotionMask)
                    .animation(.easeInOut(duration: 0.28), value: isSelected)
                }

                if scene.videoResourceName != nil {
                    campfireToneOverlay
                }
            }
        }
        .clipped()
    }

    private var campfireToneOverlay: some View {
        ZStack {
            Color.black.opacity(0.20)

            LinearGradient(
                colors: [
                    Color.black.opacity(0.34),
                    Color.black.opacity(0.10),
                    Color.black.opacity(0.30)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            LinearGradient(
                colors: [
                    Color(red: 0.30, green: 0.17, blue: 0.08).opacity(0.22),
                    .clear,
                    Color(red: 0.18, green: 0.10, blue: 0.05).opacity(0.16)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .allowsHitTesting(false)
    }

    private var campfireMotionMask: some View {
        ZStack {
            RadialGradient(
                colors: [
                    Color.white,
                    Color.white.opacity(0.84),
                    Color.white.opacity(0.34),
                    .clear
                ],
                center: UnitPoint(x: 0.5, y: 0.78),
                startRadius: 26,
                endRadius: 150
            )

            LinearGradient(
                colors: [
                    .clear,
                    .clear,
                    Color.white.opacity(0.34),
                    Color.white
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .blur(radius: 10)
        .compositingGroup()
    }
}

private struct LoopingBackgroundVideoView: UIViewRepresentable {
    let resourceName: String
    let isPlaying: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(resourceName: resourceName)
    }

    func makeUIView(context: Context) -> PlayerContainerView {
        let view = PlayerContainerView()
        view.playerLayer.videoGravity = .resizeAspectFill
        view.playerLayer.player = context.coordinator.player
        context.coordinator.updatePlayback(isPlaying: isPlaying)
        return view
    }

    func updateUIView(_ uiView: PlayerContainerView, context: Context) {
        uiView.playerLayer.player = context.coordinator.player
        context.coordinator.updatePlayback(isPlaying: isPlaying)
    }

    static func dismantleUIView(_ uiView: PlayerContainerView, coordinator: Coordinator) {
        coordinator.player.pause()
        uiView.playerLayer.player = nil
    }

    final class Coordinator {
        let player = AVQueuePlayer()
        private var looper: AVPlayerLooper?

        init(resourceName: String) {
            player.isMuted = true
            player.actionAtItemEnd = .none

            guard let url = Bundle.main.url(forResource: resourceName, withExtension: "mp4") else { return }

            let asset = AVURLAsset(url: url)
            let item = AVPlayerItem(asset: asset)
            looper = AVPlayerLooper(player: player, templateItem: item)
        }

        func updatePlayback(isPlaying: Bool) {
            if isPlaying {
                player.play()
            } else {
                player.pause()
                player.seek(to: .zero)
            }
        }
    }
}

private final class PlayerContainerView: UIView {
    override static var layerClass: AnyClass { AVPlayerLayer.self }

    var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }
}

#Preview {
    FeaturedView()
        .environmentObject(AudioManager())
}

private extension View {
    @ViewBuilder
    func homeNavigationHidden() -> some View {
        #if os(iOS)
        self.navigationBarHidden(true)
        #else
        self
        #endif
    }
}
