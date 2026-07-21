import SwiftUI

// MARK: - Case Report (Step 4: 结案报告)

struct CaseReportView: View {
    @EnvironmentObject var gameState: GameState
    @State private var filledBlanks: [String: Word] = [:]
    @State private var stampVisible: Bool = false
    @State private var stampScale: CGFloat = 3.0
    @State private var stampOpacity: Double = 0

    var caseData: DetectiveCase? { gameState.currentCase }

    private let blanks: [(id: String, answer: String)] = [
        ("blank_fish", "fish"),
        ("blank_rabbit", "rabbit"),
    ]

    var allFilled: Bool {
        filledBlanks.count == blanks.count
    }

    var body: some View {
        ZStack {
            DetectiveColors.warmBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                stepIndicator

                HStack(alignment: .top, spacing: 16) {
                    reportPaper
                    wordBank
                }
                .padding(DetectiveSpacing.md)

                if allFilled && !stampVisible {
                    DetectiveButton(
                        title: "提交报告",
                        icon: "📋",
                        style: .accent,
                        fullWidth: false
                    ) {
                        submitReport()
                    }
                    .padding(.bottom, 16)
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Step Indicator

    private var stepIndicator: some View {
        HStack(spacing: 0) {
            ForEach(CaseStep.allCases, id: \.self) { step in
                HStack(spacing: 4) {
                    if step == .report {
                        Circle().fill(DetectiveColors.accent).frame(width: 8, height: 8)
                    } else if step == .celebration {
                        Circle().fill(DetectiveColors.border).frame(width: 8, height: 8)
                    } else {
                        Circle().fill(DetectiveColors.success).frame(width: 8, height: 8)
                    }
                    Text(step.title)
                        .font(.system(size: 10))
                        .foregroundColor(
                            step == .report ? DetectiveColors.ink : DetectiveColors.textMuted
                        )
                }
                if step.stepNumber < CaseStep.allCases.count {
                    Rectangle()
                        .fill(DetectiveColors.border)
                        .frame(height: 1).frame(width: 30)
                        .padding(.horizontal, 4)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, DetectiveSpacing.md)
        .background(DetectiveColors.paper)
        .overlay(alignment: .bottom) { Divider().overlay(DetectiveColors.border) }
    }

    // MARK: - Report Paper

    private var reportPaper: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📋 案件结案报告 — CASE #004")
                .font(DetectiveTypography.titleSmall)
                .foregroundColor(DetectiveColors.ink)
                .frame(maxWidth: .infinity, alignment: .center)

            Divider().overlay(DetectiveColors.border)

            Group {
                Text("案发地点：动物园")
                Text("失踪动物数量：5 只")
                Text("调查状态：已完成搜证与审讯")
            }
            .font(DetectiveTypography.body)
            .foregroundColor(DetectiveColors.ink)

            Text("已确认的动物：")
                .font(DetectiveTypography.body)
                .fontWeight(.bold)
                .foregroundColor(DetectiveColors.ink)
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(caseData?.words ?? []) { word in
                    HStack(spacing: 4) {
                        if gameState.foundEvidence.contains(word.id) {
                            Text("✅")
                            Text("The")
                                .foregroundColor(DetectiveColors.ink)
                            Text(word.english)
                                .fontWeight(.bold)
                                .foregroundColor(DetectiveColors.ink)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(DetectiveColors.accentLight)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                            Text("is ______.")
                                .foregroundColor(DetectiveColors.textMuted)
                        }
                    }
                    .font(DetectiveTypography.bodySmall)
                    .opacity(gameState.foundEvidence.contains(word.id) ? 1.0 : 0.5)
                }

                // Blanks to fill
                ForEach(blanks, id: \.id) { blank in
                    HStack(spacing: 4) {
                        Text("⬜")
                        if let filled = filledBlanks[blank.id] {
                            Text("\(filled.emoji)")
                            Text(filled.english)
                                .fontWeight(.bold)
                                .foregroundColor(DetectiveColors.success)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color(hex: "F0FDF4"))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        } else {
                            Text("______")
                                .foregroundColor(DetectiveColors.textMuted)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(DetectiveColors.muted)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(
                                            style: StrokeStyle(lineWidth: 1.5, dash: [4])
                                        )
                                        .foregroundColor(DetectiveColors.border)
                                )
                        }
                    }
                    .font(DetectiveTypography.bodySmall)
                }
            }
            .padding(.leading, 16)

            Spacer()

            // CASE SOLVED stamp overlay
            ZStack {
                if stampVisible {
                    Text("CASE\nSOLVED")
                        .font(.system(size: 22, weight: .black, design: .serif))
                        .foregroundColor(DetectiveColors.danger)
                        .padding(16)
                        .rotationEffect(.degrees(-15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(DetectiveColors.danger, lineWidth: 4)
                                .rotationEffect(.degrees(-15))
                        )
                        .scaleEffect(stampScale)
                        .opacity(stampOpacity)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [.white, DetectiveColors.warmBackground],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: DetectiveRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: DetectiveRadius.large)
                .stroke(DetectiveColors.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
    }

    // MARK: - Word Bank

    private var wordBank: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("📦 证据池")
                .font(DetectiveTypography.label)
                .foregroundColor(DetectiveColors.textMuted)

            Text("点击单词填入报告空白处")
                .font(.system(size: 9))
                .foregroundColor(DetectiveColors.textMuted)

            ForEach(blanks, id: \.id) { blank in
                if filledBlanks[blank.id] == nil,
                   let word = caseData?.words.first(where: { $0.english == blank.answer }) {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            filledBlanks[blank.id] = word
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(word.emoji)
                            Text(word.english)
                                .fontWeight(.bold)
                        }
                        .font(DetectiveTypography.body)
                        .foregroundColor(DetectiveColors.ink)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(DetectiveColors.paper)
                        .clipShape(RoundedRectangle(cornerRadius: DetectiveRadius.small))
                        .overlay(
                            RoundedRectangle(cornerRadius: DetectiveRadius.small)
                                .stroke(DetectiveColors.accent, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            if allFilled {
                Text("✅ 全部填写完成")
                    .font(DetectiveTypography.label)
                    .foregroundColor(DetectiveColors.success)
                    .padding(.top, 4)
            }
        }
        .frame(width: 180)
    }

    // MARK: - Submit

    private func submitReport() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
            stampVisible = true
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.4)) {
            stampScale = 1.0
            stampOpacity = 1.0
        }
        // Advance after dramatic pause
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            gameState.advanceStep()
        }
    }
}

// MARK: - Preview

#Preview {
    let state = GameState()
    state.startCase(MockData.unit4Case)
    state.findEvidence(MockData.wordCat.id)
    state.findEvidence(MockData.wordDog.id)
    state.findEvidence(MockData.wordBird.id)
    state.findEvidence(MockData.wordFish.id)
    state.findEvidence(MockData.wordRabbit.id)
    return CaseReportView()
        .environmentObject(state)
}
