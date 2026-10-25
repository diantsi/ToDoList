//
//  AuthService.swift
//  ToDo
//
//  Created by Діана Цісарук on 24.10.2026.
//
import Foundation

final class AuthService {

    private var serverPath: String = "http://127.0.0.1:8080"

    func postCredentials(credentials: Credentials) async throws {
        guard let url = URL(string: serverPath + "/auth")
        else {
            throw AuthError.invalidUrl
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        let body = try JSONEncoder().encode(credentials)
        request.httpBody = body

        guard
            let (_, response) = try? await URLSession.shared.data(for: request)
        else {
            throw AuthError.cannotDoRequest
        }
        guard let response = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }

        switch response.statusCode {
        case (200...299): break
        case (400...499): throw AuthError.invalidCredentials
        case (500...599): throw AuthError.serverUnavailable
        default:
            throw AuthError.unexpectedResponse(statusCode: response.statusCode)
        }
    }
}

enum AuthError: Error {
    case invalidUrl
    case cannotDoRequest
    case invalidCredentials
    case serverUnavailable
    case unexpectedResponse(statusCode: Int)
    case invalidResponse
}
