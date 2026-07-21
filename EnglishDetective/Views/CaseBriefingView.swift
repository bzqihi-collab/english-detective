import SwiftUI

// MARK: - Case Briefing (Step 1: 接案)

struct CaseBriefingView: View {
    @EnvironmentObject var gameState: GameState

    // Animation state
    @State private var envelopeOffset: CGFloat = -300
    @State private var envelopeRotation: Double = -30
    @State private var envelopeOpacity: Double = 1
    @State private var letterScale: CGFloat = 0.3
    @State private var letterOpacity: Double = 0
    @State private var titleRevealed: Bool = false
    @State private var foxVisible: Bool = false
    @State private var wordsVisible: Bool = false
    @State private var buttonVisible: Bool = false

    var caseData: DetectiveCase? { gameState.currentCase }

    var body: some View {
        ZStack {
            DetectiveColors.warmBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                stepIndicator
                Spacer()
                briefingContent
                Spacer()
            }
        }
        .onAppear { runAnimationSequence() }
        .navigationBarHidden(true)
    }

    // MARK: - Step Indicator

    private var stepIndicator: some View {
        HStack(spacing: 0) {
            ForEach(CaseStep.allCases, id: \.self) { step in
                HStack(spacing: 4) {
                    Circle()
                        .fill(step == .briefing ? DetectiveColors.accent : DetectiveColors.border)
                        .frame(width: 8, height: 8)
                    Text(step.title)
                        .font(.system(size: 10))
                        .foregroundColor(
                            step == .briefing ? DetectiveColors.ink : DetectiveColors.textMuted
                        )
                }
                if step.stepNumber < CaseStep.allCases.count {
                    Rectangle()
                        .fill(DetectiveColors.border)
                        .frame(height: 1)
                        .frame(width: 30)
                        .padding(.horizontal, 4)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, DetectiveSpacing.md)
        .background(DetectiveColors.paper)
        .overlay(alignment: .bottom) {
            Divider().overlay(DetectiveColors.border)
        }
    }

    // MARK: - Briefing Content

    private var briefingContent: some View {
        VStack(spacing: 24) {
            // Envelope animation area
            ZStack {
                // Flying envelope (phase 1)
                if envelopeOpacity > 0 {
                    VStack(spacing: 8) {
                        Text("✉️")
                            .font(.system(size: 64))
                        Text("新密函抵达...")
                            .font(DetectiveTypography.body)
                            .foregroundColor(DetectiveColors.textMuted)
                    }
                    .offset(y: envelopeOffset)
                    .rotationEffect(.degrees(envelopeRotation))
                    .opacity(envelopeOpacity)
                }

                // Revealed letter content (phases 2-3)
                VStack(spacing: 16) {
                    Text("📨 案件密函")
                        .font(DetectiveTypography.label)
                        .foregroundColor(DetectiveColors.textMuted)

                    Text(caseData?.title ?? "")
                        .font(DetectiveTypography.titleLarge)
                        .foregroundColor(DetectiveColors.ink)
                        .opacity(titleRevealed ? 1 : 0)
                        .multilineTextAlignment(.center)

                    Text(caseData?.briefing ?? "")
                        .font(DetectiveTypography.body)
                        .foregroundColor(DetectiveColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 32)
                        .opacity(letterOpacity)
                }
                .scaleEffect(letterScale)
                .opacity(letterOpacity)
            }
            .frame(height: 200)

            // Words list (phase 4)
            if wordsVisible {
                VStack(spacing: 8) {
                    Text("🎯 本课目标单词")
                        .font(DetectiveTypography.label)
                        .foregroundColor(DetectiveColors.textMuted)

                    HStack(spacing: 8) {
                        ForEach(caseData?.words ?? []) { word in
                            StatusTag(
                                text: "\(word.emoji) \(word.english)",
                                style: .warning
                            )
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            // Sentences preview (phase 4)
            if wordsVisible {
                VStack(spacing: 4) {
                    Text("💬 跟读句子")
                        .font(DetectiveTypography.label)
                        .foregroundColor(DetectiveColors.textMuted)
                    ForEach(Array((caseData?.sentences ?? []).enumerated()), id: \.offset) { _, sentence in
                        Text("\"\(sentence)\"")
                            .font(DetectiveTypography.bodySmall)
                            .foregroundColor(DetectiveColors.textSecondary)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            // Fox character (phase 4)
            if foxVisible {
                VStack(spacing: 6) {
                    Text("🦊")
                        .font(.system(size: 52))
                    Text("\"Ready to solve this case?\"")
                        .font(DetectiveTypography.body)
                        .foregroundColor(DetectiveColors.ink)
                }
                .transition(.scale.combined(with: .opacity))
            }

            // Start button (phase 5)
            if buttonVisible {
                DetectiveButton(
                    title: "开始调查",
                    icon: "🔍",
                    style: .primary,
                    fullWidth: false
                ) {
                    gameState.advanceStep()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(DetectiveSpacing.lg)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: envelopeOffset)
    }

    // MARK: - Animation Sequence

    private func runAnimationSequence() {
        // Phase 1: Envelope flies in (0-1.5s)
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            envelopeOffset = 0
            envelopeRotation = 0
        }

        // Phase 2: Seal opens, letter expands (1.5-3.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                envelopeOpacity = 0
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                letterScale = 1.0
                letterOpacity = 1.0
            }
        }

        // Phase 3: Title types out (3.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeIn(duration: 0.6)) {
                titleRevealed = true
            }
        }

        // Phase 4: Fox + words appear (4.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                foxVisible = true
                wordsVisible = true
            }
        }

        // Phase 5: Button appears (4.8s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.8) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                buttonVisible = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let state = GameState()
    state.startCase(MockData.unit4Case)
    return CaseBriefingView()
        .environmentObject(state)
}
