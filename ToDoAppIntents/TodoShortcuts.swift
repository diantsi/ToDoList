//
//  TodoShortcuts.swift
//  ToDo
//
//  Created by Діана Цісарук on 10.11.2026.
//

import AppIntents

struct TodoShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CompleteTaskIntent(),
            phrases: [
                "\(.applicationName): виконати завдання"
            ],
            shortTitle: "Виконати завдання",
            systemImageName: "checkmark.circle"
        );
        AppShortcut(
            intent: AddTaskIntent(),
            phrases: [
                "\(.applicationName): додати завдання"
            ],
            shortTitle: "Додати завдання",
            systemImageName: "plus.circle"
        )
    }
}
