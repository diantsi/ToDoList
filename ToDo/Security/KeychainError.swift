//
//  KeychainError.swift
//  ToDo
//
//  Created by Діана Цісарук on 24.10.2026.
//
import Foundation


enum KeychainError: LocalizedError {
    case itemNotFound
    case unexpectedStatus
    case unhandledError(status: OSStatus)
    case noData
    case cannotReturnData

    var errorDescription: String {
        switch self {
        case .itemNotFound: return "item not found"
        case .unexpectedStatus: return "unexpected status"
        case .unhandledError: return "unhandled error"
        case .noData: return "no password"
        case .cannotReturnData: return "cannot return data"
        }

    }
}
