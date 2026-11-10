//
//  AddTaskIntent.swift
//  ToDo
//
//  Created by Діана Цісарук on 10.11.2026.
//
import AppIntents
import WidgetKit

struct AddTaskIntent: AppIntent {
    static var title: LocalizedStringResource { "Створити завдання" }
    
    @Parameter(title: "Назва")
    var taskTitle: String

    @Parameter(title: "Дедлайн")
    var dueDate: Date
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let task = TodoTask(name: taskTitle, dueDate: dueDate)
        try PersistenceServiceProvider.shared.addTask(task)
        
        WidgetTaskUpdater.didTaskChange()
        return .result(dialog: "Завдання «\(taskTitle)» додано")
    }
}
