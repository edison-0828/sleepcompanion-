import SwiftUI

struct FeaturedView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                ScreenBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("精选")
                            .font(.system(size: 30, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.top, 12)

                        Text("把最常用的陪伴流程放在这里，减少睡前选择。")
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.66))

                        ForEach(SampleData.sessions.prefix(4)) { session in
                            NavigationLink {
                                SessionPlayerView(session: session)
                            } label: {
                                SessionCard(session: session)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("精选")
            .sleepInlineNavigationTitle()
        }
    }
}

#Preview {
    FeaturedView()
        .environmentObject(AudioManager())
}
