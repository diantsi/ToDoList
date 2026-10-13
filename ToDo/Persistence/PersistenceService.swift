//
//  PersistenceService.swift
//  ToDo
//
//  Created by Діана Цісарук on 12.10.2026.
//

protocol PersistenceService {
    
    // MARK: - Tasks
    func fetchTasks() throws -> [TodoTask]
    func addTask(_ task: TodoTask) throws
    func deleteTask(_ task: TodoTask) throws
    func toggleTaskDone(_ task: TodoTask) throws
//
//    // MARK: - Subtasks
//    func addSubtask(_ subtask: TodoSubtask, to task: TodoTask) throws
//    func deleteSubtask(_ subtask : TodoSubtask) throws
//    func markSubtaskAsDone(_ subtask : TodoSubtask) throws
}
