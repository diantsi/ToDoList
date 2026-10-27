//
//  TodoTaskRepository.swift
//  ToDo
//
//  Created by Діана Цісарук on 25.10.2026.
//
import Foundation

final class HiddenTaskRepository {

    let service = "todo.task.service"

    let keychainService: KeychainService
    let biometricService: BiometricAuthService
    let persistenceService: PersistenceService
    
    init() {
        keychainService = KeychainService(service: service)
        biometricService = BiometricAuthService()
        persistenceService = PersistenceServiceProvider.shared
    }

    func saveTodo(todo: TodoTask) throws {
        let account = todo.id.uuidString
        let data = try JSONEncoder().encode(todo)
        try keychainService.save(data: data, account: account)
    }

    func readTodos() async throws -> [TodoTask] {
        try await biometricService.authenticate()
        
        let keychainData = try keychainService.readAll()
        return try keychainData.map { item in
            try JSONDecoder().decode(TodoTask.self, from: item.data)
        }
    }
    
    func deleteTodo(id: UUID) throws {
        try persistenceService.deleteTask(id: id)
        try keychainService.delete(account: id.uuidString)
    }

}
