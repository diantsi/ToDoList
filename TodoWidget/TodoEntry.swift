//
//  TodoEntry.swift
//  ToDo
//
//  Created by Діана Цісарук on 09.11.2026.
//

import Foundation
import WidgetKit

struct TodoEntry : TimelineEntry {
    let date: Date
    let tasks: [TodoTask]
}
