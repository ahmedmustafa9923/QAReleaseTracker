import SwiftUI

struct TasksView: View {
    @State private var tasks: [Task] = []
    @State private var showingAddTask = false
    @State private var showingEditTask = false
    @State private var selectedTask: Task?
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
                .sheet(isPresented: $showingEditTask) { editTaskSheet }
        }
    }

    var taskList: some View {
        List {
            ForEach(tasks) { task in
                NavigationLink(destination: {
                    if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                        TaskFormView(
                            title: "Edit Task",
                            taskTitle: $tasks[index].title,
                            notes: $tasks[index].notes,
                            owner: $tasks[index].owner,
                            dueDate: $tasks[index].dueDate,
                            priority: $tasks[index].priority,
                            emailSent: $tasks[index].emailSent,
                            textSent: $tasks[index].textSent,
                            approvalStatus: $tasks[index].approvalStatus,
                            onSave: {}
                        )
                    }
                }) {
                    TaskRowView(task: task)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        tasks.removeAll { $0.id == task.id }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading) {
                    Button {
                        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                            tasks[index].status = "Archived"
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
                    tasks.append(Task(
                        title: newTitle,
                        dueDate: newDueDate,
                        status: "Pending",
                        priority: newPriority,
                        notes: newNotes,
                        owner: newOwner,
                        approvalStatus: approvalStatus,
                        emailSent: emailSent,
                        textSent: textSent
                    ))
                    showingAddTask = false
                    newTitle = ""
                    newNotes = ""
                    newOwner = ""
                }
            }
        )
    }

    var editTaskSheet: some View {
        Group {
            if let task = selectedTask,
               let index = tasks.firstIndex(where: { $0.id == task.id }) {
                TaskFormView(
                    title: "Edit Task",
                    taskTitle: $tasks[index].title,
                    notes: $tasks[index].notes,
                    owner: $tasks[index].owner,
                    dueDate: $tasks[index].dueDate,
                    priority: $tasks[index].priority,
                    emailSent: $tasks[index].emailSent,
                    textSent: $tasks[index].textSent,
                    approvalStatus: $tasks[index].approvalStatus,
                    onSave: { showingEditTask = false }
                )
            }
        }
    }

    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
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
                Text(task.dueDate, style: .date).font(.caption).foregroundColor(.red)
                Spacer()
                if task.emailSent { Image(systemName: "envelope.fill").foregroundColor(.blue).font(.caption) }
                if task.textSent { Image(systemName: "message.fill").foregroundColor(.green).font(.caption) }
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
