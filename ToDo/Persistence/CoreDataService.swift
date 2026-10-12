//
//  CoreDataService.swift
//  ToDo
//
//  Created by Діана Цісарук on 07.10.2026.
//

import CoreData

class CoreDataService {
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDo")
        container.loadPersistentStores(completionHandler: { (_, error) in
            
            if let error = error as? NSError {
                fatalError()
            }
        })
        return container
        
    }()
    
    
    
    func saveContext() throws {
        let context = persistentContainer.viewContext
        guard context.hasChanges else { return }
        try context.save()
    }
    
    
}
