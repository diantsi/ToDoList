//
//  Subtask+CoreDataProperties.swift
//  ToDo
//
//  Created by Діана Цісарук on 12.10.2026.
//
//

public import Foundation
public import CoreData


public typealias SubtaskCoreDataPropertiesSet = NSSet

extension Subtask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Subtask> {
        return NSFetchRequest<Subtask>(entityName: "Subtask")
    }

    @NSManaged nonisolated public var name: String?
    @NSManaged nonisolated public var isDone: Bool
    @NSManaged nonisolated public var task: Task?

}

extension Subtask : Identifiable {

}
