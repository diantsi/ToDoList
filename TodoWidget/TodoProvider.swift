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
            return try persistenceService.getPendingTasks(limit: 4)
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
        let curDate = Date()
        let tasks = dueTasks
        let entry = TodoEntry(date: curDate, tasks: dueTasks)
        
        let updateTime = tasks
            .map(\.dueDate)
            .filter { $0 > curDate }
            .min()?
            .addingTimeInterval(1)
            ?? curDate.addingTimeInterval(6 * 60)
        
        completion(Timeline(entries: [entry], policy: .after(updateTime)))
    }
}
