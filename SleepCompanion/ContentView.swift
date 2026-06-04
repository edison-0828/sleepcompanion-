import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .sounds

    var body: some View {
        ZStack(alignment: .bottom) {
            selectedContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            BottomTabBar(selectedTab: $selectedTab)
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var selectedContent: some View {
        switch selectedTab {
        case .sounds:
            SoundLibraryView()
        case .sleepAid:
            SleepAidView()
        case .breathing:
            BreathingView()
        case .featured:
            FeaturedView()
        case .profile:
            SettingsView()
        }
    }
}

enum AppTab: String, CaseIterable, Identifiable {
    case sounds = "声音"
    case sleepAid = "助眠"
    case breathing = "呼吸"
    case featured = "精选"
    case profile = "我的"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .sounds: "cloud.rain"
        case .sleepAid: "leaf"
        case .breathing: "circle.circle"
        case .featured: "seal"
        case .profile: "person"
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
