import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "chart.bar") }
            TasksView()
                .tabItem { Label("Tasks", systemImage: "checklist") }
            ScheduleView()
                .tabItem { Label("Schedule", systemImage: "calendar") }
            ReleaseCalendarView()
                .tabItem { Label("Releases", systemImage: "rocket") }
        }
        .onAppear {
            appState.fetchTasks()
            appState.fetchReleases()
        }
    }
}
