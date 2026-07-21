import SwiftUI

// MARK: - Case Flow Container (manages step navigation)

struct CaseFlowView: View {
    @EnvironmentObject var gameState: GameState

    var body: some View {
        Group {
            switch gameState.currentStep {
            case .briefing:
                CaseBriefingView()
            case .investigation:
                InvestigationView()
            case .interrogation:
                InterrogationView()
            case .report:
                CaseReportView()
            case .celebration:
                CelebrationView()
            }
        }
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.3), value: gameState.currentStep)
    }
}

// MARK: - Preview

#Preview {
    let state = GameState()
    state.startCase(MockData.unit4Case)
    return NavigationStack {
        CaseFlowView()
            .environmentObject(state)
    }
}
