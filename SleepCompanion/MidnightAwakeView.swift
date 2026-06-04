import SwiftUI

struct MidnightAwakeView: View {
    private let actions: [MidnightAction] = [
        MidnightAction(title: "重新安静下来", icon: "moon.zzz.fill", sessionType: .midnightAwake),
        MidnightAction(title: "放下焦虑", icon: "hand.raised.fill", sessionType: .anxiety),
        MidnightAction(title: "不说话，只放声音", icon: "speaker.wave.2.fill", sessionType: .silent)
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 26) {
                Spacer()

                VStack(alignment: .leading, spacing: 12) {
                    Text("醒来了，也没关系。")
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("先不要看时间。我们只让身体重新安静一点。")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.56))
                }

                VStack(spacing: 12) {
                    ForEach(actions) { action in
                        NavigationLink {
                            SessionPlayerView(session: SampleData.session(for: action.sessionType))
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: action.icon)
                                    .frame(width: 28)
                                    .foregroundStyle(Color.softBlue)

                                Text(action.title)
                                    .font(.headline)
                                    .foregroundStyle(.white.opacity(0.88))

                                Spacer()
                            }
                            .padding(18)
                            .background(Color.white.opacity(0.07))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer()
            }
            .padding(22)
        }
        .sleepHideTabBar()
        .sleepInlineNavigationTitle()
    }
}

struct MidnightAction: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let sessionType: SessionType
}

#Preview {
    NavigationStack {
        MidnightAwakeView()
            .environmentObject(AudioManager())
    }
}
