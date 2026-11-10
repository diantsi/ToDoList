import AppIntents
//
//  PendingTaskView.swift
//  ToDo
//
//  Created by Діана Цісарук on 09.11.2026.
//
import SwiftUI
import WidgetKit

struct PendingTasksView: View {
    @Environment(\.widgetFamily) private var wFamily
    let entry: TodoEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if entry.tasks.isEmpty {
                Text("Немає найближчих справ")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                widgetStyle()
            }

        }
    }

    @ViewBuilder
    private func widgetStyle() -> some View {
        switch wFamily {
        case .systemSmall:
            widgetStyle(fontSize: 13, taskNumber: 3)
        case .systemMedium:
            widgetStyle(fontSize: 15, taskNumber: 4)
        case .accessoryRectangular:
            widgetStyle(fontSize: 13, taskNumber: 1)
        default:
            widgetStyle(fontSize: 13, taskNumber: 3)
        }
    }

    @ViewBuilder
    private func widgetStyle(
        fontSize: CGFloat,
        taskNumber: Int
    ) -> some View {
        ForEach(entry.tasks.prefix(taskNumber)) { task in
            HStack(spacing: 3) {
                Button(intent: ToggleTaskIntent(taskID: task.id)) {
                    Image(systemName: "circle")
                        .font(.system(size: fontSize*2))
                        .foregroundStyle(.tint)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Позначити виконаним")

                if let deepLink = task.deepLink {
                    Link(destination: deepLink) {
                        taskLabel(task, fontSize: fontSize)
                    }
                } else {
                    taskLabel(task, fontSize: fontSize)
                }
            }
        }

    }

    private func taskLabel(
        _ task: TodoTask,
        fontSize: CGFloat
    ) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(task.name)
                .font(.system(size: fontSize, weight: .medium))

            Text(task.dueDate.formatted())
                .font(.system(size: fontSize, weight: .medium))
                .foregroundStyle(.secondary)
                .accessibilityLabel(task.dueDate.voiceOverFormatted)
        }
    }
}
