import SwiftUI

struct CompanionView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                ScreenBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("陪伴")
                            .font(.system(size: 30, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.top, 12)

                        Text("这里放你最核心的睡眠陪伴流程。第一版先保持少而稳。")
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.66))

                        ForEach(SampleData.sessions) { session in
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
            .navigationTitle("陪伴")
            .sleepInlineNavigationTitle()
        }
    }
}

struct SessionCard: View {
    let session: CompanionSession

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(session.type.rawValue)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.warmGold)

                    Text(session.title)
                        .font(.headline)
                        .foregroundStyle(.white)
                }

                Spacer()

                Image(systemName: "play.fill")
                    .font(.subheadline)
                    .foregroundStyle(Color.nightInk)
                    .frame(width: 34, height: 34)
                    .background(Color.warmGold)
                    .clipShape(Circle())
            }

            Text(session.subtitle)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.66))
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 16) {
                Label("\(session.durationMinutes) 分钟", systemImage: "clock")
                Label(session.soundscape, systemImage: "speaker.wave.2.fill")
            }
            .font(.caption)
            .foregroundStyle(.white.opacity(0.54))
        }
        .padding(16)
        .background(Color.mistPanel)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

#Preview {
    CompanionView()
}
