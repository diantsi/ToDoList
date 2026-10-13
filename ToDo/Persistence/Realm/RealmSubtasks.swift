//
//  RealmSubtasks.swift
//  ToDo
//
//  Created by Діана Цісарук on 13.10.2026.
//
import RealmSwift
import Foundation

final class RealmSubtask: Object {
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var name: String = ""
    @Persisted var isDone: Bool = false
}
