import AppIntents
//
//  ToggleTaskIntent.swift
//  ToDo
//
//  Created by Діана Цісарук on 10.11.2026.
//
import SwiftUI
import WidgetKit

struct ToggleTaskIntent: AppIntent {
    static let title: LocalizedStringResource = "Позначити виконаним"

    @Parameter(title: "ID")
    var taskID: String

    init() {}
    init(taskID: UUID) {
        self.taskID = taskID.uuidString
    }

    func perform() async throws -> some IntentResult {
        guard let id = UUID(uuidString: taskID) else {
            return .result()
        }

        try PersistenceServiceProvider.shared.toggleTaskDone(id: id)
        WidgetCenter.shared.reloadTimelines(ofKind: "PendingTasks")
        return .result()
    }

}
