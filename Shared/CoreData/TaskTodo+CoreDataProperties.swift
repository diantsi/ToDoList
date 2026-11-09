//
//  TaskTodo+CoreDataProperties.swift
//  ToDo
//
//  Created by Діана Цісарук on 27.10.2026.
//
//

public import Foundation
public import CoreData


public typealias TaskTodoCoreDataPropertiesSet = NSSet

extension TaskTodo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskTodo> {
        return NSFetchRequest<TaskTodo>(entityName: "TaskTodo")
    }

    @NSManaged nonisolated public var dueDate: Date?
    @NSManaged nonisolated public var id: UUID?
    @NSManaged nonisolated public var isDone: Bool
    @NSManaged nonisolated public var name: String?
    @NSManaged nonisolated public var needToNotify: Bool
    @NSManaged nonisolated public var isHidden: Bool
    @NSManaged nonisolated public var subtasks: NSSet?

}

// MARK: Generated accessors for subtasks
extension TaskTodo {

    @objc(addSubtasksObject:)
    @NSManaged nonisolated public func addToSubtasks(_ value: SubtaskTodo)

    @objc(removeSubtasksObject:)
    @NSManaged nonisolated public func removeFromSubtasks(_ value: SubtaskTodo)

    @objc(addSubtasks:)
    @NSManaged nonisolated public func addToSubtasks(_ values: NSSet)

    @objc(removeSubtasks:)
    @NSManaged nonisolated public func removeFromSubtasks(_ values: NSSet)

}

extension TaskTodo : Identifiable {

}
