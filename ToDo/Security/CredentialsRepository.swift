//
//  CredentialsRepository.swift
//  ToDo
//
//  Created by Діана Цісарук on 25.10.2026.
//
import Foundation

final class CredentialsRepository {
    
    let service = "todo.credential.service"
    let account = "todo.credential.accont"
    
    let keychainService: KeychainService
    init(){
        keychainService = KeychainService(service: service)
    }

    func saveCredentials(credentials: Credentials) throws {
        let credentials = try JSONEncoder().encode(credentials)
        try keychainService.save(data: credentials, account: account)
    }

    func readCredentials() throws -> Credentials {
        let keychainData = try keychainService.read(account: account)
        let credentials = try JSONDecoder().decode(Credentials.self, from: keychainData)
        return credentials
    }

}
