//
//  TodoTask.swift
//  ToDo
//
//  Created by Діана Цісарук on 12.10.2026.
//
import Foundation

struct TodoTask {
    let id: UUID
    var name: String
    var isDone: Bool
    var dueDate: Date
    var subtasks: [TodoSubtask]

    init(
        id: UUID = UUID(),
        name: String,
        isDone: Bool = false,
        dueDate: Date,
        subtasks: [TodoSubtask] = []
    ) {
        self.id = id
        self.name = name
        self.isDone = isDone
        self.dueDate = dueDate
        self.subtasks = subtasks
    }
}
