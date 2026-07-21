import SwiftUI

// MARK: - Status Tag Component

struct StatusTag: View {
    enum TagStyle {
        case success, warning, danger, neutral

        var bgColor: Color {
            switch self {
            case .success: return Color(hex: "F0FDF4")
            case .warning: return DetectiveColors.accentLight
            case .danger: return Color(hex: "FEF2F2")
            case .neutral: return DetectiveColors.muted
            }
        }

        var fgColor: Color {
            switch self {
            case .success: return Color(hex: "3F6212")
            case .warning: return Color(hex: "92400E")
            case .danger: return Color(hex: "991B1B")
            case .neutral: return DetectiveColors.textSecondary
            }
        }
    }

    let text: String
    var style: TagStyle = .neutral

    var body: some View {
        Text(text)
            .font(DetectiveTypography.label)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(style.bgColor)
            .foregroundColor(style.fgColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 8) {
        StatusTag(text: "🐱 cat", style: .success)
        StatusTag(text: "🟡 mouth", style: .warning)
        StatusTag(text: "🔴 bird · 3天", style: .danger)
        StatusTag(text: "📚 PEP三上", style: .neutral)
    }
    .padding()
    .background(DetectiveColors.warmBackground)
}
