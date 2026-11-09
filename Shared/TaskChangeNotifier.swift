//
//  TaskChangeNotifier.swift
//  ToDo
//
//  Created by Діана Цісарук on 09.11.2026.
//

import WidgetKit

enum WidgetTaskUpdater {
        
    static func didTaskChange() {
        WidgetCenter.shared.reloadTimelines(ofKind:  "PendingTasks")
    }
}
