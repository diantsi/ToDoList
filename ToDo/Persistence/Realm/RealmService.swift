//
//  RealmService.swift
//  ToDo
//
//  Created by Діана Цісарук on 13.10.2026.
//
import RealmSwift
import Foundation
import Realm

class RealmService: PersistenceService {

    private let realm: Realm

    init() {
        guard let realm = try? Realm()
        else {
            fatalError("Failed to load persistent stores")
        }
        self.realm = realm
    }

    func getAllTasks() throws -> [TodoTask] {
        let taskEntities = realm.objects(RealmTask.self).sorted(
            byKeyPath: "dueDate",
            ascending: true
        )
        return taskEntities.map(convertTask)
    }

    private func convertTask(realmTask: RealmTask) -> TodoTask {
        let subtasks = Array(realmTask.subtasks.map(convertSubtask))
        return TodoTask(
            id: realmTask.id,
            name: realmTask.name,
            isDone: realmTask.isDone,
            dueDate: realmTask.dueDate,
            subtasks: subtasks
        )
    }

    private func convertSubtask(realmSubTask: RealmSubtask) -> TodoSubtask {
        return TodoSubtask(
            id: realmSubTask.id,
            name: realmSubTask.name,
            isDone: realmSubTask.isDone
        )
    }

    func addTask(_ task: TodoTask) throws {
        let taskEntity = RealmTask()
        taskEntity.id = task.id
        taskEntity.name = task.name
        taskEntity.isDone = task.isDone
        taskEntity.dueDate = task.dueDate
        try realm.write {
            realm.add(taskEntity)
        }

    }

    func deleteTask(_ task: TodoTask) throws {
        guard
            let taskToDelete =
                realm
                .objects(RealmTask.self)
                .where({ $0.id == task.id })
                .first
        else {
            throw PersistenceError.taskNotFound
        }
        try realm.write {
            realm.delete(taskToDelete.subtasks)
            realm.delete(taskToDelete)
        }
    }

    func toggleTaskDone(_ task: TodoTask) throws {
        guard
            let taskToUpdate =
                realm
                .objects(RealmTask.self)
                .where({ $0.id == task.id })
                .first
        else {
            throw PersistenceError.taskNotFound
        }
        try realm.write {
            taskToUpdate.isDone.toggle()
        }
    }

    func getSubtasks(for taskId: UUID) throws -> [TodoSubtask] {
        guard
            let parentTask =
                realm
                .objects(RealmTask.self)
                .where({ $0.id == taskId })
                .first
        else {
            throw PersistenceError.taskNotFound
        }
        let subtasks = parentTask.subtasks
        return subtasks.map(convertSubtask)
    }

    func addSubtask(_ subtask: TodoSubtask, to task: TodoTask) throws {
        guard
            let parentTask =
                realm
                .objects(RealmTask.self)
                .where({ $0.id == task.id })
                .first
        else {
            throw PersistenceError.taskNotFound
        }
        let subtaskEntity = RealmSubtask()
        subtaskEntity.id = subtask.id
        subtaskEntity.name = subtask.name
        subtaskEntity.isDone = subtask.isDone
        try realm.write {
            realm.add(subtaskEntity)
            parentTask.subtasks.append(subtaskEntity)
        }
    }

    func deleteSubtask(_ subtask: TodoSubtask) throws {
        guard
            let subtaskToDelete =
                realm
                .objects(RealmSubtask.self)
                .where({ $0.id == subtask.id })
                .first
        else {
            throw PersistenceError.subtaskNotFound
        }
        try realm.write {
            realm.delete(subtaskToDelete)
        }
    }

    func toggleSubtaskDone(_ subtask: TodoSubtask) throws {
        guard
            let subtaskToUpdate =
                realm
                .objects(RealmSubtask.self)
                .where({ $0.id == subtask.id })
                .first
        else {
            throw PersistenceError.subtaskNotFound
        }
        try realm.write {
            subtaskToUpdate.isDone.toggle()
        }
    }

}
