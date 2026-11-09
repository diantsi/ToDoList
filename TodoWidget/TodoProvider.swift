//
//  TodoProvider.swift
//  ToDo
//
//  Created by Діана Цісарук on 09.11.2026.
//

import WidgetKit

class TodoProvider: TimelineProvider {
    
    let persistenceService: PersistenceService
        
    init() {
        persistenceService = PersistenceServiceProvider.shared
    }
    
    private var dueTasks : [TodoTask] {
        do {
            //todo: write method for getting 3 pending task
            return try persistenceService.getPendingTasks(limit: 3)
        } catch {
            return []
        }
    }
    
    private var mockTasks : [TodoTask] {
        return [
            TodoTask(name: "полити вазони", dueDate: Date()),
            TodoTask(name: "погодувати котика", dueDate: Date())
        ]
    }
    
    
    func placeholder(in context: Context) -> TodoEntry {
        TodoEntry(date: Date(), tasks: [])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TodoEntry) -> Void) {
        completion(TodoEntry(date: Date(), tasks: mockTasks))
        
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<TodoEntry>) -> Void) {
         let entry = TodoEntry(date: Date(), tasks: dueTasks)
        completion(Timeline(entries: [entry], policy: .never))
    }
}
