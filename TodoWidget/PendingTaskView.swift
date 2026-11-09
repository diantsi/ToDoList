//
//  PendingTaskView.swift
//  ToDo
//
//  Created by Діана Цісарук on 09.11.2026.
//
import SwiftUI

struct PendingTasksView: View {
    
    let entry: TodoEntry
    
    var body: some View {
        VStack {
            ForEach(entry.tasks) { task in
                HStack {
                    Button {
                        
                    } label: {
                        Image(systemName: "square")
                    }
                    Text(task.name)
                    Text(task.dueDate.formatted())
                }
            }
        }
    }
}
