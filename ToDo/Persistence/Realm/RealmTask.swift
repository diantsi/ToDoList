//
//  RealmTask.swift
//  ToDo
//
//  Created by Діана Цісарук on 13.10.2026.
//
import RealmSwift
import Realm
import Foundation

final class RealmTask: Object {
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var name: String
    @Persisted var isDone: Bool
    @Persisted var dueDate: Date
    @Persisted var subtasks: List<RealmSubtask>
    @Persisted var needToNotify: Bool
}
