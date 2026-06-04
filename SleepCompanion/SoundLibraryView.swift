import SwiftUI

struct SoundLibraryView: View {
    @EnvironmentObject private var audioManager: AudioManager
    @State private var selectedCategory = "全部"
    @State private var selectedSound = SoundscapeItem.samples[0]

    private let categories = ["全部", "雷雨", "江湖", "课堂", "自然", "ASMR", "动物", "旋律", "脑波"]

    private var filteredSounds: [SoundscapeItem] {
        if selectedCategory == "全部" {
            return SoundscapeItem.samples
        }

        return SoundscapeItem.samples.filter { $0.category == selectedCategory }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScreenBackground()

                ScrollView {
                    VStack(spacing: 24) {
                        soundHero
                        soundGrid
                    }
                    .padding(.top, 18)
                    .padding(.bottom, 152)
                }

                categoryTabs
                    .padding(.bottom, 78)
            }
            .navigationTitle("声音")
            .sleepInlineNavigationTitle()
        }
    }

    private var soundHero: some View {
        VStack(spacing: 18) {
            Text("小睡眠")
                .font(.title3.weight(.medium))
                .foregroundStyle(.white.opacity(0.76))

            Image(systemName: selectedSound.icon)
                .font(.system(size: 78, weight: .thin))
                .foregroundStyle(Color.warmGold)
                .frame(height: 92)

            Text(selectedSound.title)
                .font(.system(size: 32, weight: .regular, design: .rounded))
                .foregroundStyle(.white)

            Button {
                audioManager.toggle(session: SampleData.session(for: .silent))
            } label: {
                Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(Color.nightInk)
                    .frame(width: 64, height: 64)
                    .background(Color.warmGold)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Text(audioManager.isPlaying ? audioManager.remainingTimeText : "30:00")
                .font(.title.weight(.light))
                .foregroundStyle(.white.opacity(0.84))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 26)
        .padding(.horizontal, 20)
    }

    private var soundGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 18), count: 4), spacing: 28) {
            ForEach(filteredSounds) { sound in
                Button {
                    selectedSound = sound
                } label: {
                    SoundscapeCell(sound: sound, isSelected: selectedSound.id == sound.id)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
    }

    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        Text(category)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(selectedCategory == category ? Color.nightInk : Color.white.opacity(0.72))
                            .padding(.horizontal, 14)
                            .frame(height: 36)
                            .background(selectedCategory == category ? Color.softBlue : Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 54)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)
        }
    }
}

struct SoundscapeCell: View {
    let sound: SoundscapeItem
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: sound.icon)
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(isSelected ? Color.nightInk : Color.white.opacity(0.58))
                .frame(width: 58, height: 58)
                .background(isSelected ? Color.warmGold : Color.white.opacity(0.06))
                .clipShape(Circle())

            Text(sound.title)
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(isSelected ? 0.92 : 0.66))
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SoundscapeItem: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let icon: String

    static let samples: [SoundscapeItem] = [
        SoundscapeItem(title: "红泥小炉", category: "全部", icon: "flame"),
        SoundscapeItem(title: "浪卷海贝", category: "自然", icon: "shell"),
        SoundscapeItem(title: "夜虫唧唧", category: "动物", icon: "moon.stars"),
        SoundscapeItem(title: "小卖部", category: "江湖", icon: "storefront"),
        SoundscapeItem(title: "凌雪藏锋", category: "旋律", icon: "snowflake"),
        SoundscapeItem(title: "凌雪密洞", category: "自然", icon: "mountain.2"),
        SoundscapeItem(title: "凌雪隐侠", category: "旋律", icon: "wind"),
        SoundscapeItem(title: "化学课堂", category: "课堂", icon: "flask"),
        SoundscapeItem(title: "英语课 2", category: "课堂", icon: "textformat"),
        SoundscapeItem(title: "空山飞鸟", category: "自然", icon: "bird"),
        SoundscapeItem(title: "雪落伞上", category: "自然", icon: "umbrella"),
        SoundscapeItem(title: "大漠风沙", category: "自然", icon: "triangle"),
        SoundscapeItem(title: "一碗面条", category: "ASMR", icon: "takeoutbag.and.cup.and.straw"),
        SoundscapeItem(title: "一包薯片", category: "ASMR", icon: "frying.pan"),
        SoundscapeItem(title: "一颗苹果", category: "ASMR", icon: "apple.logo"),
        SoundscapeItem(title: "一杯冰水", category: "ASMR", icon: "waterbottle")
    ]
}

#Preview {
    SoundLibraryView()
        .environmentObject(AudioManager())
}
