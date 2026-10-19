//
//  LocalNotificationService.swift
//  ToDo
//
//  Created by Діана Цісарук on 16.10.2026.
//

import UserNotifications

final class LocalNotificationService {
    
    
    func createLocalNotification(
        for reminderItem: any ReminderItem
    ) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
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
