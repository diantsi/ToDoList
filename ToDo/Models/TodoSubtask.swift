//
//  TodoSubtask.swift
//  ToDo
//
//  Created by Діана Цісарук on 12.10.2026.
//
import Foundation

struct TodoSubtask {
    let id: UUID
    var name: String
    var isDone: Bool

    init(
        id: UUID = UUID(),
        name: String,
        isDone: Bool = false,
    ) {
        self.id = id
        self.name = name
        self.isDone = isDone
    }
}
