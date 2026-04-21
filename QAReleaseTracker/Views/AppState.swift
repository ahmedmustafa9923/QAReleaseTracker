import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var tasks: [Task] = [] {
        didSet { saveTasks() }
    }
    @Published var releases: [Release] = [] {
        didSet { saveReleases() }
    }

    init() {
        loadTasks()
        loadReleases()
    }

    var overdueTasks: [Task] {
        tasks.filter { $0.due_date < Date() && $0.status != "Completed" && $0.status != "Archived" }
    }

    var overdueReleases: [Release] {
        releases.filter { $0.deployment_date < Date() && $0.status != "On Track" }
    }

    var totalOverdue: Int {
        overdueTasks.count + overdueReleases.count
    }

    // MARK: - Persistence
    func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: "saved_tasks")
        }
    }

    func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: "saved_tasks"),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        }
    }

    func saveReleases() {
        if let encoded = try? JSONEncoder().encode(releases) {
            UserDefaults.standard.set(encoded, forKey: "saved_releases")
        }
    }

    func loadReleases() {
        if let data = UserDefaults.standard.data(forKey: "saved_releases"),
           let decoded = try? JSONDecoder().decode([Release].self, from: data) {
            releases = decoded
        }
    }
}
