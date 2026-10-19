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
            do {
                try await userNotificationCenter.requestAuthorization(
                    options: [.badge, .sound, .alert, .provisional]
                )
            } catch {
                print("Access denied")
                return
            }
            await MainActor.run {
                application.registerForRemoteNotifications()
                print("registration is done")
            }
        }
    }
    
    
    func sendNotification(with reminderItem: any ReminderItem) {
        let request = localNotificationService.createLocalNotification(
            for: reminderItem
        )
        Task {
            do {
                try await userNotificationCenter.add(request)
            } catch {
                print("cannot sent local notification")
                return
            }
        }
    }
    
    func cancelNotification(with reminderItem: any ReminderItem) {
        userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [reminderItem.notificationId])
    }
    
    

}

// xcrun simctl push booted ua.edu.tsisaruk.ToDo 

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
