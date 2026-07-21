import SwiftUI

// MARK: - Investigation (Step 2: 搜证)

struct InvestigationView: View {
    @EnvironmentObject var gameState: GameState
    @State private var foundWord: Word? = nil
    @State private var showPronunciationResult: Bool = false
    @State private var pronunciationScore: Int = 0
    @State private var currentClueText: String = ""

    private let audioClues: [String] = [
        "Find the animal that says meow...",
        "Find the animal that says woof...",
        "Find the animal that says tweet-tweet...",
        "Find the animal that swims in water...",
        "Find the animal that hops and has long ears...",
    ]

    var caseData: DetectiveCase? { gameState.currentCase }
    var totalCount: Int { caseData?.words.count ?? 5 }
    var foundCount: Int { gameState.foundEvidence.count }
    var allFound: Bool { foundCount == totalCount }

    var body: some View {
        ZStack {
            DetectiveColors.warmBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                stepIndicator
                sceneArea
                Spacer()
            }
        }
        .onAppear { pickRandomClue() }
        .navigationBarHidden(true)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: foundCount)
    }

    // MARK: - Step Indicator

    private var stepIndicator: some View {
        HStack(spacing: 0) {
            ForEach(CaseStep.allCases, id: \.self) { step in
                HStack(spacing: 4) {
                    if step == .investigation {
                        Circle().fill(DetectiveColors.accent).frame(width: 8, height: 8)
                    } else if step == .briefing {
                        Circle().fill(DetectiveColors.success).frame(width: 8, height: 8)
                    } else {
                        Circle().fill(DetectiveColors.border).frame(width: 8, height: 8)
                    }
                    Text(step.title)
                        .font(.system(size: 10))
                        .foregroundColor(
                            step == .investigation ? DetectiveColors.ink : DetectiveColors.textMuted
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

    // MARK: - Scene Area

    private var sceneArea: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Instructions
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Text("🔦")
                        Text("已找到")
                            .font(DetectiveTypography.bodySmall)
                        Text("\(foundCount)/\(totalCount)")
                            .font(DetectiveTypography.bodySmall)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(DetectiveColors.ink)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(DetectiveColors.paper)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    Spacer()

                    Text("点击场景中的动物 → 说出英文名 → 收集证物")
                        .font(DetectiveTypography.bodySmall)
                        .foregroundColor(DetectiveColors.textMuted)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                // Scene grid with warm gradient background
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5),
                    spacing: 12
                ) {
                    ForEach(caseData?.words ?? []) { word in
                        let isFound = gameState.foundEvidence.contains(word.id)
                        WordCard(
                            word: word,
                            status: isFound ? .mastered : nil,
                            onTap: { if !isFound { discoverWord(word) } },
                            size: .normal
                        )
                        .opacity(isFound ? 1.0 : 0.85)
                    }
                }
                .padding(20)
                .background(
                    LinearGradient(
                        colors: [DetectiveColors.muted, Color(hex: "E8E0D3")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: DetectiveRadius.large))
                .overlay(
                    RoundedRectangle(cornerRadius: DetectiveRadius.large)
                        .stroke(DetectiveColors.border, lineWidth: 1.5)
                )
                .padding(.horizontal, 16)

                // Audio clue
                HStack(spacing: 8) {
                    Text("🔊")
                        .font(.title3)
                    Text("\"\(currentClueText)\"")
                        .font(DetectiveTypography.bodySmall)
                        .foregroundColor(DetectiveColors.ink)
                    Button {
                        pickRandomClue()
                    } label: {
                        Text("🔁")
                            .font(.caption)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(DetectiveColors.paper)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.03), radius: 3, y: 1)

                // Pronunciation result popup
                if showPronunciationResult, let word = foundWord {
                    pronunciationResultView(word)
                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                        .padding(.horizontal, 16)
                }

                // Evidence bag row
                evidenceBagRow
                    .padding(.horizontal, 16)

                // Continue button
                if allFound {
                    DetectiveButton(
                        title: "审讯证人",
                        icon: "🎤",
                        style: .primary,
                        fullWidth: false
                    ) {
                        gameState.advanceStep()
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
            }
        }
    }

    // MARK: - Pronunciation Result

    private func pronunciationResultView(_ word: Word) -> some View {
        HStack(spacing: 10) {
            Text("🎤")
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text("你读出了 \"\(word.english)\"")
                    .font(DetectiveTypography.body)
                    .foregroundColor(DetectiveColors.ink)
                HStack(spacing: 2) {
                    ForEach(0..<pronunciationScore, id: \.self) { _ in
                        Text("⭐")
                    }
                }
                .font(.caption)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                StatusTag(text: "证物已收集", style: .success)
                Text("+10 ⚡")
                    .font(DetectiveTypography.label)
                    .foregroundColor(DetectiveColors.accent)
            }
        }
        .padding(14)
        .background(Color(hex: "F0FDF4"))
        .clipShape(RoundedRectangle(cornerRadius: DetectiveRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: DetectiveRadius.medium)
                .stroke(Color(hex: "D9F99D"), lineWidth: 1.5)
        )
    }

    // MARK: - Evidence Bag Row

    private var evidenceBagRow: some View {
        HStack(spacing: 6) {
            ForEach(caseData?.words ?? []) { word in
                if gameState.foundEvidence.contains(word.id) {
                    StatusTag(text: "🧤 \(word.english)", style: .success)
                } else {
                    StatusTag(text: "🧤 ???", style: .neutral)
                }
            }
        }
    }

    // MARK: - Actions

    private func discoverWord(_ word: Word) {
        foundWord = word
        pronunciationScore = Int.random(in: 3...5)
        showPronunciationResult = true

        // Haptic-like delay before collecting
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                gameState.findEvidence(word.id)
                showPronunciationResult = false
                foundWord = nil
                pickRandomClue()
            }
        }
    }

    private func pickRandomClue() {
        let remaining = (caseData?.words ?? [])
            .filter { !gameState.foundEvidence.contains($0.id) }
        if !remaining.isEmpty {
            currentClueText = audioClues.randomElement() ?? audioClues[0]
        }
    }
}

// MARK: - Preview

#Preview {
    let state = GameState()
    state.startCase(MockData.unit4Case)
    state.findEvidence(MockData.wordCat.id)
    state.findEvidence(MockData.wordDog.id)
    return InvestigationView()
        .environmentObject(state)
}
