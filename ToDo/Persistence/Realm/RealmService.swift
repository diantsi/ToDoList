//
//  RealmService.swift
//  ToDo
//
//  Created by Діана Цісарук on 13.10.2026.
//
import RealmSwift
import Foundation
import Realm


enum RealmMigrationManager {

    private nonisolated static let schemaVersion: UInt64 = 3

    nonisolated static var configuration: Realm.Configuration {
        Realm.Configuration(
            schemaVersion: schemaVersion,
            migrationBlock: migrate
        )
    }

    private nonisolated static func migrate(
        migration: Migration,
        oldSchemaVersion: UInt64
    ) {
        if oldSchemaVersion < 1 {
            migration.enumerateObjects(
                ofType: RealmTask.className()
            ) { _, newObject in
                newObject?["needToNotify"] = false
            }
        }

        if oldSchemaVersion < 2 {
            migration.enumerateObjects(
                ofType: RealmSubtask.className()
            ) { _, newObject in
                newObject?["dueDate"] = Date()
                newObject?["needToNotify"] = false
            }
        }
    }
}

class RealmService: PersistenceService {

    private let realm: Realm
    
    init() {
        guard let realm = try? Realm(configuration: RealmMigrationManager.configuration)
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
            subtasks: subtasks,
            needToNotify: realmTask.needToNotify
        )
    }

    private func convertSubtask(realmSubTask: RealmSubtask) -> TodoSubtask {
        return TodoSubtask(
            id: realmSubTask.id,
            name: realmSubTask.name,
            isDone: realmSubTask.isDone,
            dueDate: realmSubTask.dueDate,
            needToNotify: realmSubTask.needToNotify
        )
    }

    func addTask(_ task: TodoTask) throws {
        let taskEntity = RealmTask()
        taskEntity.id = task.id
        taskEntity.name = task.name
        taskEntity.isDone = task.isDone
        taskEntity.dueDate = task.dueDate
        taskEntity.needToNotify = task.needToNotify
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

    func setTaskNotificationEnabled(
        _ isEnabled: Bool,
        for taskId: UUID
    ) throws {
        guard
            let taskToUpdate = realm
                .objects(RealmTask.self)
                .where({ $0.id == taskId })
                .first
        else {
            throw PersistenceError.taskNotFound
        }

        try realm.write {
            taskToUpdate.needToNotify = isEnabled
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
        subtaskEntity.dueDate = subtask.dueDate
        subtaskEntity.needToNotify = subtask.needToNotify
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

    func setSubtaskNotificationEnabled(
        _ isEnabled: Bool,
        for subtaskId: UUID
    ) throws {
        guard
            let subtaskToUpdate = realm
                .objects(RealmSubtask.self)
                .where({ $0.id == subtaskId })
                .first
        else {
            throw PersistenceError.subtaskNotFound
        }

        try realm.write {
            subtaskToUpdate.needToNotify = isEnabled
        }
    }

    // MARK: - Received notifications

    func getAllNotificationTasks() throws -> [NotificationTask] {
        realm.objects(RealmNotificationTask.self)
            .sorted(byKeyPath: "receivedAt", ascending: false)
            .map(convertNotificationTask)
    }

    func addNotificationTask(
        _ notificationTask: NotificationTask
    ) throws {
        guard realm.object(
            ofType: RealmNotificationTask.self,
            forPrimaryKey: notificationTask.id
        ) == nil else {
            return
        }

        let entity = RealmNotificationTask()
        entity.id = notificationTask.id
        entity.title = notificationTask.title
        entity.body = notificationTask.body
        entity.dueDate = notificationTask.dueDate
        entity.status = notificationTask.status.rawValue
        entity.receivedAt = notificationTask.receivedAt

        try realm.write {
            realm.add(entity)
        }
    }

    func setNotificationTaskStatus(
        _ status: NotificationStatus,
        for notificationId: String
    ) throws {
        guard let entity = realm.object(
            ofType: RealmNotificationTask.self,
            forPrimaryKey: notificationId
        ) else {
            throw PersistenceError.notificationTaskNotFound
        }

        try realm.write {
            entity.status = status.rawValue
        }
    }

    private func convertNotificationTask(
        _ entity: RealmNotificationTask
    ) -> NotificationTask {
        NotificationTask(
            id: entity.id,
            title: entity.title,
            body: entity.body,
            dueDate: entity.dueDate,
            status: NotificationStatus(rawValue: entity.status) ?? .pending,
            receivedAt: entity.receivedAt
        )
    }

}
