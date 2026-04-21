import SwiftUI

struct TasksView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingAddTask = false
    @State private var showingError = false
    @State private var newTitle = ""
    @State private var newNotes = ""
    @State private var newOwner = ""
    @State private var newDueDate = Date()
    @State private var newPriority = "Medium"
    @State private var emailSent = false
    @State private var textSent = false
    @State private var approvalStatus = "Pending"

    var body: some View {
        NavigationView {
            taskList
                .navigationTitle("Tasks")
                .toolbar { toolbarButtons }
                .alert("Error", isPresented: $showingError) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("Task title cannot be empty.")
                }
                .sheet(isPresented: $showingAddTask) { addTaskSheet }
        }
    }

    var taskList: some View {
        List {
            ForEach(appState.tasks) { task in
                NavigationLink(destination: EditTaskView(task: task)) {
                    TaskRowView(task: task)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        appState.tasks.removeAll { $0.id == task.id }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading) {
                    Button {
                        if let index = appState.tasks.firstIndex(where: { $0.id == task.id }) {
                            appState.tasks[index].status = "Archived"
                        }
                    } label: {
                        Label("Archive", systemImage: "archivebox")
                    }
                    .tint(.orange)
                }
            }
        }
    }

    var toolbarButtons: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: { showingAddTask = true }) {
                Image(systemName: "plus")
            }
        }
    }

    var addTaskSheet: some View {
        TaskFormView(
            title: "New Task",
            taskTitle: $newTitle,
            notes: $newNotes,
            owner: $newOwner,
            dueDate: $newDueDate,
            priority: $newPriority,
            emailSent: $emailSent,
            textSent: $textSent,
            approvalStatus: $approvalStatus,
            onSave: {
                if newTitle.trimmingCharacters(in: .whitespaces).isEmpty {
                    showingError = true
                } else {
                    appState.tasks.append(Task(
                        title: newTitle,
                        notes: newNotes,
                        owner: newOwner,
                        status: "Pending",
                        priority: newPriority,
                        due_date: newDueDate,
                        approval_status: approvalStatus,
                        email_sent: emailSent,
                        text_sent: textSent
                   ))
                    showingAddTask = false
                    newTitle = ""
                    newNotes = ""
                    newOwner = ""
                }
            }
        )
    }
}

// Separate Edit View — fixes the Binding issue completely
struct EditTaskView: View {
    @EnvironmentObject var appState: AppState
    var task: Task

    var body: some View {
        if let index = appState.tasks.firstIndex(where: { $0.id == task.id }) {
            TaskFormView(
                title: "Edit Task",
                taskTitle: $appState.tasks[index].title,
                notes: $appState.tasks[index].notes,
                owner: $appState.tasks[index].owner,
                dueDate: $appState.tasks[index].due_date,
                priority: $appState.tasks[index].priority,
                emailSent: $appState.tasks[index].email_sent,
                textSent: $appState.tasks[index].text_sent,
                approvalStatus: $appState.tasks[index].approval_status,
                onSave: {}
            )
        }
    }
}

struct TaskRowView: View {
    var task: Task
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(task.title).font(.headline)
            HStack {
                Text(task.status).font(.caption).foregroundColor(.gray)
                Spacer()
                Text("Priority: \(task.priority)").font(.caption).foregroundColor(.orange)
            }
            HStack {
                Text(task.due_date, style: .date).font(.caption).foregroundColor(.red)
                Spacer()
                if task.email_sent { Image(systemName: "envelope.fill").foregroundColor(.blue).font(.caption) }
                if task.text_sent { Image(systemName: "message.fill").foregroundColor(.green).font(.caption) }
            }
        }
        .padding(.vertical, 5)
    }
}

struct TaskFormView: View {
    var title: String
    @Binding var taskTitle: String
    @Binding var notes: String
    @Binding var owner: String
    @Binding var dueDate: Date
    @Binding var priority: String
    @Binding var emailSent: Bool
    @Binding var textSent: Bool
    @Binding var approvalStatus: String
    var onSave: () -> Void

    let priorities = ["Low", "Medium", "High", "Critical"]
    let approvals = ["Pending", "Approved", "Rejected"]

    var body: some View {
        NavigationView {
            Form {
                Section("Task Details") {
                    TextField("Task Title", text: $taskTitle)
                    TextField("Owner", text: $owner)
                    TextField("Notes", text: $notes)
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                }
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(priorities, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Approval") {
                    Picker("Approval Status", selection: $approvalStatus) {
                        ForEach(approvals, id: \.self) { Text($0) }
                    }
                }
                Section("Follow Up") {
                    Toggle("Email Sent", isOn: $emailSent)
                    Toggle("Text Sent", isOn: $textSent)
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save", action: onSave)
                }
            }
        }
    }
}
