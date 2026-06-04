import SwiftUI

struct MindUnloadView: View {
    @AppStorage("lastMindUnloadText") private var savedText = ""
    @AppStorage("lastMindUnloadCategory") private var savedCategory = "明天处理"
    @AppStorage("lastMindUnloadDate") private var savedDate = ""

    @State private var thoughtText = ""
    @State private var category = "明天处理"
    @State private var didSave = false

    private let categories = ["明天处理", "无法控制", "已经完成"]
    private let followUpSession = SampleData.session(for: .mindUnload)

    var body: some View {
        ZStack {
            ScreenBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    unloadEditor
                    closingPhrase
                    continueButton
                }
                .padding(20)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("思绪放下")
        .sleepInlineNavigationTitle()
        .onAppear {
            thoughtText = savedText
            category = savedCategory
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("先把它从脑子里拿出来。")
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            Text("这里只负责保存，不需要现在解决。")
                .font(.body)
                .foregroundStyle(.white.opacity(0.64))
        }
        .padding(.top, 12)
    }

    private var unloadEditor: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle(title: "睡前卸载")

            Picker("分类", selection: $category) {
                ForEach(categories, id: \.self) { item in
                    Text(item).tag(item)
                }
            }
            .pickerStyle(.segmented)

            TextEditor(text: $thoughtText)
                .frame(minHeight: 150)
                .padding(10)
                .foregroundStyle(.white)
                .scrollContentBackground(.hidden)
                .background(Color.white.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(alignment: .topLeading) {
                    if thoughtText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text("写下一个放不下的念头...")
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.36))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 18)
                    }
                }

            Button {
                saveThought()
            } label: {
                Label(didSave ? "已经放下" : "保存到明天", systemImage: didSave ? "checkmark.circle.fill" : "tray.and.arrow.down.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.warmGold)
            .foregroundStyle(Color.nightInk)
        }
        .padding(16)
        .background(Color.mistPanel)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var closingPhrase: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle(title: "收尾语")

            Text("这件事已经被保存。今晚不用继续解决它，我们先让身体休息。")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.88))
                .fixedSize(horizontal: false, vertical: true)

            if !savedDate.isEmpty {
                Text("上次保存：\(savedDate) · \(savedCategory)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.46))
            }
        }
        .padding(16)
        .background(Color.mistPanel)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var continueButton: some View {
        NavigationLink {
            SessionPlayerView(session: followUpSession)
        } label: {
            HStack {
                Label("继续放松陪伴", systemImage: "play.circle.fill")
                    .font(.headline)
                Spacer()
                Text("\(followUpSession.durationMinutes) 分钟")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.58))
            }
            .foregroundStyle(.white)
            .padding(16)
            .background(Color.mistPanel)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func saveThought() {
        savedText = thoughtText
        savedCategory = category
        savedDate = Date.now.formatted(date: .abbreviated, time: .shortened)

        withAnimation(.easeInOut(duration: 0.2)) {
            didSave = true
        }
    }
}

#Preview {
    NavigationStack {
        MindUnloadView()
            .environmentObject(AudioManager())
    }
}
