//
//  NotificationTaskCoordinator.swift
//  ToDo
//
import Foundation
import UIKit

final class NotificationTaskCoordinator {

    private let persistenceService: any PersistenceService

    init(
        persistenceService: any PersistenceService =
            PersistenceServiceProvider.shared
    ) {
        self.persistenceService = persistenceService
    }

    func receive(_ notificationTask: NotificationTask) throws {
        try store(notificationTask)
        notifyInboxChanged()
    }

    func accept(
        _ notificationTask: NotificationTask
    ) throws -> TodoTask? {
        try store(notificationTask)

        guard try status(for: notificationTask.id) == .pending else {
            return nil
        }

        let todoTask = TodoTask(
            name: notificationTask.taskName,
            dueDate: notificationTask.dueDate,
            needToNotify: true
        )

        try persistenceService.addTask(todoTask)
        try persistenceService.setNotificationTaskStatus(
            .accepted,
            for: notificationTask.id
        )
        notifyInboxChanged()
        NotificationCenter.default.post(
            name: .todoTasksDidChange,
            object: nil
        )
        UIAccessibility.post(
            notification: .announcement,
            argument: "Сповіщення прийнято"
        )

        return todoTask
    }

    func decline(_ notificationTask: NotificationTask) throws {
        try store(notificationTask)
        print("Користувач відмовився від завдання")

        guard try status(for: notificationTask.id) == .pending else {
            return
        }

        try persistenceService.setNotificationTaskStatus(
            .declined,
            for: notificationTask.id
        )
        notifyInboxChanged()
        UIAccessibility.post(
            notification: .announcement,
            argument: "Сповіщення відхилено"
        )
    }

    private func status(
        for notificationId: String
    ) throws -> NotificationStatus? {
        try persistenceService
            .getAllNotificationTasks()
            .first(where: { $0.id == notificationId })?
            .status
    }

    private func store(_ notificationTask: NotificationTask) throws {
        try persistenceService.addNotificationTask(notificationTask)
    }

    private func notifyInboxChanged() {
        NotificationCenter.default.post(
            name: .notificationTasksDidChange,
            object: nil
        )
    }
}

extension Notification.Name {
    static let notificationTasksDidChange = Notification.Name(
        "notificationTasksDidChange"
    )

    static let todoTasksDidChange = Notification.Name(
        "todoTasksDidChange"
    )

}
