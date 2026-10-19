//
//  UserNotificationsService.swift
//  ToDo
//
//  Created by Діана Цісарук on 14.10.2026.
//
import Foundation
import UserNotifications
import UIKit

final class UserNotificationsService: NSObject {
    
    static let shared = UserNotificationsService()
    
    private let localNotificationService: LocalNotificationService
    
    private override init() {
        localNotificationService = LocalNotificationService()
        super.init()
        
        userNotificationCenter.delegate = self
    }

    private var userNotificationCenter: UNUserNotificationCenter {
        return UNUserNotificationCenter.current()
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
                options: [.badge, .sound, .alert, .provisional]
            )
        } catch {
            return
        }
    }
    
    
    private func getNotificationAccess() async -> Bool {
        var authorizationStatus = await userNotificationCenter.notificationSettings().authorizationStatus
        if authorizationStatus == .notDetermined {
            await request()
            authorizationStatus = await userNotificationCenter.notificationSettings().authorizationStatus
        }
        switch authorizationStatus {
        case .authorized, .ephemeral:
            return true
        case .provisional:
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
        userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [reminderItem.notificationId])
    }
    

}

enum NotificationError : Error {
    case notificationAccessDenied
}

extension UserNotificationsService: UNUserNotificationCenterDelegate {
    
    func application(
     _ application: UIApplication,
     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
     ) {
         completionHandler(.noData)
     }
    
     func userNotificationCenter(
     _
     center: UNUserNotificationCenter,
     willPresent notification: UNNotification,
     withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
     ) {
         completionHandler([.badge, .sound, .banner])
     }
    
}
