import SwiftUI

struct JournalView: View {
    @AppStorage("journalFeeling") private var savedFeeling = "一般"
    @AppStorage("journalBeforeSleep") private var savedBeforeSleep = "思绪很多"
    @AppStorage("journalHelpfulness") private var savedHelpfulness = "有一点"
    @AppStorage("journalSavedDate") private var savedDate = ""

    @State private var selectedFeeling = "一般"
    @State private var selectedBeforeSleep = "思绪很多"
    @State private var selectedHelpfulness = "有一点"
    @State private var didSave = false

    private let feelings = ["还不错", "一般", "有点困难", "很难"]
    private let beforeSleepStates = ["平静", "焦虑", "思绪很多", "身体不舒服"]
    private let helpfulnessOptions = ["有帮助", "有一点", "没感觉", "不适合"]

    var body: some View {
        NavigationStack {
            ZStack {
                ScreenBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        Text("记录")
                            .font(.system(size: 30, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.top, 12)

                        morningCheckIn
                        recentTrend
                    }
                    .padding(20)
                }
            }
            .navigationTitle("记录")
            .sleepInlineNavigationTitle()
        }
        .onAppear {
            selectedFeeling = savedFeeling
            selectedBeforeSleep = savedBeforeSleep
            selectedHelpfulness = savedHelpfulness
        }
    }

    private var morningCheckIn: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle(title: "早晨轻记录")

            JournalQuestion(
                title: "昨晚整体感觉？",
                options: feelings,
                selection: $selectedFeeling
            )

            JournalQuestion(
                title: "入睡前状态？",
                options: beforeSleepStates,
                selection: $selectedBeforeSleep
            )

            JournalQuestion(
                title: "陪伴是否有帮助？",
                options: helpfulnessOptions,
                selection: $selectedHelpfulness
            )

            Button {
                saveEntry()
            } label: {
                Label(didSave ? "已保存" : "保存今天的感觉", systemImage: didSave ? "checkmark.circle.fill" : "checkmark")
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

    private var recentTrend: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "最近的休息感")

            if !savedDate.isEmpty {
                Text(savedDate)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.46))
            }

            ForEach(savedCheckIns) { item in
                HStack {
                    Text(item.title)
                        .foregroundStyle(.white.opacity(0.72))

                    Spacer()

                    Text(item.value)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                .font(.subheadline)
                .padding(.vertical, 8)
            }
        }
        .padding(16)
        .background(Color.mistPanel)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var savedCheckIns: [SleepCheckIn] {
        [
            SleepCheckIn(title: "昨晚整体感觉", value: savedFeeling),
            SleepCheckIn(title: "入睡前状态", value: savedBeforeSleep),
            SleepCheckIn(title: "陪伴是否有帮助", value: savedHelpfulness)
        ]
    }

    private func saveEntry() {
        savedFeeling = selectedFeeling
        savedBeforeSleep = selectedBeforeSleep
        savedHelpfulness = selectedHelpfulness
        savedDate = Date.now.formatted(date: .abbreviated, time: .omitted)

        withAnimation(.easeInOut(duration: 0.2)) {
            didSave = true
        }
    }
}

struct JournalQuestion: View {
    let title: String
    let options: [String]
    @Binding var selection: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            Picker(title, selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

#Preview {
    JournalView()
}
