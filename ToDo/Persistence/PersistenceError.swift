//
//  PersistanceError.swift
//  ToDo
//
//  Created by Діана Цісарук on 13.10.2026.
//

enum PersistenceError : Error {
    case missingTaskID
    case missingSubtaskID
    case taskNotFound
    case subtaskNotFound
    case cannotUpdateTask
}
