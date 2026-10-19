//
//  PersistenceService.swift
//  ToDo
//
//  Created by Діана Цісарук on 12.10.2026.
//
import Foundation

protocol PersistenceService {
    
    // MARK: - Tasks
    func getAllTasks() throws -> [TodoTask]
    func addTask(_ task: TodoTask) throws
    func deleteTask(_ task: TodoTask) throws
    func toggleTaskDone(_ task: TodoTask) throws
    func setTaskNotificationEnabled(_ isEnabled: Bool, for taskId: UUID) throws

//    // MARK: - Subtasks
    func getSubtasks(for taskId: UUID) throws -> [TodoSubtask]
    func addSubtask(_ subtask: TodoSubtask, to task: TodoTask) throws
    func deleteSubtask(_ subtask : TodoSubtask) throws
    func toggleSubtaskDone(_ subtask : TodoSubtask) throws
    func setSubtaskNotificationEnabled(
        _ isEnabled: Bool,
        for subtaskId: UUID
    ) throws
}
