//
//  AuthError.swift
//  ToDo
//
//  Created by Діана Цісарук on 27.10.2026.
//
import Foundation

enum AuthError: LocalizedError {
    case invalidUrl
    case cannotDoRequest(Error)
    case invalidCredentials
    case serverUnavailable
    case unexpectedResponse(statusCode: Int)
    case invalidResponse
    
    var errorDescription: String? {
            switch self {
            case .invalidUrl:
                return "Некоректна адреса сервера"

            case .cannotDoRequest(let error):
                return "Не вдалося підключитися до сервера: \(error.localizedDescription)"

            case .invalidCredentials:
                return "Неправильний email або пароль"

            case .serverUnavailable:
                return "Сервер тимчасово недоступний"

            case .unexpectedResponse(let statusCode):
                return "Неочікувана відповідь сервера: \(statusCode)"

            case .invalidResponse:
                return "Сервер повернув некоректну відповідь"
            }
        }
}
