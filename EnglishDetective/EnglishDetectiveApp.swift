import SwiftUI

// MARK: - App Entry Point

@main
struct EnglishDetectiveApp: App {
    @StateObject private var gameState = GameState()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MainOfficeView()
            }
            .environmentObject(gameState)
            .preferredColorScheme(.light)
            .tint(DetectiveColors.accent)
        }
    }
}
