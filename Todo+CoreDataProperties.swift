//
//  Todo+CoreDataProperties.swift
//  ToDo
//
//  Created by Діана Цісарук on 07.10.2026.
//
//

public import Foundation
public import CoreData


public typealias TodoCoreDataPropertiesSet = NSSet

extension Todo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Todo> {
        return NSFetchRequest<Todo>(entityName: "Todo")
    }

    @NSManaged nonisolated public var dueDate: Date?
    @NSManaged nonisolated public var isDone: Bool
    @NSManaged nonisolated public var name: String?

}

extension Todo : Identifiable {

}
