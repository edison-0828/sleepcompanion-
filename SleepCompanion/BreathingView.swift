import SwiftUI

struct BreathingView: View {
    @State private var isBreathing = false
    @State private var phase = "准备"

    var body: some View {
        NavigationStack {
            ZStack {
                ScreenBackground()

                VStack(spacing: 34) {
                    Spacer()

                    VStack(spacing: 10) {
                        Text("呼吸")
                            .font(.system(size: 34, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("跟着圆慢慢呼吸，不需要做得很标准。")
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.62))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 28)

                    ZStack {
                        Circle()
                            .fill(Color.softBlue.opacity(0.18))
                            .frame(width: 210, height: 210)
                            .scaleEffect(isBreathing ? 1.18 : 0.78)
                            .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: isBreathing)

                        Text(phase)
                            .font(.title2.weight(.medium))
                            .foregroundStyle(.white)
                    }
                    .frame(height: 260)

                    Button {
                        isBreathing.toggle()
                        phase = isBreathing ? "呼气" : "准备"
                    } label: {
                        Label(isBreathing ? "暂停" : "开始", systemImage: isBreathing ? "pause.fill" : "play.fill")
                            .font(.headline)
                            .foregroundStyle(Color.nightInk)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color.warmGold)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 28)

                    Spacer()
                }
            }
            .navigationTitle("呼吸")
            .sleepInlineNavigationTitle()
        }
    }
}

#Preview {
    BreathingView()
}
