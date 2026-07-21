import Foundation

// MARK: - Detective Case Model

struct DetectiveCase: Identifiable, Equatable {
    let id = UUID()
    let caseNumber: Int
    let title: String
    let subtitle: String
    let briefing: String
    let words: [Word]
    let sentences: [String]
    let sceneEmojis: [String]
    var isUnlocked: Bool = true

    static func == (lhs: DetectiveCase, rhs: DetectiveCase) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Case Step (Flow Navigation)

enum CaseStep: String, CaseIterable, Equatable {
    case briefing
    case investigation
    case interrogation
    case report
    case celebration

    var stepNumber: Int {
        switch self {
        case .briefing: return 1
        case .investigation: return 2
        case .interrogation: return 3
        case .report: return 4
        case .celebration: return 5
        }
    }

    var title: String {
        switch self {
        case .briefing: return "接案"
        case .investigation: return "搜证"
        case .interrogation: return "审讯"
        case .report: return "结案报告"
        case .celebration: return "庆祝"
        }
    }

    var icon: String {
        switch self {
        case .briefing: return "📋"
        case .investigation: return "🔍"
        case .interrogation: return "🎤"
        case .report: return "✍️"
        case .celebration: return "🏆"
        }
    }
}
