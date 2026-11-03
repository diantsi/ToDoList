//
//  TaskTableUITests.swift
//  ToDo
//
//  Created by Діана Цісарук on 03.11.2026.
//
import XCTest

final class ScreenAccessibilityUITests: XCTestCase {

    private enum Screen {
        static let inboxTab = "Вхідні"
        static let hiddenTasksTab = "Приховані"

        static let tasksNavigationBar = "Мої завдання"
        static let inboxNavigationBar = "Вхідні повідомлення"
        static let hiddenTasksNavigationBar = "Приховані завдання"
        static let addTaskNavigationBar = "Додати завдання"
        static let authenticationButton = "Увійти"
        static let addTaskButton = "Додати завдання"
        static let closeButton = "Закрити вкладку"
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }

    @MainActor
    func testTasksScreenAccessibilityAudit() throws {
        let app = launchApp(launchOptions: ["-UITestSkipAuthentication"])
        XCTAssertTrue(
            app.navigationBars[Screen.tasksNavigationBar].waitForExistence(timeout: 10)
        )

        try app.performAccessibilityAudit()
    }

    @MainActor
    func testInboxScreenAccessibilityAudit() throws {
        let app = launchApp(launchOptions: ["-UITestSkipAuthentication"])
        openTab(Screen.inboxTab, in: app)
        XCTAssertTrue(
            app.navigationBars[Screen.inboxNavigationBar].waitForExistence(timeout: 10)
        )
        try app.performAccessibilityAudit()
    }

    @MainActor
    func testHiddenTasksScreenAccessibilityAudit() throws {
        let app = launchApp(launchOptions: ["-UITestSkipAuthentication"])
        openTab(Screen.hiddenTasksTab, in: app)
        XCTAssertTrue(
            app.navigationBars[Screen.hiddenTasksNavigationBar].waitForExistence(timeout: 10)
        )

        try app.performAccessibilityAudit()
    }

    @MainActor
    func testAuthScreenAccessibilityAudit() throws {
        let app = launchApp(
            launchOptions: ["-UITestShowAuthentication"]
        )
        XCTAssertTrue(
            app.buttons[Screen.authenticationButton].waitForExistence(timeout: 10)
        )

        try app.performAccessibilityAudit()
    }

    @MainActor
    func testAddTaskScreenAccessibilityAudit() throws {
        let app = launchApp(
            launchOptions: ["-UITestSkipAuthentication"]
        )
        openAddTaskScreen(in: app)

        try app.performAccessibilityAudit()
    }

    @MainActor
    func testMainScreensAtLargestDynamicTypeSize() throws {
        let dynamicTypeLaunchOptions = [
            "-UIPreferredContentSizeCategoryName",
            "UICTContentSizeCategoryAccessibilityXXXL",
        ]
        let app = launchApp(
            launchOptions: ["-UITestSkipAuthentication"]
                + dynamicTypeLaunchOptions
        )
        XCTAssertTrue(
            app.navigationBars[Screen.tasksNavigationBar].waitForExistence(timeout: 10)
        )

        openAddTaskScreen(in: app)
        try app.performAccessibilityAudit(for: [.dynamicType, .textClipped])
        app.buttons[Screen.closeButton].tap()

        try app.performAccessibilityAudit(for: [.dynamicType, .textClipped])

        openTab(Screen.inboxTab, in: app)
        XCTAssertTrue(
            app.navigationBars[Screen.inboxNavigationBar].waitForExistence(timeout: 10)
        )
        try app.performAccessibilityAudit(for: [.dynamicType, .textClipped])

        openTab(Screen.hiddenTasksTab, in: app)
        XCTAssertTrue(
            app.navigationBars[Screen.hiddenTasksNavigationBar].waitForExistence(timeout: 10)
        )
        try app.performAccessibilityAudit(for: [.dynamicType, .textClipped])

        app.terminate()

        let authApp = launchApp(
            launchOptions: ["-UITestShowAuthentication"]
                + dynamicTypeLaunchOptions
        )
        XCTAssertTrue(
            authApp.buttons[Screen.authenticationButton]
                .waitForExistence(timeout: 10)
        )
        try authApp.performAccessibilityAudit(for: [.dynamicType, .textClipped])
    }

    @MainActor
    private func launchApp(
        launchOptions: [String] = []
    ) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += [
            "-UITestKeepHiddenTasksLocked",
        ]
        app.launchArguments += launchOptions

        app.launch()
        return app
    }

    @MainActor
    private func openTab(_ title: String, in app: XCUIApplication) {
        let tab = app.tabBars.buttons[title]
        XCTAssertTrue(
            tab.waitForExistence(timeout: 10)
        )
        tab.tap()
    }

    @MainActor
    private func openAddTaskScreen(in app: XCUIApplication) {
        XCTAssertTrue(
            app.navigationBars[Screen.tasksNavigationBar]
                .waitForExistence(timeout: 10)
        )

        let addTaskButton = app.buttons[Screen.addTaskButton]
        XCTAssertTrue(addTaskButton.waitForExistence(timeout: 10))
        addTaskButton.tap()

        XCTAssertTrue(
            app.navigationBars[Screen.addTaskNavigationBar]
                .waitForExistence(timeout: 10)
        )
    }

}
