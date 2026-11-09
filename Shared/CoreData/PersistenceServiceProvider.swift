//
//  PersistenceServiceProvider.swift
//  ToDo
//
//  Created by Діана Цісарук on 20.10.2026.
//


enum PersistenceServiceProvider {
    static let shared: any PersistenceService = CoreDataService()
}
