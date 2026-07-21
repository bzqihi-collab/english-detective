import Foundation
import SwiftUI

// MARK: - Word Model

struct Word: Identifiable, Equatable, Hashable {
    let id = UUID()
    let english: String
    let phonetic: String
    let chinese: String
    let emoji: String
    let exampleSentence: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Word Proficiency

enum WordProficiency: CaseIterable {
    case mastered
    case weak
    case forgotten

    var label: String {
        switch self {
        case .mastered: return "已掌握"
        case .weak: return "需复习"
        case .forgotten: return "高危"
        }
    }

    var color: Color {
        switch self {
        case .mastered: return DetectiveColors.success
        case .weak: return DetectiveColors.accent
        case .forgotten: return DetectiveColors.danger
        }
    }

    var emoji: String {
        switch self {
        case .mastered: return "✅"
        case .weak: return "🟡"
        case .forgotten: return "🔴"
        }
    }
}
