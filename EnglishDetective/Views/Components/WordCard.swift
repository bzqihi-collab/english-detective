import SwiftUI

// MARK: - Word Card Component

struct WordCard: View {
    let word: Word
    var status: WordProficiency? = nil
    var onTap: (() -> Void)? = nil
    var size: CardSize = .normal

    enum CardSize {
        case small, normal
        var emojiFont: CGFloat { self == .small ? 28 : 36 }
        var padding: CGFloat { self == .small ? 10 : 14 }
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(word.emoji)
                .font(.system(size: size.emojiFont))

            Text(word.english)
                .font(DetectiveTypography.titleSmall)
                .foregroundColor(DetectiveColors.ink)

            if size == .normal {
                Text(word.phonetic)
                    .font(DetectiveTypography.label)
                    .foregroundColor(DetectiveColors.textMuted)
            }
        }
        .padding(size.padding)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: DetectiveRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: DetectiveRadius.medium)
                .stroke(borderColor, lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        .onTapGesture { onTap?() }
        .overlay(alignment: .topTrailing) {
            if let status = status {
                Circle()
                    .fill(status.color)
                    .frame(width: 22, height: 22)
                    .overlay(
                        Image(systemName: statusIcon(for: status))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .offset(x: 6, y: -6)
            }
        }
    }

    private var backgroundColor: Color {
        if status == .mastered {
            return DetectiveColors.paper
        }
        if status != nil {
            return DetectiveColors.accentLight
        }
        return DetectiveColors.paper
    }

    private var borderColor: Color {
        guard let status = status else { return DetectiveColors.border }
        return status.color
    }

    private func statusIcon(for proficiency: WordProficiency) -> String {
        switch proficiency {
        case .mastered: return "checkmark"
        case .weak: return "exclamationmark"
        case .forgotten: return "xmark"
        }
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 12) {
        WordCard(word: MockData.wordCat, status: .mastered)
        WordCard(word: MockData.wordDog, status: .weak)
        WordCard(word: MockData.wordBird, status: .forgotten)
        WordCard(word: MockData.wordFish)
    }
    .padding()
    .background(DetectiveColors.warmBackground)
}
