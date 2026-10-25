//
//  KeychainError.swift
//  ToDo
//
//  Created by Діана Цісарук on 24.10.2026.
//
import Foundation


enum KeychainError: Error {
    case itemNotFound
    case unexpectedStatus
    case cannotReturnData
    case unhandledError(status: OSStatus)
    case noCredentials
    case noPassword
    case cannotReturnPasswordData

    var errorDescription: String {
        switch self {
        case .itemNotFound: return "item not found"
        case .unexpectedStatus: return "unexpected status"
        case .cannotReturnData: return "cannot return data"
        case .unhandledError: return "unhandled error"
        case .noCredentials: return "have no credentials"
        case .noPassword: return "no password"
        case .cannotReturnPasswordData: return "cannot return password data"
        }

    }
}
