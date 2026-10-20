//
//  RealmNotificationTask.swift
//  ToDo
//

import Foundation
import RealmSwift

final class RealmNotificationTask: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var title: String
    @Persisted var body: String
    @Persisted var dueDate: Date
    @Persisted var status: String
    @Persisted var receivedAt: Date
}
