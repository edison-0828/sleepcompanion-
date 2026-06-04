import Foundation

enum SleepState: String, CaseIterable, Identifiable {
    case anxious = "有点焦虑"
    case thoughts = "脑子停不下来"
    case tired = "身体很累"
    case quiet = "只想安静一会儿"
    case awake = "半夜醒了"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .anxious: "cloud.moon.fill"
        case .thoughts: "scribble.variable"
        case .tired: "bed.double.fill"
        case .quiet: "leaf.fill"
        case .awake: "moon.zzz.fill"
        }
    }

    var sessionType: SessionType {
        switch self {
        case .anxious: .anxiety
        case .thoughts: .mindUnload
        case .tired: .sleepOnset
        case .quiet: .silent
        case .awake: .midnightAwake
        }
    }
}

enum SessionType: String {
    case sleepOnset = "入睡陪伴"
    case anxiety = "焦虑陪伴"
    case midnightAwake = "夜间醒来"
    case silent = "无语言陪伴"
    case mindUnload = "思绪放下"
}

struct CompanionSession: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let type: SessionType
    let durationMinutes: Int
    let soundscape: String
    let stages: [SessionStage]
}

struct SessionStage: Identifiable {
    let id = UUID()
    let title: String
    let minutes: Int
    let note: String
}

struct SleepCheckIn: Identifiable {
    let id = UUID()
    let title: String
    let value: String
}

enum SampleData {
    static let sessions: [CompanionSession] = [
        CompanionSession(
            title: "慢慢进入夜晚",
            subtitle: "适合睡前躺下后开始，不追求立刻睡着。",
            type: .sleepOnset,
            durationMinutes: 30,
            soundscape: "细雨",
            stages: [
                SessionStage(title: "安顿下来", minutes: 3, note: "把注意力从今天带回身体。"),
                SessionStage(title: "放慢呼吸", minutes: 7, note: "用更长的呼气降低紧绷感。"),
                SessionStage(title: "身体扫描", minutes: 15, note: "从额头到脚趾逐步放松。"),
                SessionStage(title: "只留声音", minutes: 5, note: "人声淡出，背景音继续。")
            ]
        ),
        CompanionSession(
            title: "今晚不用证明什么",
            subtitle: "适合越想睡越紧张的时候。",
            type: .anxiety,
            durationMinutes: 20,
            soundscape: "低频暖噪",
            stages: [
                SessionStage(title: "允许当下", minutes: 4, note: "先停止和清醒对抗。"),
                SessionStage(title: "安全感提示", minutes: 6, note: "用稳定语句降低失控感。"),
                SessionStage(title: "轻呼吸", minutes: 6, note: "不用刻意，只是跟随。"),
                SessionStage(title: "安静陪伴", minutes: 4, note: "语言减少，身体继续休息。")
            ]
        ),
        CompanionSession(
            title: "半夜醒来也没关系",
            subtitle: "屏幕更暗，选择更少，帮你重新安静下来。",
            type: .midnightAwake,
            durationMinutes: 15,
            soundscape: "远海",
            stages: [
                SessionStage(title: "不看时间", minutes: 2, note: "先避开时间压力。"),
                SessionStage(title: "放下判断", minutes: 5, note: "醒来不是失败。"),
                SessionStage(title: "重新躺回身体", minutes: 5, note: "感受床的支撑。"),
                SessionStage(title: "纯背景音", minutes: 3, note: "留下稳定声音。")
            ]
        ),
        CompanionSession(
            title: "把事情放到明天",
            subtitle: "适合脑子停不下来时，先把思绪从床上移开。",
            type: .mindUnload,
            durationMinutes: 12,
            soundscape: "温柔风声",
            stages: [
                SessionStage(title: "写下来", minutes: 3, note: "只记录，不解决。"),
                SessionStage(title: "分一分类", minutes: 3, note: "明天处理、无法控制、已经完成。"),
                SessionStage(title: "收尾语", minutes: 2, note: "告诉大脑这件事已被保存。"),
                SessionStage(title: "回到身体", minutes: 4, note: "把注意力放回呼吸和床的支撑。")
            ]
        ),
        CompanionSession(
            title: "不说话，只陪着",
            subtitle: "适合不想听引导，只想有一个稳定背景的时候。",
            type: .silent,
            durationMinutes: 45,
            soundscape: "棕噪音",
            stages: [
                SessionStage(title: "背景音", minutes: 45, note: "没有人声，没有任务，只保留稳定声音。")
            ]
        )
    ]

    static func session(for type: SessionType) -> CompanionSession {
        sessions.first { $0.type == type } ?? sessions[0]
    }

    static let checkIns: [SleepCheckIn] = [
        SleepCheckIn(title: "昨晚整体感觉", value: "一般"),
        SleepCheckIn(title: "入睡前状态", value: "思绪很多"),
        SleepCheckIn(title: "陪伴是否有帮助", value: "有一点")
    ]
}
