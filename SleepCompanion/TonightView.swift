import SwiftUI

struct TonightView: View {
    @State private var selectedState: SleepState = .thoughts

    private var recommendedSession: CompanionSession {
        SampleData.session(for: selectedState.sessionType)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScreenBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        header
                        statePicker
                        recommendation
                        midnightEntry
                    }
                    .padding(20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("今晚")
            .sleepInlineNavigationTitle()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("今晚，我们先不用急着睡着。")
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            Text("选择现在的状态，我会给你一个更少打扰的陪伴流程。")
                .font(.body)
                .foregroundStyle(.white.opacity(0.66))
        }
        .padding(.top, 12)
    }

    private var statePicker: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "现在的你")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(SleepState.allCases) { state in
                    StateOptionButton(state: state, isSelected: selectedState == state) {
                        selectedState = state
                    }
                }
            }
        }
    }

    private var recommendation: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle(title: "推荐陪伴")

            NavigationLink {
                if selectedState == .thoughts {
                    MindUnloadView()
                } else {
                    SessionPlayerView(session: recommendedSession)
                }
            } label: {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(recommendedSession.title)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.white)

                            Text(recommendedSession.subtitle)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.68))
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer()

                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 38))
                            .foregroundStyle(Color.warmGold)
                    }

                    HStack(spacing: 16) {
                        Label("\(recommendedSession.durationMinutes) 分钟", systemImage: "timer")
                        Label(recommendedSession.soundscape, systemImage: "waveform")
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.62))
                }
                .padding(18)
                .background(Color.mistPanel)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }

    private var midnightEntry: some View {
        NavigationLink {
            MidnightAwakeView()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "moon.zzz.fill")
                    .font(.title2)
                    .foregroundStyle(Color.softBlue)

                VStack(alignment: .leading, spacing: 4) {
                    Text("半夜醒来模式")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text("更暗、更少选择，不显示睡眠压力。")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.62))
                }

                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.white.opacity(0.42))
            }
            .padding(16)
            .background(Color.mistPanel)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct StateOptionButton: View {
    let state: SleepState
    let isSelected: Bool
    let action: () -> Void

    private var textColor: Color {
        isSelected ? Color.nightInk : Color.white.opacity(0.88)
    }

    private var iconColor: Color {
        isSelected ? Color.nightInk : Color.warmGold
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: state.iconName)
                    .font(.title3)
                    .foregroundStyle(iconColor)

                Text(state.rawValue)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(textColor)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
            }
            .frame(maxWidth: .infinity, minHeight: 86, alignment: .leading)
            .padding(14)
            .background(isSelected ? Color.warmGold : Color.mistPanel)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TonightView()
}
