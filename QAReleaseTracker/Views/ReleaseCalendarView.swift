import SwiftUI

struct Release: Identifiable, Codable {
    var id: UUID = UUID()
    var user_id: UUID? = nil
    var title: String
    var notes: String
    var owner: String
    var status: String
    var deployment_date: Date
}

struct ReleaseCalendarView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingAddRelease = false
    @State private var newTitle = ""
    @State private var newOwner = ""
    @State private var newNotes = ""
    @State private var newDate = Date()
    @State private var newStatus = "On Track"
    @State private var showingError = false

    let statuses = ["On Track", "In Progress", "Medium", "Critical"]

    func statusColor(_ status: String) -> Color {
        switch status {
        case "Critical": return .red
        case "Medium": return .orange
        case "On Track": return .green
        case "In Progress": return .blue
        default: return .gray
        }
    }

    var groupedByMonth: [String: [Release]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return Dictionary(grouping: appState.releases) { formatter.string(from: $0.deployment_date) }
    }

    var sortedMonths: [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return groupedByMonth.keys.sorted {
            (formatter.date(from: $0) ?? Date()) < (formatter.date(from: $1) ?? Date())
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(sortedMonths, id: \.self) { month in
                    Section(header:
                        Text(month)
                            .font(.headline)
                            .foregroundColor(.blue)
                            .bold()
                    ) {
                        ForEach(groupedByMonth[month] ?? []) { release in
                            ReleaseRowView(release: release, statusColor: statusColor(release.status))
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Release Calendar")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddRelease = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Release title cannot be empty.")
            }
            .sheet(isPresented: $showingAddRelease) {
                NavigationView {
                    Form {
                        Section("Release Details") {
                            TextField("Release Title", text: $newTitle)
                            TextField("Owner", text: $newOwner)
                            TextField("Notes", text: $newNotes)
                            DatePicker("Deployment Date", selection: $newDate, displayedComponents: .date)
                        }
                        Section("Status") {
                            Picker("Status", selection: $newStatus) {
                                ForEach(statuses, id: \.self) { status in
                                    Text(status).tag(status)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    .navigationTitle("New Release")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Save") {
                                if newTitle.trimmingCharacters(in: .whitespaces).isEmpty {
                                    showingError = true
                                } else {
                                    appState.releases.append(Release(
                                        title: newTitle,
                                        notes: newNotes,
                                        owner: newOwner,
                                        status: newStatus,
                                        deployment_date: newDate
                                    ))
                                    newTitle = ""
                                    newOwner = ""
                                    newNotes = ""
                                    showingAddRelease = false
                                }
                            }
                        }
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") { showingAddRelease = false }
                        }
                    }
                }
            }
        }
    }
}

struct ReleaseRowView: View {
    var release: Release
    var statusColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(release.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text(release.status)
                    .font(.caption)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor)
                    .cornerRadius(8)
            }
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                Text(release.deployment_date, style: .date)
                    .font(.caption)
                    .foregroundColor(.blue)
                Spacer()
                if !release.owner.isEmpty {
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                    Text(release.owner)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            if !release.notes.isEmpty {
                Text(release.notes)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}
