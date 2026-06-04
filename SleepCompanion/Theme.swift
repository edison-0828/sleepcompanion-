import SwiftUI

extension Color {
    static let nightInk = Color(red: 0.06, green: 0.07, blue: 0.10)
    static let deepNight = Color(red: 0.10, green: 0.12, blue: 0.17)
    static let mistPanel = Color.white.opacity(0.08)
    static let warmGold = Color(red: 0.93, green: 0.74, blue: 0.45)
    static let softBlue = Color(red: 0.45, green: 0.63, blue: 0.77)
    static let sleepGreen = Color(red: 0.42, green: 0.66, blue: 0.55)
}

struct ScreenBackground: View {
    var body: some View {
        LinearGradient(
            colors: [.nightInk, .deepNight, Color(red: 0.07, green: 0.10, blue: 0.12)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct SectionTitle: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(.white.opacity(0.86))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension View {
    @ViewBuilder
    func sleepInlineNavigationTitle() -> some View {
        #if os(iOS)
        self.navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }

    @ViewBuilder
    func sleepHideTabBar() -> some View {
        #if os(iOS)
        self.toolbar(.hidden, for: .tabBar)
        #else
        self
        #endif
    }
}
