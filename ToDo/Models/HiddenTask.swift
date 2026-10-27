//
//  HiddenTask.swift
//  ToDo
//
//  Created by Діана Цісарук on 25.10.2026.
//

import Foundation

struct HiddenTask : ReminderItem {
    let id: UUID
    var name: String = "приховане повідомлення"
    var dueDate: Date
    var needToNotify: Bool = false

    init(
        id: UUID = UUID(),
        dueDate: Date,
        needToNotify: Bool = false
    ) {
        self.id = id
        self.dueDate = dueDate
        self.needToNotify = needToNotify
    }
    
    
}
