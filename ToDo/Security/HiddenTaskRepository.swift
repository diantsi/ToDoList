//
//  TodoTaskRepository.swift
//  ToDo
//
//  Created by Діана Цісарук on 25.10.2026.
//
import Foundation

final class HiddenTaskRepository {

    let service = "hidden.task.service"

    let keychainService: KeychainService
    let biometricService: BiometricAuthService
    let persistenceService: PersistenceService
    let notificationService: UserNotificationsService
    
    init() {
        keychainService = KeychainService(service: service)
        biometricService = BiometricAuthService()
        persistenceService = PersistenceServiceProvider.shared
        notificationService = UserNotificationsService.shared
    }

    func saveTodo(todo: TodoTask) async throws {
        let account = todo.id.uuidString
        let data = try JSONEncoder().encode(todo.name)
        try keychainService.save(data: data, account: account)
        let hiddenTask = todo.hiddenTask
        try persistenceService.addTask(hiddenTask)
        if hiddenTask.needToNotify {
            try await notificationService.sendNotification(with: hiddenTask)
        }
    }

    func readTodos() async throws -> [TodoTask] {
        try await biometricService.authenticate()
        
        let keychainData = try keychainService.readAll()
        let hiddenTasks = try persistenceService.getAllTasks(isHidden: true)

        var namesByID: [UUID: String] = [:]
        
        for item in keychainData {
            guard let id = UUID(uuidString: item.account)
                    else {
                throw KeychainError.cannotReturnData
            }
            let name = try JSONDecoder().decode(String.self, from: item.data)
            namesByID[id] = name
        }
        
        return hiddenTasks.compactMap { hiddenTask in
            guard let unlockedName = namesByID[hiddenTask.id]
                    else {
                print("name for task with id \(hiddenTask.id) doesn`t exist")
                return nil
            }
            var unlockedTask = hiddenTask
            unlockedTask.name = unlockedName
            return unlockedTask
        }
    }
    
    func deleteTodo(id: UUID) throws {
        try persistenceService.deleteTask(id: id)
        try keychainService.delete(account: id.uuidString)
    }

}
