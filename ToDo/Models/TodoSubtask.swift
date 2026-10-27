//
//  TodoSubtask.swift
//  ToDo
//
//  Created by Діана Цісарук on 12.10.2026.
//
import Foundation

struct TodoSubtask: ReminderItem, Codable {
    let id: UUID
    var name: String
    var isDone: Bool
    var dueDate: Date
    var needToNotify: Bool

    init(
        id: UUID = UUID(),
        name: String,
        isDone: Bool = false,
        dueDate: Date,
        needToNotify: Bool = false
    ) {
        self.id = id
        self.name = name
        self.isDone = isDone
        self.dueDate = dueDate
        self.needToNotify = needToNotify
    }

}
