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
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    // MARK: - PersistenceService methods
    func getAllTasks() throws -> [TodoTask] {
        return try fetchTasks().map(convertTask)
    }
    
    func getSubtasks(for taskId: UUID) throws -> [TodoSubtask] {
        let fetchRequest = SubtaskTodo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "task.id == %@", taskId as NSUUID)

        let entities = try context.fetch(fetchRequest)
        return try entities.map(convertSubtask)
    }

    private func fetchTasks() throws -> [TaskTodo] {
        let fetchRequest = TaskTodo.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TaskTodo.dueDate, ascending: true)
        ]

        let entities = try context.fetch(fetchRequest)
        return entities
    }

    private func fetchTask(_ id: UUID) throws -> TaskTodo {
        let taskReq = TaskTodo.fetchRequest()
        taskReq.predicate = NSPredicate(format: "id == %@", id as NSUUID)
        taskReq.fetchLimit = 1
        guard let task = try context.fetch(taskReq).first
        else {
            throw PersistenceError.taskNotFound
        }
        return task
    }

    private func fetchSubtask(_ id: UUID) throws -> SubtaskTodo {
        let subtaskReq = SubtaskTodo.fetchRequest()
        subtaskReq.predicate = NSPredicate(format: "id == %@", id as NSUUID)
        subtaskReq.fetchLimit = 1
        guard let subtask = try context.fetch(subtaskReq).first
        else {
            throw PersistenceError.subtaskNotFound
        }
        return subtask
    }

    func addTask(_ task: TodoTask) throws {
        let newTask = TaskTodo(context: context)
        newTask.id = task.id
        newTask.name = task.name
        newTask.dueDate = task.dueDate
        newTask.isDone = task.isDone
        
        try saveContext()

    }

    private func convertTask(_ cdEntity: TaskTodo) throws -> TodoTask {
        guard let id = cdEntity.id
        else {
            throw PersistenceError.missingTaskID
        }
        let subtasks =
            try (cdEntity.subtasks as? Set<SubtaskTodo>)?
            .map(convertSubtask) ?? []

        return TodoTask(
            id: id,
            name: cdEntity.name ?? "",
            isDone: cdEntity.isDone,
            dueDate: cdEntity.dueDate ?? Date(),
            subtasks: subtasks
        )

    }

    func addSubtask(_ subtask: TodoSubtask, to task: TodoTask) throws {
        let task = try fetchTask(task.id)
        let newSubtask = SubtaskTodo(context: context)
        newSubtask.id = subtask.id
        newSubtask.name = subtask.name
        newSubtask.isDone = subtask.isDone
        newSubtask.task = task
        try saveContext()
    }

    private func convertSubtask(
        _ cdEntity: SubtaskTodo
    ) throws -> TodoSubtask {
        guard let id = cdEntity.id
        else {
            throw PersistenceError.missingSubtaskID
        }
        return TodoSubtask(
            id: id,
            name: cdEntity.name ?? "",
            isDone: cdEntity.isDone
        )
    }

    func deleteTask(_ task: TodoTask) throws {
        let task = try fetchTask(task.id)
        context.delete(task)
        try saveContext()
    }

    func toggleTaskDone(_ task: TodoTask) throws {
        let task = try fetchTask(task.id)
        task.isDone.toggle()
        try saveContext()
    }

    func deleteSubtask(_ subtask: TodoSubtask) throws {
        let subtask = try fetchSubtask(subtask.id)
        context.delete(subtask)
        try saveContext()
    }

    func toggleSubtaskDone(_ subtask: TodoSubtask) throws {
        let subtask = try fetchSubtask(subtask.id)
        subtask.isDone.toggle()
        try saveContext()
    }

}
