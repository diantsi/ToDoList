//
//  Reminder.swift
//  ToDo
//
//  Created by Діана Цісарук on 16.10.2026.
//
import Foundation

protocol ReminderItem {
    var id: UUID { get }
    var name: String { get }
    var dueDate: Date { get }
    var needToNotify: Bool { get }
}

extension ReminderItem {
    var notificationId: String {
        "notification.\(id.uuidString)"
    }
}
