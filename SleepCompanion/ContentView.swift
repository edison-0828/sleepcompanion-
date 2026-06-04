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
                    Image(systemName: "person.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.nightInk)
                        .frame(width: 38, height: 38)
                        .background(Color.warmGold)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.22), radius: 10, x: 0, y: 6)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 18)
            }
            .padding(.top, 10)

            Spacer()
        }
    }
}

enum AppTab: String, CaseIterable, Identifiable {
    case home = "首页"
    case sleepAid = "睡眠"
    case sounds = "声音"
    case breathing = "呼吸"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .home: "house"
        case .sleepAid: "leaf"
        case .sounds: "cloud.rain"
        case .breathing: "circle.circle"
        }
    }
}

struct BottomTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack {
            ForEach(AppTab.allCases) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 22, weight: .regular))

                        Text(tab.rawValue)
                            .font(.caption.weight(.medium))
                    }
                    .foregroundStyle(selectedTab == tab ? Color.softBlue : Color.white.opacity(0.56))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AudioManager())
}
