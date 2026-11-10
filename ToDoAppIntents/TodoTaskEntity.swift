//
//  TodoTaskEntity.swift
//  ToDo
//
//  Created by Діана Цісарук on 10.11.2026.
import AppIntents

struct TodoTaskEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Невиконані завдання"
    static let defaultQuery = TodoTaskQuery()

    let id: UUID
    @Property(title: "назва")
    var title: String
    @Property(title: "дедлайн")
    var dueDate: Date
    
    init(id: UUID, title: String, dueDate: Date) {
        self.id = id
        self.title = title
        self.dueDate = dueDate
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)",
                              subtitle: "До \(dueDate.formatted(date: .abbreviated, time: .shortened))")
    }
}

struct TodoTaskQuery: EntityQuery {
    func entities(for ids: [UUID]) async throws
     -> [TodoTaskEntity] {
         return ids.compactMap { id in
           guard let task = try? PersistenceServiceProvider.shared.getTaskById(id: id)
                    else {
               return nil
           }
             return TodoTaskEntity(id: task.id, title: task.name, dueDate: task.dueDate)
         }
     }
     func suggestedEntities() async throws
     -> [TodoTaskEntity] {
          let pendingTask = try PersistenceServiceProvider.shared.getPendingTasks(limit: 10)
         return pendingTask.map { task in
             return TodoTaskEntity(id: task.id, title: task.name, dueDate: task.dueDate)
         }

     }
}
