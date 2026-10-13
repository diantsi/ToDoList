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

        return try entities.map(convertTask)
    }
    
    func addTask(_ task: TodoTask) throws {
        let newTask = TaskTodo(context: context)
        newTask.id = task.id
        newTask.name = task.name
        newTask.dueDate = task.dueDate
        newTask.isDone = task.isDone
        
        for subtask in task.subtasks {
            let newSubtask = SubtaskTodo(context: context)
            newSubtask.id = subtask.id
            newSubtask.name = subtask.name
            newSubtask.isDone = subtask.isDone
            newSubtask.task = newTask
        }
        
        try saveContext()

    }
    

    private func convertTask(_ cdEntity: TaskTodo) throws -> TodoTask {
        guard let id = cdEntity.id
                else {
            throw PersistenceError.missingTaskID
        }
        let subtasks = try (cdEntity.subtasks as? Set<SubtaskTodo>)?
               .map(convertSubtask) ?? []
        
        return TodoTask(
            id: id,
            name: cdEntity.name ?? "",
            isDone: cdEntity.isDone,
            dueDate: cdEntity.dueDate ?? Date(),
            subtasks: subtasks
        )

    }

    private func convertSubtask(
        _ cdEntity: SubtaskTodo
    ) throws -> TodoSubtask {
        guard let id = cdEntity.id
                else {
            throw PersistenceError.missingTaskID
        }
        return TodoSubtask(
            id: id,
            name: cdEntity.name ?? "",
            isDone: cdEntity.isDone
        )
    }


    func deleteTask(_ task: TodoTask) throws {
        let taskToDeleteReq = TaskTodo.fetchRequest()
        taskToDeleteReq.predicate = NSPredicate(format: "id == %@", task.id as NSUUID)
        taskToDeleteReq.fetchLimit = 1
        guard let taskToDelete = try context.fetch(taskToDeleteReq).first
                else {
            throw PersistenceError.taskNotFound
        }
        context.delete(taskToDelete)
        try saveContext()
    }

    func toggleTaskDone(_ task: TodoTask) throws {
        let taskToUpdateReq = TaskTodo.fetchRequest()
        taskToUpdateReq.predicate = NSPredicate(format: "id == %@", task.id as NSUUID)
        taskToUpdateReq.fetchLimit = 1
        guard let taskToUpdate = try context.fetch(taskToUpdateReq).first
                else {
            throw PersistenceError.taskNotFound
        }
        taskToUpdate.isDone.toggle()
        try saveContext()
    }
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
