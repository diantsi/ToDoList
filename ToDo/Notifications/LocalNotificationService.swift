//
//  LocalNotificationService.swift
//  ToDo
//
//  Created by Діана Цісарук on 16.10.2026.
//

import UserNotifications

final class LocalNotificationService {
    
    private let content = UNMutableNotificationContent()
    
    
    func createLocalNotification(
        for reminderItem: any ReminderItem
    ) -> UNNotificationRequest {
        content.title = reminderItem.name
        
        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute], from: reminderItem.dueDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: reminderItem.notificationId,
            content: content,
            trigger: trigger
        )
        
        return request
    }
    
    
}
