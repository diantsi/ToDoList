//
//  KeychainService.swift
//  ToDo
//
//  Created by Діана Цісарук on 21.10.2026.
//
import Foundation

final class KeychainService {

    private let service = "todo.task.service"

    func saveCredentials(credentials: Credentials) throws {
        do {
            try updateCredentialsInKeychain(credentials: credentials)
        } catch KeychainError.itemNotFound {
            try addCredentialstoKeychain(credentials: credentials)
        }

    }

    func addCredentialstoKeychain(credentials: Credentials) throws {
        let account = credentials.username
        let password = Data(credentials.password.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecValueData as String: password,
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }

    }

    func updateCredentialsInKeychain(credentials: Credentials) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
        ]

        let account = credentials.username
        let password = Data(credentials.password.utf8)
        let attributes: [String: Any] = [
            kSecAttrAccount as String: account,
            kSecValueData as String: password,
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

    func readCredentials() throws -> Credentials {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true,
        ]

        var itemCopy: AnyObject?
        let status = SecItemCopyMatching(
            query as CFDictionary,
            &itemCopy
        )

        guard status != errSecItemNotFound else {
            throw KeychainError.noPassword
        }

        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus
        }

        guard let item = itemCopy as? [String: Any],
            let passwordData = item[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: .utf8),
            let account = item[kSecAttrAccount as String] as? String
        else {
            throw KeychainError.cannotReturnPasswordData
        }

        return Credentials(username: account, password: password)
    }
}
