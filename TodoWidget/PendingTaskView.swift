//
//  PendingTaskView.swift
//  ToDo
//
//  Created by Діана Цісарук on 09.11.2026.
//
import SwiftUI
import AppIntents
import WidgetKit

struct PendingTasksView: View {
    let entry: TodoEntry
    
    var body: some View {
        VStack {
            ForEach(entry.tasks) { task in
                HStack {
                    Button(intent: ToggleTaskIntent(taskID : task.id)) {
                        Image(systemName: "square")
                    }
                    if let deepLink = task.deepLink {
                        Link(destination: deepLink) {
                            Text(task.name)
                            Text(task.dueDate.formatted())
                        }
                    } else {
                        Text(task.name)
                        Text(task.dueDate.formatted())
                    }
                }
            }
        }
    }
}
