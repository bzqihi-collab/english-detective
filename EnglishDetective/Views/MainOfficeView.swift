import SwiftUI

// MARK: - Main Office (Home Screen)

struct MainOfficeView: View {
    @EnvironmentObject var gameState: GameState
    @State private var showCaseFlow = false
    @State private var showColdCase = false

    var body: some View {
        ZStack {
            DetectiveColors.warmBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                HStack(alignment: .top, spacing: DetectiveSpacing.md) {
                    leftPanel
                    centerPanel
                    rightPanel
                }
                .padding(DetectiveSpacing.md)
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showCaseFlow) {
            CaseFlowView()
        }
        .navigationDestination(isPresented: $showColdCase) {
            ColdCaseView()
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            HStack(spacing: 8) {
                Text("🔍")
                    .font(.title3)
                Text("英语侦探社")
                    .font(DetectiveTypography.titleSmall)
                    .foregroundColor(DetectiveColors.ink)
            }

            Spacer()

            HStack(spacing: 8) {
                StatusTag(text: "📚 PEP三上 ▾", style: .neutral)
                StatusTag(text: "⭐ \(gameState.coins)", style: .warning)
                Text("🦊")
                    .font(.title2)
            }
        }
        .padding(.horizontal, DetectiveSpacing.md)
        .padding(.vertical, 10)
        .background(DetectiveColors.paper)
        .overlay(alignment: .bottom) {
            Divider().overlay(DetectiveColors.border)
        }
    }

    // MARK: - Left Panel (Character + Navigation)

    private var leftPanel: some View {
        VStack(spacing: DetectiveSpacing.sm) {
            characterCard
            navigationButtons
        }
        .frame(width: 200)
    }

    private var characterCard: some View {
        VStack(spacing: 6) {
            Text("🦊")
                .font(.system(size: 44))
            Text("福克斯探长")
                .font(DetectiveTypography.titleSmall)
                .foregroundColor(DetectiveColors.ink)
            Text("你的导师")
                .font(DetectiveTypography.label)
                .foregroundColor(DetectiveColors.textMuted)

            StatusTag(text: "🔰 \(gameState.detectiveRank)", style: .neutral)
                .padding(.top, 2)

            ProgressBar(
                progress: gameState.experienceProgress,
                color: DetectiveColors.accent
            )
            .frame(width: 120)
            .padding(.top, 2)

            Text("\(gameState.experience)/\(gameState.maxExperience)")
                .font(.system(size: 9))
                .foregroundColor(DetectiveColors.textMuted)
        }
        .padding(DetectiveSpacing.md)
        .cardStyle()
    }

    private var navigationButtons: some View {
        VStack(spacing: 6) {
            DetectiveButton(
                title: "受理新案件",
                icon: "📁",
                style: .primary
            ) {
                gameState.startCase(MockData.unit4Case)
                showCaseFlow = true
            }

            DetectiveButton(
                title: "冷案档案室",
                icon: "📂",
                style: .secondary
            ) {
                gameState.coldCaseWords = MockData.coldCaseSample
                showColdCase = true
            }

            DetectiveButton(
                title: "徽章收藏册",
                icon: "🏆",
                style: .secondary
            ) {}

            DetectiveButton(
                title: "设置",
                icon: "⚙️",
                style: .secondary
            ) {}
        }
    }

    // MARK: - Center Panel (Tasks + Cases)

    private var centerPanel: some View {
        VStack(spacing: DetectiveSpacing.sm) {
            todayTasksCard
            caseCardsRow
        }
    }

    private var todayTasksCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("📋 今日任务")
                .font(DetectiveTypography.titleSmall)
                .foregroundColor(DetectiveColors.ink)

            taskRow(
                color: DetectiveColors.success,
                label: "学习新单词",
                done: gameState.todayNewWordsDone,
                total: gameState.todayNewWordsTotal
            )

            taskRow(
                color: DetectiveColors.success,
                label: "复习冷案",
                done: gameState.todayColdReviewDone,
                total: gameState.todayColdReviewTotal
            )

