//
//  UserNotificationsService.swift
//  ToDo
//
//  Created by Діана Цісарук on 14.10.2026.
//
import Foundation
import UIKit
import UserNotifications

final class UserNotificationsService: NSObject {
    
    enum Const {
        static let categoryId = "adding_task_category"
        static let acceptActionId = "accept_task"
        static let declineActionId = "deny_task"
    }

    static let shared = UserNotificationsService()

    private let localNotificationService: LocalNotificationService
    
    private let remoteNotificationHandler: NotificationTaskCoordinator

    private var userNotificationCenter: UNUserNotificationCenter {
        return UNUserNotificationCenter.current()
    }

    private override init() {
        localNotificationService = LocalNotificationService()
        remoteNotificationHandler = NotificationTaskCoordinator()
        super.init()

        userNotificationCenter.delegate = self
    }

    func requestAccess(for application: UIApplication) {
        Task {
            await request()
            await MainActor.run {
                application.registerForRemoteNotifications()
            }
        }
    }

    private func request() async {
        do {
            try await userNotificationCenter.requestAuthorization(
                options: [.badge, .sound, .alert]
            )
        } catch {
            return
        }
    }

    func setNotificationCategory() {
        let acceptAction = UNNotificationAction(
            identifier: Const.acceptActionId,
            title: "Прийняти",
            options: [.foreground]
        )
        let declineAction = UNNotificationAction(
            identifier: Const.declineActionId,
            title: "Видалити",
            options: [.destructive]
        )

        let addingTaskCategory = UNNotificationCategory(
            identifier: Const.categoryId,
            actions: [acceptAction, declineAction],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "нове повідомлення",
            options: .customDismissAction
        )

        userNotificationCenter.setNotificationCategories([addingTaskCategory])
    }

    private func getNotificationAccess() async -> Bool {
        var authorizationStatus =
            await userNotificationCenter.notificationSettings()
            .authorizationStatus
        if authorizationStatus == .notDetermined {
            await request()
            authorizationStatus =
                await userNotificationCenter.notificationSettings()
                .authorizationStatus
        }
        switch authorizationStatus {
        case .authorized, .ephemeral:
            return true
        case .denied:
            return false
        default:
            return false
        }
    }

    func sendNotification(with reminderItem: any ReminderItem) async throws {
        guard await getNotificationAccess() else {
            throw NotificationError.notificationAccessDenied
        }
        let request = localNotificationService.createLocalNotification(
            for: reminderItem
        )
        try await userNotificationCenter.add(request)
    }

    func cancelNotification(with reminderItem: any ReminderItem) {
        userNotificationCenter.removePendingNotificationRequests(
            withIdentifiers: [reminderItem.notificationId])
    }

    func receiveRemoteNotification(
        userInfo: [AnyHashable: Any]
    ) throws {
        let notificationTask = try parse(
            userInfo: userInfo,
            receivedAt: Date()
        )
        try remoteNotificationHandler.receive(notificationTask)
    }

    private func parse(
        _ notification: UNNotification
    ) throws -> NotificationTask {
        let content = notification.request.content

        return try parse(
            userInfo: content.userInfo,
            fallbackTitle: content.title,
            fallbackBody: content.body,
            receivedAt: notification.date
        )
    }

    private func parse(
        userInfo: [AnyHashable: Any],
        fallbackTitle: String = "",
        fallbackBody: String = "",
        receivedAt: Date
    ) throws -> NotificationTask {
        let alert = alertContent(from: userInfo)

        guard
            let id = userInfo["id"] as? String,
            !id.isEmpty,
            let dueDate = dueDate(from: userInfo["due"])
        else {
            throw NotificationError.invalidPayload
        }

        return NotificationTask(
            id: id,
            title: fallbackTitle.isEmpty
                ? alert.title
                : fallbackTitle,
            body: fallbackBody.isEmpty
                ? alert.body
                : fallbackBody,
            dueDate: dueDate,
            status: .pending,
            receivedAt: receivedAt
        )
    }

    private func dueDate(from value: Any?) -> Date? {
        guard let value = value as? String else {
            return nil
        }

        return ISO8601DateFormatter().date(from: value)
    }
    
    private func alertContent(
        from userInfo: [AnyHashable: Any]
    ) -> (title: String, body: String) {
        guard
            let aps = userInfo["aps"] as? [String: Any],
            let alert = aps["alert"]
        else {
            return ("", "")
        }

        if let body = alert as? String {
            return ("", body)
        }

        guard let alert = alert as? [String: Any] else {
            return ("", "")
        }

        return (
            alert["title"] as? String ?? "",
            alert["body"] as? String ?? ""
        )
    }

    private func process(
        _ response: UNNotificationResponse
    ) async {
        do {
            let notificationTask = try parse(
                response.notification
            )

            switch response.actionIdentifier {
            case Const.acceptActionId:
                if let task = try remoteNotificationHandler.accept(
                    notificationTask
                ) {
                    try await sendNotification(with: task)
                }

            case Const.declineActionId:
                try remoteNotificationHandler.decline(notificationTask)

            default:
                try remoteNotificationHandler.receive(notificationTask)
            }
        } catch {
            print("Не вдалося обробити зовнішнє сповіщення: \(error)")
        }
    }
}

extension UserNotificationsService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
            @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        guard notification.request.content.categoryIdentifier
                == Const.categoryId
        else {
            completionHandler([.badge, .sound, .banner])
            return
        }

        do {
            let notificationTask = try parse(notification)
            try remoteNotificationHandler.receive(notificationTask)
        } catch {
            print("Не вдалося зберегти зовнішнє сповіщення: \(error)")
        }

        completionHandler([.badge, .sound, .banner])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        guard response.notification.request.content.categoryIdentifier
                == Const.categoryId
        else {
            completionHandler()
            return
        }

        Task {
            await process(response)
            completionHandler()
        }
    }

}
