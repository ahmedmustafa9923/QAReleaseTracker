import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState

    var pendingTasks: [Task] { appState.tasks.filter { $0.status == "Pending" } }
    var completedTasks: [Task] { appState.tasks.filter { $0.status == "Completed" } }
    var overdueTasks: [Task] { appState.tasks.filter { $0.due_date < Date() && $0.status != "Completed" } }

    var body: some View {
        NavigationView {
            List {
                Section {
                    Text("Welcome, Ahmed")
                        .font(.title)
                        .bold()
                        .padding(.vertical, 8)
                }

                Section("Overview") {
                    NavigationLink(destination: TaskListView(title: "All Tasks", tasks: appState.tasks)) {
                        DashboardRow(title: "Total Tasks", value: "\(appState.tasks.count)", color: .blue, icon: "checklist")
                    }
                    NavigationLink(destination: TaskListView(title: "Completed", tasks: completedTasks)) {
                        DashboardRow(title: "Completed", value: "\(completedTasks.count)", color: .green, icon: "checkmark.circle.fill")
                    }
                    NavigationLink(destination: TaskListView(title: "Pending", tasks: pendingTasks)) {
                        DashboardRow(title: "Pending", value: "\(pendingTasks.count)", color: .orange, icon: "clock.fill")
                    }
                    NavigationLink(destination: TaskListView(title: "Overdue", tasks: overdueTasks)) {
                        DashboardRow(title: "Overdue", value: "\(appState.totalOverdue)", color: .red, icon: "exclamationmark.circle.fill")
                    }
                }

                if !overdueTasks.isEmpty {
                    Section {
                        Button(action: {
                            appState.checkAndNotifyOverdueTasks(userPhone: appState.userPhone)
                        }) {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.white)
                                Text("Send SMS Alerts for \(overdueTasks.count) Overdue Tasks")
                                    .foregroundColor(.white)
                                    .font(.caption)
                                    .bold()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Dashboard")
        }
    }
}

struct DashboardRow: View {
    var title: String
    var value: String
    var color: Color
    var icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
                .frame(width: 36)
            Text(title)
                .font(.body)
            Spacer()
            Text(value)
                .font(.title2)
                .bold()
                .foregroundColor(color)
        }
        .padding(.vertical, 6)
    }
}

struct TaskListView: View {
    var title: String
    var tasks: [Task]

    var body: some View {
        List {
            ForEach(tasks) { task in
                VStack(alignment: .leading, spacing: 5) {
                    Text(task.title)
                        .font(.headline)
                    HStack {
                        Text(task.status)
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Text("Priority: \(task.priority)")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    Text(task.due_date, style: .date)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(.vertical, 5)
            }
        }
        .navigationTitle(title)
    }
}

struct StatCard: View {
    var title: String
    var value: String
    var color: Color

    var body: some View {
        VStack {
            Text(value)
                .font(.largeTitle)
                .bold()
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
