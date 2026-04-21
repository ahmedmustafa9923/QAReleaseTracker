//
//  Task.swift
//  QAReleaseTracker
//
//  Created by GermanDriveM on 4/20/26.
//
import Foundation

struct Task: Identifiable {
    var id = UUID()
    var title: String
    var dueDate: Date
    var status: String
    var priority: String
    var notes: String
    var owner: String
    var approvalStatus: String
    var emailSent: Bool
    var textSent: Bool
}
