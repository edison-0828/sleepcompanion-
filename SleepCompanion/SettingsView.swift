import SwiftUI

struct SettingsView: View {
    @AppStorage("backgroundVolume") private var backgroundVolume = 0.7
    @AppStorage("voiceVolume") private var voiceVolume = 0.55
    @AppStorage("nightBrightness") private var nightBrightness = 0.25
    @AppStorage("autoFadeOut") private var autoFadeOut = true

    var body: some View {
        NavigationStack {
            ZStack {
                ScreenBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        Text("我的")
                            .font(.system(size: 30, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.top, 12)

                        preferences
                        journalEntry
                        privacyNote
                    }
                    .padding(20)
                }
            }
            .navigationTitle("我的")
            .sleepInlineNavigationTitle()
        }
    }

    private var preferences: some View {
        VStack(alignment: .leading, spacing: 18) {
            SectionTitle(title: "陪伴偏好")

            VStack(alignment: .leading, spacing: 8) {
                Label("背景音", systemImage: "speaker.wave.2.fill")
                Slider(value: $backgroundVolume, in: 0...1)
            }

            VStack(alignment: .leading, spacing: 8) {
                Label("人声", systemImage: "person.wave.2.fill")
                Slider(value: $voiceVolume, in: 0...1)
            }

            VStack(alignment: .leading, spacing: 8) {
                Label("夜间亮度", systemImage: "sun.min.fill")
                Slider(value: $nightBrightness, in: 0.05...0.6)
            }

            Toggle(isOn: $autoFadeOut) {
                Label("结束时自动渐弱", systemImage: "waveform.path.ecg")
            }
        }
        .font(.subheadline)
        .foregroundStyle(.white.opacity(0.82))
        .padding(16)
        .background(Color.mistPanel)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var privacyNote: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle(title: "隐私与定位")

            Text("第一版建议所有记录只保存在本机。App 提供睡前放松和休息陪伴，不替代专业医疗建议。")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.62))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color.mistPanel)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var journalEntry: some View {
        NavigationLink {
            JournalView()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "note.text")
                    .font(.title3)
                    .foregroundStyle(Color.warmGold)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 4) {
                    Text("早晨记录")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text("保存昨晚的休息感和陪伴反馈。")
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

#Preview {
    SettingsView()
}
