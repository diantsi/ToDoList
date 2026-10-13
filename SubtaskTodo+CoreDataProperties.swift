//
//  SubtaskTodo+CoreDataProperties.swift
//  ToDo
//
//  Created by Діана Цісарук on 13.10.2026.
//
//

public import Foundation
public import CoreData


public typealias SubtaskTodoCoreDataPropertiesSet = NSSet

extension SubtaskTodo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubtaskTodo> {
        return NSFetchRequest<SubtaskTodo>(entityName: "SubtaskTodo")
    }

    @NSManaged nonisolated public var isDone: Bool
    @NSManaged nonisolated public var name: String?
    @NSManaged nonisolated public var id: UUID?
    @NSManaged nonisolated public var task: TaskTodo?

}

extension SubtaskTodo : Identifiable {

}
