import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .home
    @State private var isShowingProfile = false

    var body: some View {
        ZStack(alignment: .bottom) {
            selectedContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            profileButton

            BottomTabBar(selectedTab: $selectedTab)
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $isShowingProfile) {
            SettingsView()
        }
    }

    @ViewBuilder
    private var selectedContent: some View {
        switch selectedTab {
        case .home:
            FeaturedView()
        case .sleepAid:
            SleepAidView()
        case .sounds:
            SoundLibraryView()
        case .breathing:
            BreathingView()
        }
    }

    private var profileButton: some View {
        VStack {
            HStack {
                Spacer()

                Button {
                    isShowingProfile = true
                } label: {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.88, green: 0.76, blue: 0.75),
                                    Color(red: 0.73, green: 0.77, blue: 0.96),
                                    Color(red: 0.89, green: 0.63, blue: 0.56)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay {
                            Circle()
                                .stroke(.white.opacity(0.34), lineWidth: 1.2)
                        }
                        .frame(width: 52, height: 52)
                        .blur(radius: 0.2)
                        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 6)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 18)
            }
            .padding(.top, 12)

            Spacer()
        }
    }
}

enum AppTab: String, CaseIterable, Identifiable {
    case home = "首页"
    case sleepAid = "睡眠"
    case breathing = "冥想"
    case sounds = "声音"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .home: "square.leadingthird.inset.filled"
        case .sleepAid: "moon.fill"
        case .sounds: "circle.fill"
        case .breathing: "triangle.fill"
        }
    }
}

struct BottomTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 8) {
            ForEach(AppTab.allCases) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 18, weight: .semibold))

                        Text(tab.rawValue)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(selectedTab == tab ? Color.white.opacity(0.98) : Color.black.opacity(0.62))
                    .frame(maxWidth: .infinity)
                    .frame(height: 72)
                    .background {
                        if selectedTab == tab {
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(Color.black.opacity(0.16))
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(.white.opacity(0.58))
        .overlay {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(.white.opacity(0.52), lineWidth: 1.2)
        }
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
        .padding(.horizontal, 18)
        .padding(.bottom, 14)
    }
}

#Preview {
    ContentView()
        .environmentObject(AudioManager())
}
