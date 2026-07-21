import SwiftUI

// MARK: - Interrogation (Step 3: 审讯)

struct InterrogationView: View {
    @EnvironmentObject var gameState: GameState
    @State private var currentSentenceIndex: Int = 0
    @State private var isRecording: Bool = false
    @State private var showResult: Bool = false
    @State private var wordScores: [String: Int] = [:]  // 0=red, 1=yellow, 2=green

    private let witnessEmoji = "🐰"
    private let witnessName = "兔子女士"
    private let witnessRole = "目击证人"

    var caseData: DetectiveCase? { gameState.currentCase }
    var sentences: [String] { caseData?.sentences ?? [] }
    var totalSentences: Int { sentences.count }

    var allSentencesDone: Bool {
        gameState.spokenSentences.count == totalSentences
    }

    var body: some View {
        ZStack {
            DetectiveColors.warmBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                stepIndicator

                HStack(alignment: .top, spacing: 16) {
                    witnessPanel
                    dialoguePanel
                }
                .padding(DetectiveSpacing.md)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Step Indicator

    private var stepIndicator: some View {
        HStack(spacing: 0) {
            ForEach(CaseStep.allCases, id: \.self) { step in
                HStack(spacing: 4) {
                    if step == .interrogation {
                        Circle().fill(DetectiveColors.accent).frame(width: 8, height: 8)
                    } else if step == .briefing || step == .investigation {
                        Circle().fill(DetectiveColors.success).frame(width: 8, height: 8)
                    } else {
                        Circle().fill(DetectiveColors.border).frame(width: 8, height: 8)
                    }
                    Text(step.title)
                        .font(.system(size: 10))
                        .foregroundColor(
                            step == .interrogation ? DetectiveColors.ink : DetectiveColors.textMuted
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

    // MARK: - Witness Panel (Left)

    private var witnessPanel: some View {
        VStack(spacing: 12) {
            Text(witnessEmoji)
                .font(.system(size: 64))

            Text(witnessName)
                .font(DetectiveTypography.titleSmall)
                .foregroundColor(DetectiveColors.ink)

            Text(witnessRole)
                .font(DetectiveTypography.label)
                .foregroundColor(DetectiveColors.textMuted)

            if isRecording {
                StatusTag(text: "聆听中...", style: .warning)
            } else if showResult {
                let allGood = wordScores.values.allSatisfy { $0 >= 1 }
                StatusTag(
                    text: allGood ? "✨ 说得很好!" : "🤔 再试试?",
                    style: allGood ? .success : .warning
                )
            } else {
                StatusTag(text: "等待中", style: .neutral)
            }

            Spacer()

            // Progress dots
            HStack(spacing: 8) {
                ForEach(0..<totalSentences, id: \.self) { i in
                    Circle()
                        .fill(
                            gameState.spokenSentences[i] == true
                            ? DetectiveColors.success
                            : i == currentSentenceIndex
                            ? DetectiveColors.accent
                            : DetectiveColors.border
                        )
                        .frame(width: 10, height: 10)
                }
            }
            Text("句子 \(currentSentenceIndex + 1) / \(totalSentences)")
                .font(.system(size: 9))
                .foregroundColor(DetectiveColors.textMuted)
        }
        .frame(width: 200)
        .padding(20)
        .background(
            LinearGradient(
                colors: [DetectiveColors.muted, DetectiveColors.warmBackground],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: DetectiveRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: DetectiveRadius.large)
                .stroke(DetectiveColors.border, lineWidth: 1)
        )
    }

    // MARK: - Dialogue Panel (Right)

    private var dialoguePanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            // NPC speech bubble
            VStack(alignment: .leading, spacing: 4) {
                Text("\(witnessEmoji) \(witnessName)说：")
                    .font(.system(size: 9))
                    .foregroundColor(DetectiveColors.textMuted)

                Text("\"\(sentences[safe: currentSentenceIndex] ?? "")\"")
                    .font(DetectiveTypography.body)
                    .fontWeight(.bold)
                    .foregroundColor(DetectiveColors.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .cardStyle()

            // Recording area
            VStack(spacing: 10) {
                Text("🎤 请跟读这句话，说服她给你更多线索！")
                    .font(DetectiveTypography.bodySmall)
                    .foregroundColor(Color(hex: "92400E"))

                // Simulated waveform
                if isRecording {
                    HStack(alignment: .bottom, spacing: 2) {
                        ForEach(0..<14, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(i % 2 == 0 ? DetectiveColors.success : DetectiveColors.accent)
                                .frame(width: 3, height: CGFloat.random(in: 12...36))
                        }
                    }
                    .frame(height: 36)
                    .transition(.scale.combined(with: .opacity))
                    .id("waveform-\(Date().timeIntervalSince1970)") // force refresh
                }

                // Record / Stop button
                Button {
                    toggleRecording()
                } label: {
                    HStack(spacing: 8) {
                        Text(isRecording ? "🔴" : "🎙️")
                        Text(isRecording ? "录音中...轻点停止" : "点我开始跟读")
                            .font(DetectiveTypography.body)
                    }
                    .foregroundColor(isRecording ? DetectiveColors.danger : DetectiveColors.ink)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isRecording ? Color(hex: "FEF2F2") : DetectiveColors.accentLight)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isRecording ? DetectiveColors.danger : Color(hex: "FDE68A"),
                                lineWidth: 1.5
                            )
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(14)
            .background(DetectiveColors.accentLight)
            .clipShape(RoundedRectangle(cornerRadius: DetectiveRadius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: DetectiveRadius.medium)
                    .stroke(Color(hex: "FDE68A"), lineWidth: 1.5)
            )

            // Word-by-word scores
            if showResult {
                wordScoreGrid
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Navigation buttons
            if showResult {
                HStack {
                    if currentSentenceIndex < totalSentences - 1 {
                        DetectiveButton(
                            title: "下一句",
                            style: .secondary,
                            fullWidth: false
                        ) {
                            nextSentence()
                        }
                    }

                    Spacer()

                    if allSentencesDone || (showResult && currentSentenceIndex == totalSentences - 1) {
                        DetectiveButton(
                            title: "写结案报告",
                            icon: "✍️",
                            style: .primary,
                            fullWidth: false
                        ) {
                            gameState.advanceStep()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Word Score Grid

    private var wordScoreGrid: some View {
        let words = (sentences[safe: currentSentenceIndex] ?? "")
            .components(separatedBy: " ")
            .map { $0.trimmingCharacters(in: .punctuationCharacters).lowercased() }
            .filter { !$0.isEmpty }

        return VStack(alignment: .leading, spacing: 6) {
            Text("📊 逐词评分")
                .font(DetectiveTypography.label)
                .foregroundColor(DetectiveColors.textMuted)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4),
                spacing: 6
            ) {
                ForEach(Array(words.enumerated()), id: \.offset) { _, word in
                    let score = wordScores[word] ?? 1
                    StatusTag(
                        text: "\(word) \(score >= 2 ? "⭐" : score == 1 ? "△" : "✗")",
                        style: score >= 2 ? .success : score == 1 ? .warning : .danger
                    )
                }
            }
        }
        .padding(14)
        .cardStyle()
    }

    // MARK: - Actions

    private func toggleRecording() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if isRecording {
                isRecording = false
                simulateScores()
                showResult = true
                gameState.completeSentence(currentSentenceIndex)
            } else {
                isRecording = true
                showResult = false
                wordScores = [:]
            }
        }
    }

    private func simulateScores() {
        let words = (sentences[safe: currentSentenceIndex] ?? "")
            .components(separatedBy: " ")
            .map { $0.trimmingCharacters(in: .punctuationCharacters).lowercased() }
            .filter { !$0.isEmpty }

        wordScores = [:]
        for word in words {
            // Most words score well, occasional "needs work"
            wordScores[word] = Int.random(in: 1...2)
        }
    }

    private func nextSentence() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentSentenceIndex += 1
            isRecording = false
            showResult = false
            wordScores = [:]
        }
    }
}

// MARK: - Safe Array Access

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Preview

#Preview {
    let state = GameState()
    state.startCase(MockData.unit4Case)
    return InterrogationView()
        .environmentObject(state)
}
