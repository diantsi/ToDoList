//
//  TodoWidgetBundle.swift
//  TodoWidget
//
//  Created by Діана Цісарук on 09.11.2026.
//

import WidgetKit
import SwiftUI

@main
struct TodoWidgetBundle: WidgetBundle {
    var body: some Widget {
        TodoWidget()
        TodoWidgetControl()
        TodoWidgetLiveActivity()
    }
}
