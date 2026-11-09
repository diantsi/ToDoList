//
//  PendingTaskWidget.swift
//  ToDo
//
//  Created by Діана Цісарук on 09.11.2026.
//
import WidgetKit
import SwiftUI

struct PendingTaskWidget: Widget {
    let widgetkind = "PendingTasks"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: widgetkind, provider: TodoProvider()) { entry in
            PendingTasksView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Найближчі справи")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
    
}
