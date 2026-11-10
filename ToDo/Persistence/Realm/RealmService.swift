import Foundation
import Realm
//
//  RealmService.swift
//  ToDo
//
//  Created by Діана Цісарук on 13.10.2026.
//
import RealmSwift

class RealmService: PersistenceService {
    

    private let realm: Realm

    init() {
        guard
            let realm = try? Realm(
                configuration: RealmMigrationManager.configuration
            )
        else {
            fatalError("Failed to load persistent stores")
        }
        self.realm = realm
    }

    func getAllTasks(isHidden: Bool) throws -> [TodoTask] {
        let taskEntities = realm.objects(RealmTask.self)
            .filter("isHidden == %@", isHidden)
            .sorted(
                byKeyPath: "dueDate",
                ascending: true
            )
        return taskEntities.map(convertTask)
    }
    
    func getPendingTasks(limit: Int) throws -> [TodoTask] {
        var result: [RealmTask] = []
        let taskEntities = realm.objects(RealmTask.self)
            .filter("isDone == %@", false)
            .sorted(
                byKeyPath: "dueDate",
                ascending: true
            )
        for i in (0...2) {
            result[i] = taskEntities[i]
        }
        return result.map(convertTask)
    }

    func getTaskById(id: UUID) throws -> TodoTask {
        guard let taskEntity = realm.objects(RealmTask.self)
            .filter("id == %@", id)
            .first
                else {
            throw PersistenceError.missingTaskID
        }
        return convertTask(realmTask: taskEntity)
    }

    private func convertTask(realmTask: RealmTask) -> TodoTask {
        let subtasks = Array(realmTask.subtasks.map(convertSubtask))
        return TodoTask(
            id: realmTask.id,
            name: realmTask.name,
            isDone: realmTask.isDone,
            dueDate: realmTask.dueDate,
            subtasks: subtasks,
            needToNotify: realmTask.needToNotify,
            isHidden: realmTask.isHidden
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
        taskEntity.isHidden = task.isHidden
        try realm.write {
            realm.add(taskEntity)
        }

    }

    func deleteTask(id: UUID) throws {
        guard
            let taskToDelete =
                realm
                .objects(RealmTask.self)
                .where({ $0.id == id })
                .first
        else {
            throw PersistenceError.taskNotFound
        }
        try realm.write {
            realm.delete(taskToDelete.subtasks)
            realm.delete(taskToDelete)
        }
    }

    func toggleTaskDone(id: UUID) throws {
        guard
            let taskToUpdate =
                realm
                .objects(RealmTask.self)
                .where({ $0.id == id })
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
            let taskToUpdate =
                realm
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

    func deleteSubtask(id: UUID) throws {
        guard
            let subtaskToDelete =
                realm
                .objects(RealmSubtask.self)
                .where({ $0.id == id })
                .first
        else {
            throw PersistenceError.subtaskNotFound
        }
        try realm.write {
            realm.delete(subtaskToDelete)
        }
    }

    func toggleSubtaskDone(id: UUID) throws {
        guard
            let subtaskToUpdate =
                realm
                .objects(RealmSubtask.self)
                .where({ $0.id == id })
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
            let subtaskToUpdate =
                realm
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
        let existingEntity = realm.objects(RealmNotificationTask.self)
            .filter("id == %@", notificationTask.id)
            .first

        guard existingEntity == nil else {
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
        let entity = realm.objects(RealmNotificationTask.self)
            .filter("id == %@", notificationId)
            .first

        guard let entity else {
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
