//
//  NotificationTask.swift
//  ToDo
//
//  Created by Діана Цісарук on 19.10.2026.
//
import Foundation

struct NotificationTask {
    let id: String
    let title: String
    let body: String
    let dueDate: Date
    let status: NotificationStatus
    let receivedAt: Date

    var taskName: String {
        var taskname = ""
        let trimmedTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        if !trimmedTitle.isEmpty {
            taskname.append("\(trimmedTitle), ")
        }

        taskname.append(body.trimmingCharacters(in: .whitespacesAndNewlines))
        return taskname
    }
}

enum NotificationStatus: String {
    case pending
    case accepted
    case declined
}
