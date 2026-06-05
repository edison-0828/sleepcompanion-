import SwiftUI

struct FeaturedView: View {
    @EnvironmentObject private var audioManager: AudioManager
    @State private var selectedSceneID = HomeSoundScene.scenes[0].id
    @State private var isSceneTitleVisible = true

    private var selectedScene: HomeSoundScene {
        HomeSoundScene.scenes.first(where: { $0.id == selectedSceneID }) ?? HomeSoundScene.scenes[0]
    }

    private let weekdays = ["一", "二", "三", "四", "今", "六", "日"]

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let bottomBarReserve = geometry.safeAreaInsets.bottom + 106
                let sceneHeight = max(geometry.size.height * 0.66, geometry.size.height - bottomBarReserve - 156)

                VStack(spacing: 0) {
                    ZStack(alignment: .topLeading) {
                        sceneBackdrop
                            .frame(height: sceneHeight)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 0, style: .continuous)
                            )

                        VStack(alignment: .leading, spacing: 0) {
                            topSection
                            Spacer()
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, max(18, geometry.safeAreaInsets.top + 4))
                        .padding(.bottom, 24)
                    }

                    sceneFooter
                        .padding(.horizontal, 18)
                        .padding(.top, 22)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.09, green: 0.11, blue: 0.16),
                                    Color(red: 0.06, green: 0.08, blue: 0.12)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }

                .ignoresSafeArea(edges: .top)
                .padding(.bottom, bottomBarReserve)
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
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(greetingText)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    weekdayStrip
                }

                Spacer()

                sceneControls
                    .padding(.top, 10)
                    .padding(.trailing, 74)
            }

            Button {
            } label: {
                HStack(spacing: 10) {
                    Text("🎁")
                    Text("七天免费试用")
                        .font(.subheadline.weight(.medium))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .frame(height: 44)
                .background(.white.opacity(0.12))
                .overlay {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(.white.opacity(0.18), lineWidth: 1)
                }
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    private var weekdayStrip: some View {
        HStack(spacing: 12) {
            ForEach(Array(weekdays.enumerated()), id: \.offset) { index, item in
                Text(item)
                    .font(.system(size: 18, weight: index == 4 ? .bold : .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(index == 4 ? 0.96 : 0.48))
            }
        }
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
        .background(.white.opacity(0.12))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.22), lineWidth: 1)
        }
        .clipShape(Capsule())
    }

    private var sceneFooter: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(selectedScene.title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .opacity(isSceneTitleVisible ? 1 : 0)
                .frame(height: 40, alignment: .leading)
                .animation(.easeOut(duration: 0.28), value: isSceneTitleVisible)

            VStack(alignment: .leading, spacing: 6) {
                Text(timeText(selectedScene))
                    .font(.system(size: 40, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }

            HStack(alignment: .center) {
                HStack(spacing: 8) {
                    ForEach(Array(HomeSoundScene.scenes.enumerated()), id: \.element.id) { index, scene in
                        Capsule()
                            .fill(scene.id == selectedSceneID ? .white : .white.opacity(0.26))
                            .frame(width: scene.id == selectedSceneID ? 22 : 8, height: 8)
                            .animation(.spring(response: 0.28, dampingFraction: 0.8), value: selectedSceneID)
                    }
                }

                Spacer()

                Text(sceneStatusText)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))
            }
        }
        .padding(20)
        .background(.white.opacity(0.06))
        .overlay {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }

    private var sceneBackdrop: some View {
        ZStack {
            ForEach(HomeSoundScene.scenes) { scene in
                Image(scene.imageName)
                    .resizable()
                    .scaledToFill()
                    .opacity(scene.id == selectedSceneID ? 1 : 0)
                    .animation(.easeInOut(duration: 0.45), value: selectedSceneID)
            }

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.08),
                                Color.black.opacity(0.02),
                                Color.black.opacity(0.12),
                                Color.black.opacity(0.30)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 330)
                    .overlay {
                        WaterTexture(color: .white.opacity(0.16))
                            .opacity(0.70)
                    }
            }

            LinearGradient(
                colors: [
                    .white.opacity(0.08),
                    .clear,
                    Color.black.opacity(0.42)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .animation(.easeInOut(duration: 0.38), value: selectedSceneID)
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 5 && hour < 12 ? "早上好" : "晚上好"
    }

    private func timeText(_ scene: HomeSoundScene) -> String {
        audioManager.activeSession?.id == scene.session.id ? audioManager.remainingTimeText : scene.defaultTime
    }

    private var sceneStatusText: String {
        audioManager.isPlaying && audioManager.activeSession?.id == selectedScene.session.id ? "轻点暂停" : "轻点播放"
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

    private func revealSceneTitleTemporarily() {
        let currentSceneID = selectedSceneID
        isSceneTitleVisible = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            guard selectedSceneID == currentSceneID else { return }
            withAnimation(.easeOut(duration: 0.3)) {
                isSceneTitleVisible = false
            }
        }
    }
}

private struct WaterTexture: View {
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<5, id: \.self) { index in
                    Path { path in
                        let width = geometry.size.width
                        let y = 34 + CGFloat(index) * 50

                        path.move(to: CGPoint(x: 0, y: y))

                        for step in stride(from: 0, through: width + 40, by: 40) {
                            let x = step
                            let wave = sin((x / width) * .pi * 2 + CGFloat(index)) * 10
                            path.addLine(to: CGPoint(x: x, y: y + wave))
                        }
                    }
                    .stroke(color.opacity(0.18), lineWidth: index == 0 ? 2 : 1.2)
                    .blur(radius: index == 0 ? 0.5 : 1.4)
                }
            }
        }
    }
}

private struct HomeSoundScene: Identifiable {
    let id = UUID()
    let title: String
    let defaultTime: String
    let imageName: String
    let session: CompanionSession

    static let scenes: [HomeSoundScene] = [
        HomeSoundScene(
            title: "篝火",
            defaultTime: "45:00",
            imageName: "HomeCampfire",
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
