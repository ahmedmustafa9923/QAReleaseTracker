import SwiftUI

struct DashboardView: View {
    @State private var tasks: [Task] = []

    var pendingTasks: [Task] { tasks.filter { $0.status == "Pending" } }
    var completedTasks: [Task] { tasks.filter { $0.status == "Completed" } }
    var overdueTasks: [Task] { tasks.filter { $0.dueDate < Date() && $0.status != "Completed" } }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Welcome, Ahmed")
                        .font(.title)
                        .bold()

                    HStack(spacing: 15) {
                        NavigationLink(destination: TaskListView(title: "All Tasks", tasks: tasks)) {
                            StatCard(title: "Total Tasks", value: "\(tasks.count)", color: .blue)
                        }
                        NavigationLink(destination: TaskListView(title: "Completed", tasks: completedTasks)) {
                            StatCard(title: "Completed", value: "\(completedTasks.count)", color: .green)
                        }
                    }
                    HStack(spacing: 15) {
                        NavigationLink(destination: TaskListView(title: "Pending", tasks: pendingTasks)) {
                            StatCard(title: "Pending", value: "\(pendingTasks.count)", color: .orange)
                        }
                        NavigationLink(destination: TaskListView(title: "Overdue", tasks: overdueTasks)) {
                            StatCard(title: "Overdue", value: "\(overdueTasks.count)", color: .red)
                        }
                    }
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }
}

struct TaskListView: View {
    var title: String
    var tasks: [Task]

    var body: some View {
        List {
            ForEach(tasks.sorted { $0.priority > $1.priority }) { task in
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
                    Text(task.dueDate, style: .date)
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
