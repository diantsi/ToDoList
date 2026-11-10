//
//  ToDoAppIntents.swift
//  ToDoAppIntents
//
//  Created by Діана Цісарук on 10.11.2026.
//

import AppIntents
import WidgetKit

struct CompleteTaskIntent: AppIntent {
    static var title: LocalizedStringResource { "Виконати завдання" }
    
    @Parameter(title: "Завдання")
    var task: TodoTaskEntity
    
    func perform() async throws -> some IntentResult {
        let currentTask = try PersistenceServiceProvider.shared.getTaskById(id: task.id)
        try PersistenceServiceProvider.shared.toggleTaskDone(id: currentTask.id)
        WidgetTaskUpdater.didTaskChange()
        return .result()
    }
}
