import SwiftUI

@main
struct QAReleaseTrackerApp: App {
    @StateObject var appState = AppState()

    var body: some Scene {
        WindowGroup {
            if appState.isLoggedIn {
                ContentView()
                    .environmentObject(appState)
            } else {
                AuthView()
                    .environmentObject(appState)
            }
        }
    }
}
