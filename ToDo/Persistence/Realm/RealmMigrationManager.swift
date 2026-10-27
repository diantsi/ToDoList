//
//  RealmMigrationManager.swift
//  ToDo
//
//  Created by Діана Цісарук on 27.10.2026.
//
import Foundation
import RealmSwift
import Realm

enum RealmMigrationManager {

    private nonisolated static let schemaVersion: UInt64 = 5

    nonisolated static var configuration: Realm.Configuration {
        Realm.Configuration(
            schemaVersion: schemaVersion,
            migrationBlock: migrate,
            objectTypes: [
                RealmTask.self,
                RealmSubtask.self,
                RealmNotificationTask.self,
            ]
        )
    }

    private nonisolated static func migrate(
        migration: Migration,
        oldSchemaVersion: UInt64
    ) {
        if oldSchemaVersion < 1 {
            migration.enumerateObjects(
                ofType: RealmTask.className()
            ) { _, newObject in
                newObject?["needToNotify"] = false
            }
        }

        if oldSchemaVersion < 2 {
            migration.enumerateObjects(
                ofType: RealmSubtask.className()
            ) { _, newObject in
                newObject?["dueDate"] = Date()
                newObject?["needToNotify"] = false
            }
        }
        if oldSchemaVersion < 5 {
            migration.enumerateObjects(
                ofType: RealmTask.className()
            ) { _, newObject in
                newObject?["isHidden"] = false
            }
        }
    }
}
