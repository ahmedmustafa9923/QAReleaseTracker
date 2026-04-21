//
//  AppState.swift
//  QAReleaseTracker
//
//  Created by GermanDriveM on 4/20/26.
//

import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var releases: [Release] = []
    
    var overdueTasks: [Task] {
        tasks.filter { $0.dueDate < Date() && $0.status != "Completed" && $0.status != "Archived" }
    }
    
    var overdueReleases: [Release] {
        releases.filter { $0.date < Date() && $0.status != "On Track" }
    }
    
    var totalOverdue: Int {
        overdueTasks.count + overdueReleases.count
    }
}
