//
//  TodoTask.swift
//  ToDo
//
//  Created by Діана Цісарук on 12.10.2026.
//
import Foundation

struct TodoTask: ReminderItem, Codable {
    let id: UUID
    var name: String
    var isDone: Bool
    var dueDate: Date
    var subtasks: [TodoSubtask]
    var needToNotify: Bool = false
    var isHidden: Bool = false

    init(
        id: UUID = UUID(),
        name: String,
        isDone: Bool = false,
        dueDate: Date,
        subtasks: [TodoSubtask] = [],
        needToNotify: Bool = false,
        isHidden: Bool = false
    ) {
        self.id = id
        self.name = name
        self.isDone = isDone
        self.dueDate = dueDate
        self.subtasks = subtasks
        self.needToNotify = needToNotify
        self.isHidden = isHidden
    }

    var hiddenTask: TodoTask {
        TodoTask(
            id: id,
            name: "приховане повідомлення",
            isDone: isDone,
            dueDate: dueDate,
            subtasks: subtasks,
            needToNotify: needToNotify,
            isHidden: true
        )
    }
}
