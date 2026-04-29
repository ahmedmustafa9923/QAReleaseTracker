import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var appState: AppState

    var today: Date { Date() }

    var weekDays: [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    func tasksFor(_ date: Date) -> [Task] {
        let calendar = Calendar.current
        return appState.tasks.filter {
            calendar.isDate($0.due_date, inSameDayAs: date)
        }
    }

    func releasesFor(_ date: Date) -> [Release] {
        let calendar = Calendar.current
        return appState.releases.filter {
            calendar.isDate($0.deployment_date, inSameDayAs: date)
        }
    }

    func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(weekDays, id: \.self) { day in
                    Section(header: dayHeader(for: day)) {
                        let tasks = tasksFor(day)
                        let releases = releasesFor(day)

                        if tasks.isEmpty && releases.isEmpty {
                            Text("No items scheduled")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.vertical, 4)
                        }

                        ForEach(tasks) { task in
                            HStack {
                                Circle()
                                    .fill(priorityColor(task.priority))
                                    .frame(width: 8, height: 8)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(task.title)
                                        .font(.subheadline)
                                        .bold()
                                    Text("Task · \(task.priority) priority · \(task.status)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 4)
                        }

                        ForEach(releases) { release in
                            HStack {
                                Circle()
                                    .fill(statusColor(release.status))
                                    .frame(width: 8, height: 8)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(release.title)
                                        .font(.subheadline)
                                        .bold()
                                    Text("Release · \(release.status)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("This Week")
        }
    }

    func dayHeader(for date: Date) -> some View {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return HStack {
            Text(formatter.string(from: date))
                .font(.subheadline)
                .bold()
                .foregroundColor(isToday(date) ? .blue : .primary)
            if isToday(date) {
                Text("TODAY")
                    .font(.caption2)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue)
                    .cornerRadius(4)
            }
            Spacer()
        }
    }

    func priorityColor(_ priority: String) -> Color {
        switch priority {
        case "Critical": return .red
        case "High": return .orange
        case "Medium": return .yellow
        default: return .green
        }
    }

    func statusColor(_ status: String) -> Color {
        switch status {
        case "Critical": return .red
        case "Medium": return .orange
        case "On Track": return .green
        default: return .blue
        }
    }
}
