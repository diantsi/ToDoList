//
//  Task+CoreDataProperties.swift
//  ToDo
//
//  Created by Діана Цісарук on 12.10.2026.
//
//

public import Foundation
public import CoreData


public typealias TaskCoreDataPropertiesSet = NSSet

extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged nonisolated public var dueDate: Date?
    @NSManaged nonisolated public var isDone: Bool
    @NSManaged nonisolated public var name: String?
    @NSManaged nonisolated public var subtasks: NSSet?

}

// MARK: Generated accessors for subtasks
extension Task {

    @objc(addSubtasksObject:)
    @NSManaged nonisolated public func addToSubtasks(_ value: Subtask)

    @objc(removeSubtasksObject:)
    @NSManaged nonisolated public func removeFromSubtasks(_ value: Subtask)

    @objc(addSubtasks:)
    @NSManaged nonisolated public func addToSubtasks(_ values: NSSet)

    @objc(removeSubtasks:)
    @NSManaged nonisolated public func removeFromSubtasks(_ values: NSSet)

}

extension Task : Identifiable {

}
