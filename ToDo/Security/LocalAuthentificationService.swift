//
//  LocalAuthentification.swift
//  ToDo
//
//  Created by Діана Цісарук on 25.10.2026.
//
import Foundation
import LocalAuthentication

final class BiometricAuthService {

    private let context: LAContext
    
    init() {
        context = LAContext()
    }

    func authenticate() async throws  {
        var error: NSError?

        guard
            context.canEvaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                error: &error
            )
        else {
            throw error ?? BiometricError.unavailable
        }

        do {
            try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Unlock private data"
            )
        } catch let error {
            throw error
        }

    }

}


enum BiometricError: LocalizedError {
    case unavailable

    var errorDescription: String? {
        switch self {
        case .unavailable:
            return "biometric authentification unavailable"
        }
    }
}
