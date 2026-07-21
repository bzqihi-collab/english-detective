import SwiftUI

// MARK: - Celebration (Step 5: 庆祝)

struct CelebrationView: View {
    @EnvironmentObject var gameState: GameState
    @Environment(\.dismiss) private var dismiss

    @State private var showConfetti: Bool = false
    @State private var showStats: Bool = false
    @State private var showBadge: Bool = false
    @State private var badgeRotation: Double = 0
    @State private var showButtons: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [DetectiveColors.warmBackground, DetectiveColors.accentLight],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Confetti particles (simplified)
            if showConfetti {
                confettiOverlay
            }

            VStack(spacing: 20) {
                Spacer()

                // Header
                VStack(spacing: 8) {
                    Text("🎉🎉🎉")
                        .font(.system(size: 48))

                    Text("案件解决！")
                        .font(DetectiveTypography.titleLarge)
                        .foregroundColor(DetectiveColors.ink)

                    Text(gameState.currentCase?.title ?? "Case #004")
                        .font(DetectiveTypography.body)
                        .foregroundColor(DetectiveColors.textSecondary)
                }

                // Stats tags
                if showStats {
                    VStack(spacing: 6) {
                        HStack(spacing: 8) {
                            StatusTag(text: "⭐ 单词 5/5", style: .success)
                            StatusTag(text: "🎤 跟读 3/3", style: .success)
                            StatusTag(text: "📝 报告完美", style: .success)
                        }
                        HStack(spacing: 8) {
                            StatusTag(text: "⚡ +120 经验", style: .warning)
                            StatusTag(text: "🪙 +50 金币", style: .warning)
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                // Badge
                if showBadge {
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "FFD700"), Color(hex: "FFA000")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .shadow(
                                    color: Color(hex: "FFA000").opacity(0.3),
                                    radius: 12,
                                    y: 4
                                )

                            Text("🏅")
                                .font(.system(size: 44))
                        }
                        .rotationEffect(.degrees(badgeRotation))

                        Text("获得新徽章")
                            .font(DetectiveTypography.label)
                            .foregroundColor(DetectiveColors.textMuted)

                        Text("动物之友")
                            .font(DetectiveTypography.titleMedium)
                            .foregroundColor(DetectiveColors.ink)

                        Text("徽章已收入收藏册")
                            .font(DetectiveTypography.bodySmall)
                            .foregroundColor(DetectiveColors.textSecondary)
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                Spacer()

                // Action buttons
                if showButtons {
                    VStack(spacing: 10) {
                        NavigationLink {
                            MainOfficeView()
                                .navigationBarHidden(true)
                        } label: {
                            HStack(spacing: 6) {
                                Text("🏢")
                                Text("回事务所")
                                    .fontWeight(.bold)
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(DetectiveColors.ink)
                            .clipShape(RoundedRectangle(cornerRadius: DetectiveRadius.small))
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            ColdCaseView()
                        } label: {
                            HStack(spacing: 6) {
                                Text("📂")
                                Text("清理冷案")
                                    .fontWeight(.bold)
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(DetectiveColors.accent)
                            .clipShape(RoundedRectangle(cornerRadius: DetectiveRadius.small))
                        }
                        .buttonStyle(.plain)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(40)
        }
        .navigationBarHidden(true)
        .onAppear { runCelebrationSequence() }
    }

    // MARK: - Confetti Overlay

    private var confettiOverlay: some View {
        GeometryReader { geometry in
            ForEach(0..<30) { i in
                let x = CGFloat.random(in: 0...geometry.size.width)
                let size = CGFloat.random(in: 6...14)
                let colors: [Color] = [
                    DetectiveColors.accent,
                    DetectiveColors.success,
                    Color(hex: "EC4899"),
                    Color(hex: "3B82F6"),
                    Color(hex: "F59E0B"),
                ]

                Circle()
                    .fill(colors[i % colors.count])
                    .frame(width: size, height: size)
                    .position(
                        x: x,
                        y: showConfetti
                            ? geometry.size.height + 20
                            : -20
                    )
                    .animation(
                        .interpolatingSpring(
                            stiffness: 50,
                            damping: 5
                        )
                        .delay(Double(i) * 0.05)
                        .repeatForever(autoreverses: false),
                        value: showConfetti
                    )
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Animation Sequence

    private func runCelebrationSequence() {
        // Phase 1: Confetti
        withAnimation {
            showConfetti = true
        }

        // Phase 2: Stats (0.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showStats = true
            }
        }

        // Phase 3: Badge (1.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                showBadge = true
            }
        }

        // Phase 4: Badge spin (1.2s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.5)) {
                badgeRotation = 360
            }
        }

        // Phase 5: Buttons (1.8s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showButtons = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        let state = GameState()
        state.startCase(MockData.unit4Case)
        return CelebrationView()
            .environmentObject(state)
    }
}
