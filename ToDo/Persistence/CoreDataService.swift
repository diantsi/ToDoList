//
//  CoreDataService.swift
//  ToDo
//
//  Created by Діана Цісарук on 07.10.2026.
//

import CoreData

class CoreDataService: PersistenceService {

    private let persistentContainer: NSPersistentContainer
    private let context: NSManagedObjectContext

    init() {
        persistentContainer = NSPersistentContainer(name: "ToDo")
        persistentContainer.loadPersistentStores {
            (_, error) in

            if let error = error as? NSError {
                fatalError(
                    "Failed to load persistent stores: \(error.localizedDescription)"
                )
            }
        }
        context = persistentContainer.viewContext
    }

    func saveContext() throws {
        guard context.hasChanges else { return }
        try context.save()
    }

    // MARK: - PersistenceService methods

    func fetchTasks() throws -> [TodoTask] {
        let fetchRequest = TaskTodo.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TaskTodo.dueDate, ascending: true)
        ]

        let entities = try context.fetch(fetchRequest)

        return entities.map { convertTask($0) }
    }
    
    func addTask(_ task: TodoTask) throws {
        let newTask = TaskTodo(context: context)
        newTask.name = task.name
        newTask.dueDate = task.dueDate
        newTask.isDone = task.isDone
        
        for subtask in task.subtasks {
            let newSubtask = SubtaskTodo(context: context)
            newSubtask.name = subtask.name
            newSubtask.isDone = subtask.isDone
            newSubtask.task = newTask
        }
        
        try saveContext()

    }
    

    private func convertTask(_ cdEntity: TaskTodo) -> TodoTask {
        return TodoTask(
            name: cdEntity.name ?? "",
            isDone: cdEntity.isDone,
            dueDate: cdEntity.dueDate ?? Date(),
            subtasks: (cdEntity.subtasks as? Set<SubtaskTodo>)?
                .compactMap { convertSubtask($0) } ?? []
        )

    }

    private func convertSubtask(
        _ cdEntity: SubtaskTodo
    ) -> TodoSubtask? {
        return TodoSubtask(
            name: cdEntity.name ?? "",
            isDone: cdEntity.isDone
        )
    }


//    func deleteTask(_ task: TodoTask) throws {
//        <#code#>
//    }
//
//    func markTaskAsDone(_ task: TodoTask) throws {
//        <#code#>
//    }
//
//    func addSubtask(_ subtask: TodoSubtask, to task: TodoTask) throws {
//        <#code#>
//    }
//
//    func deleteSubtask(_ subtask: TodoSubtask) throws {
//        <#code#>
//    }
//
//    func markSubtaskAsDone(_ subtask: TodoSubtask) throws {
//        <#code#>
//    }

}
