import SwiftUI
import Combine

// MARK: - Global Game State

class GameState: ObservableObject {

    // MARK: Detective Profile
    @Published var detectiveName: String = "小明"
    @Published var detectiveRank: String = "初级侦探"
    @Published var experience: Int = 650
    @Published var maxExperience: Int = 1000
    @Published var coins: Int = 385

    // MARK: Current Case Flow
    @Published var currentCase: DetectiveCase?
    @Published var currentStep: CaseStep = .briefing
    @Published var foundEvidence: Set<UUID> = []
    @Published var spokenSentences: [Int: Bool] = [:]
    @Published var reportBlanksFilled: [String: Bool] = [:]

    // MARK: Daily Tasks
    @Published var todayNewWordsDone: Int = 4
    @Published var todayNewWordsTotal: Int = 5
    @Published var todayColdReviewDone: Int = 6
    @Published var todayColdReviewTotal: Int = 8
    @Published var todayReadSentencesDone: Int = 1
    @Published var todayReadSentencesTotal: Int = 3

    // MARK: Cold Case Words
    @Published var coldCaseWords: [(word: Word, proficiency: WordProficiency)] = []

    // MARK: Computed

    var experienceProgress: Double {
        guard maxExperience > 0 else { return 0 }
        return Double(experience) / Double(maxExperience)
    }

    // MARK: Actions

    func startCase(_ detectiveCase: DetectiveCase) {
        currentCase = detectiveCase
        currentStep = .briefing
        foundEvidence = []
        spokenSentences = [:]
        reportBlanksFilled = [:]
    }

    func advanceStep() {
        guard let currentIndex = CaseStep.allCases.firstIndex(of: currentStep),
              currentIndex < CaseStep.allCases.count - 1 else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = CaseStep.allCases[currentIndex + 1]
        }
    }

    func goToStep(_ step: CaseStep) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = step
        }
    }

    func findEvidence(_ wordId: UUID) {
        foundEvidence.insert(wordId)
    }

    func completeSentence(_ index: Int) {
        spokenSentences[index] = true
    }

    func fillReportBlank(_ blankId: String) {
        reportBlanksFilled[blankId] = true
    }
}
