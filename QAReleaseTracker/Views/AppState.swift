import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var releases: [Release] = []
    @Published var isLoggedIn: Bool = false
    @Published var accessToken: String = ""
    @Published var userId: String = ""

    let baseURL = "https://zskjzutxeafxluarmmkx.supabase.co/rest/v1"
    let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpza2p6dXR4ZWFmeGx1YXJtbWt4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY3ODYyMzQsImV4cCI6MjA5MjM2MjIzNH0.P91kDwqiARgKJHFkXNxeNBW4-K_QLsBGDrcRHZmAoyQ"

    var headers: [String: String] {
        [
            "apikey": anonKey,
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json",
            "Prefer": "return=representation"
        ]
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

    // MARK: - Tasks
    func fetchTasks() {
        guard let url = URL(string: "\(baseURL)/tasks?select=*&order=created_at.desc") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        headers.forEach { request.addValue($1, forHTTPHeaderField: $0) }

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data else { return }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let tasks = try? decoder.decode([Task].self, from: data) {
                DispatchQueue.main.async { self.tasks = tasks }
            } else {
                print("Fetch tasks error: \(String(data: data, encoding: .utf8) ?? "")")
            }
        }.resume()
    }

    func insertTask(_ task: Task) {
        guard let url = URL(string: "\(baseURL)/tasks") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        headers.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try? encoder.encode(task)
        
        if let body = request.httpBody {
            print("Sending task: \(String(data: body, encoding: .utf8) ?? "")")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print("Supabase insert response: \(String(data: data, encoding: .utf8) ?? "")")
            }
            if let error = error {
                print("Supabase insert error: \(error)")
            }
            DispatchQueue.main.async { self.fetchTasks() }
        }.resume()
    }

    func deleteTask(id: UUID) {
        guard let url = URL(string: "\(baseURL)/tasks?id=eq.\(id.uuidString)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        headers.forEach { request.addValue($1, forHTTPHeaderField: $0) }

        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async { self.fetchTasks() }
        }.resume()
    }

    func updateTask(_ task: Task) {
        guard let url = URL(string: "\(baseURL)/tasks?id=eq.\(task.id.uuidString)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        headers.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try? encoder.encode(task)

        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async { self.fetchTasks() }
        }.resume()
    }

    // MARK: - Releases
    func fetchReleases() {
        guard let url = URL(string: "\(baseURL)/releases?select=*&order=deployment_date.asc") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        headers.forEach { request.addValue($1, forHTTPHeaderField: $0) }

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { return }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let releases = try? decoder.decode([Release].self, from: data) {
                DispatchQueue.main.async { self.releases = releases }
            } else {
                print("Fetch releases error: \(String(data: data, encoding: .utf8) ?? "")")
            }
        }.resume()
    }

    func insertRelease(_ release: Release) {
        guard let url = URL(string: "\(baseURL)/releases") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        headers.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try? encoder.encode(release)

        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async { self.fetchReleases() }
        }.resume()
    }
}
