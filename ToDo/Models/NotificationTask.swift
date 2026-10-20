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
}

enum NotificationStatus: String {
    case pending
    case accepted
    case declined
}
