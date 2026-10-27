//
//  KeychainService.swift
//  ToDo
//
//  Created by Діана Цісарук on 21.10.2026.
//
import Foundation

final class KeychainService {

    private let service: String

    init(service: String = "todo.service") {
        self.service = service
    }

    func save(data: Data, account: String) throws {
        do {
            try update(data: data, account: account)
        } catch KeychainError.itemNotFound {
            try add(data: data, account: account)
        }

    }

    private func add(data: Data, account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecValueData as String: data,
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }

    }

    private func update(data: Data, account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let status = SecItemUpdate(
            query as CFDictionary,
            attributes as CFDictionary
        )

        switch status {
        case errSecItemNotFound: throw KeychainError.itemNotFound
        case errSecSuccess: return
        default: throw KeychainError.unhandledError(status: status)
        }

    }

    func delete(account: String) throws {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: account]
                
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
    }
    
    func read(account: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account as AnyObject,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true,
        ]

        var itemCopy: AnyObject?
        let status = SecItemCopyMatching(
            query as CFDictionary,
            &itemCopy
        )

        guard status != errSecItemNotFound else {
            throw KeychainError.noData
        }

        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus
        }

        guard let item = itemCopy as? Data
        else {
            throw KeychainError.cannotReturnData
        }
        return item
    }

    func readAll() throws -> [(account: String, data: Data)] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecMatchLimit as String: kSecMatchLimitAll,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true,
        ]

        var results: CFTypeRef?
        let status = SecItemCopyMatching(
            query as CFDictionary,
            &results
        )

        guard status != errSecItemNotFound else {
            return []
        }

        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus
        }

        guard let items = results as? [[String: Any]]
        else {
            throw KeychainError.cannotReturnData
        }
        
        return try items.map { item in
            guard let account = item[kSecAttrAccount as String] as? String,
                let data = item[kSecValueData as String] as? Data
            else {
                throw KeychainError.cannotReturnData
            }
            return (account: account, data: data)
        }
    }
    

}