            taskRow(
                color: DetectiveColors.accent,
                label: "跟读句子",
                done: gameState.todayReadSentencesDone,
                total: gameState.todayReadSentencesTotal,
                highlight: true
            )
        }
        .padding(DetectiveSpacing.md)
        .cardStyle()
    }

    private func taskRow(
        color: Color,
        label: String,
        done: Int,
        total: Int,
        highlight: Bool = false
    ) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)

            Text(label)
                .font(DetectiveTypography.bodySmall)
                .foregroundColor(DetectiveColors.ink)

            Text("\(done)/\(total)")
                .font(DetectiveTypography.bodySmall)
                .fontWeight(.bold)
                .foregroundColor(DetectiveColors.ink)

            Spacer()

            ProgressBar(
                progress: Double(done) / Double(max(total, 1)),
                color: color
            )
            .frame(width: 80)
        }
        .padding(8)
        .background(highlight ? DetectiveColors.accentLight : DetectiveColors.muted)
        .clipShape(RoundedRectangle(cornerRadius: DetectiveRadius.small))
        .overlay(
            highlight
            ? RoundedRectangle(cornerRadius: DetectiveRadius.small)
                .stroke(Color(hex: "FDE68A"), lineWidth: 1)
            : nil
        )
    }

    private var caseCardsRow: some View {
        HStack(spacing: DetectiveSpacing.sm) {
            activeCaseCard
            lockedCaseCard
        }
    }

    private var activeCaseCard: some View {
        Button {
            gameState.startCase(MockData.unit4Case)
            showCaseFlow = true
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text("进行中")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(DetectiveColors.accent)
                    .clipShape(
                        UnevenRoundedRectangle(
                            bottomLeadingRadius: 8,
                            bottomTrailingRadius: 8
                        )
                    )

                Spacer().frame(height: 8)

                Text("CASE #004")
                    .font(DetectiveTypography.label)
                    .foregroundColor(DetectiveColors.textMuted)

                Text("失踪的动物园动物")
                    .font(DetectiveTypography.titleSmall)
                    .foregroundColor(DetectiveColors.ink)

                Text("Unit 4: Animals · 5词")
                    .font(DetectiveTypography.bodySmall)
                    .foregroundColor(DetectiveColors.textSecondary)

                HStack(spacing: 4) {
                    StatusTag(text: "🐱 cat", style: .success)
                    StatusTag(text: "🐶 dog", style: .success)
                    StatusTag(text: "+3", style: .warning)
                }

                Text("→ 继续调查")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(DetectiveColors.accent)
                    .padding(.top, 4)
            }
            .padding(DetectiveSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardStyle()
        }
        .buttonStyle(.plain)
    }

    private var lockedCaseCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("🔒 CASE #005")
                .font(DetectiveTypography.label)
                .foregroundColor(DetectiveColors.textMuted)

            Text("博物馆失窃案")
                .font(DetectiveTypography.titleSmall)
                .foregroundColor(DetectiveColors.textMuted)

            Text("完成 #004 解锁")
                .font(.system(size: 9))
                .foregroundColor(Color(hex: "D6D3D1"))
        }
        .padding(DetectiveSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DetectiveColors.muted)
        .clipShape(RoundedRectangle(cornerRadius: DetectiveRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: DetectiveRadius.large)
                .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                .foregroundColor(DetectiveColors.border)
        )
        .opacity(0.7)
    }

    // MARK: - Right Panel (Wanted + Stats)

    private var rightPanel: some View {
        VStack(spacing: DetectiveSpacing.xs) {
            wantedPosters
            weeklyStats
        }
        .frame(width: 165)
    }

    private var wantedPosters: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("🚨 悬赏令")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(DetectiveColors.ink)

            StatusTag(text: "🔴 bird · 3天", style: .danger)
            StatusTag(text: "🟡 mouth · 2天", style: .warning)
            StatusTag(text: "🟡 brown · 2天", style: .warning)
        }
        .padding(12)
        .cardStyle()
    }

    private var weeklyStats: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("📊 本周战绩")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(DetectiveColors.ink)

            statLine("结案", "3")
            statLine("词汇", "28")
            statLine("最长连对", "12")
        }
        .padding(12)
        .cardStyle()
    }

    private func statLine(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(DetectiveTypography.bodySmall)
                .foregroundColor(DetectiveColors.textSecondary)
            Spacer()
            Text(value)
                .font(DetectiveTypography.bodySmall)
                .fontWeight(.bold)
                .foregroundColor(DetectiveColors.ink)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MainOfficeView()
            .environmentObject(GameState())
    }
}
