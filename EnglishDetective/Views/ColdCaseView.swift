import SwiftUI

// MARK: - Cold Case Archive (冷案档案室)

struct ColdCaseView: View {
    @EnvironmentObject var gameState: GameState

    var body: some View {
        ZStack {
            DetectiveColors.warmBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                HStack(alignment: .top, spacing: 14) {
                    mainContent
                    sidePanel
                }
                .padding(DetectiveSpacing.md)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            NavigationLink {
                MainOfficeView()
                    .navigationBarHidden(true)
            } label: {
                HStack(spacing: 4) {
                    Text("←")
                    Text("事务所")
                }
                .font(DetectiveTypography.bodySmall)
                .foregroundColor(DetectiveColors.accent)
            }

            Spacer()

            Text("📂 冷案档案室")
                .font(DetectiveTypography.titleSmall)
                .foregroundColor(DetectiveColors.ink)

            Spacer()

            Text("\(gameState.coldCaseWords.count)个待追查")
                .font(DetectiveTypography.bodySmall)
                .foregroundColor(DetectiveColors.ink)
        }
        .padding(.horizontal, DetectiveSpacing.md)
        .padding(.vertical, 10)
        .background(DetectiveColors.paper)
        .overlay(alignment: .bottom) {
            Divider().overlay(DetectiveColors.border)
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Unresolved cold cases
            Text("🧊 未结冷案 — 需要重新追查")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(DetectiveColors.ink)

            if gameState.coldCaseWords.isEmpty {
                emptyColdCaseState
            } else {
                HStack(spacing: 10) {
                    ForEach(gameState.coldCaseWords, id: \.word.id) { item in
                        coldCaseItemCard(item.word, proficiency: item.proficiency)
                    }
                }
            }

            // Resolved cases
            Text("✅ 已清理冷案")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(DetectiveColors.ink)
                .padding(.top, 12)

            if gameState.coldCaseWords.isEmpty {
                VStack(spacing: 8) {
                    Text("🎉")
                        .font(.largeTitle)
                    Text("太棒了！没有待追查的冷案")
                        .font(DetectiveTypography.body)
                        .foregroundColor(DetectiveColors.ink)
                    Text("继续保持！")
                        .font(DetectiveTypography.bodySmall)
                        .foregroundColor(DetectiveColors.textMuted)
                }
                .frame(maxWidth: .infinity)
                .padding(30)
                .cardStyle()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        StatusTag(text: "🐱 cat · 已掌握", style: .success)
                        StatusTag(text: "🐶 dog · 已掌握", style: .success)
                        StatusTag(text: "👀 eye · 已掌握", style: .success)
                        StatusTag(text: "👂 ear · 已掌握", style: .success)
                        StatusTag(text: "👃 nose · 已掌握", style: .success)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Side Panel

    private var sidePanel: some View {
        VStack(spacing: 8) {
            Text("🏃 本周越狱挑战")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(DetectiveColors.ink)
                .multilineTextAlignment(.center)

            Text("⏰")
                .font(.system(size: 40))

            Text("还剩 3 天")
                .font(DetectiveTypography.label)
                .foregroundColor(DetectiveColors.textMuted)

            Text("3个冷案词即将\"越狱\"\n一次性全部抓捕！")
                .font(DetectiveTypography.bodySmall)
                .foregroundColor(DetectiveColors.ink)
                .multilineTextAlignment(.center)

            StatusTag(text: "🎁 奖励翻倍", style: .warning)
        }
        .padding(14)
        .cardStyle()
        .frame(width: 180)
    }

    // MARK: - Cold Case Item Card

    private func coldCaseItemCard(_ word: Word, proficiency: WordProficiency) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(word.english)
                        .font(DetectiveTypography.titleSmall)
                        .foregroundColor(DetectiveColors.ink)

                    Text("\(word.phonetic) · \(word.chinese)")
                        .font(DetectiveTypography.label)
                        .foregroundColor(DetectiveColors.textMuted)

                    StatusTag(
                        text: "\(proficiency.emoji) \(proficiency.label)",
                        style: proficiency == .forgotten ? .danger : .warning
                    )
                    .padding(.top, 2)
                }

                Spacer()

                Text(word.emoji)
                    .font(.system(size: 32))
            }

            DetectiveButton(
                title: "追查",
                icon: "🔍",
                style: proficiency == .forgotten ? .accent : .secondary
            ) {
                // Tap to simulate review
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    var updated = gameState.coldCaseWords
                    if let idx = updated.firstIndex(where: { $0.word.id == word.id }) {
                        updated[idx] = (word, .mastered)
                    }
                    // Remove "mastered" items after brief display
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        gameState.coldCaseWords.removeAll { $0.word.id == word.id }
                    }
                }
            }
            .padding(.top, 4)
        }
        .padding(12)
        .cardStyle()
    }

    // MARK: - Empty State

    private var emptyColdCaseState: some View {
        VStack(spacing: 8) {
            Image(systemName: "tray.full")
                .font(.title)
                .foregroundColor(DetectiveColors.textMuted)
            Text("没有待追查的冷案")
                .font(DetectiveTypography.body)
                .foregroundColor(DetectiveColors.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(30)
        .cardStyle()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        let state = GameState()
        state.coldCaseWords = MockData.coldCaseSample
        return ColdCaseView()
            .environmentObject(state)
    }
}
