//
//  PersistenceService.swift
//  ToDo
//
//  Created by Діана Цісарук on 12.10.2026.
//
import Foundation

protocol PersistenceService {
    
    // MARK: - Tasks
    func getAllTasks(isHidden: Bool) throws -> [TodoTask]
    func addTask(_ task: TodoTask) throws
    func deleteTask(id: UUID) throws
    func toggleTaskDone(id: UUID) throws
    func setTaskNotificationEnabled(_ isEnabled: Bool, for taskId: UUID) throws
    
    func getPendingTasks(limit: Int) throws -> [TodoTask]
    func getTaskById(id: UUID) throws -> TodoTask

//    // MARK: - Subtasks
    func getSubtasks(for taskId: UUID) throws -> [TodoSubtask]
    func addSubtask(_ subtask: TodoSubtask, to task: TodoTask) throws
    func deleteSubtask(id: UUID) throws
    func toggleSubtaskDone(id: UUID) throws
    func setSubtaskNotificationEnabled(
        _ isEnabled: Bool,
        for subtaskId: UUID
    ) throws

    // MARK: - Received notifications
    func getAllNotificationTasks() throws -> [NotificationTask]
    func addNotificationTask(_ notificationTask: NotificationTask) throws
    func setNotificationTaskStatus(
        _ status: NotificationStatus,
        for notificationId: String
    ) throws
}

