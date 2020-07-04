//
//  NotificationService.swift
//  Tymed
//
//  Created by Jonah Schueller on 04.07.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import Foundation
import UserNotifications

//MARK: NotificationService
class NotificationService {

    //MARK: NotificationThread
    enum NotificationThread : String {
        
        case lesson = "lessonThread"
        case task = "taskThread"
        case other = "otherThread"
        
        var identifier: String {
            self.rawValue
        }
    }
    
    //MARK: NotificationCategory
    enum NotificationCategory : String {
        
        case lesson = "lessonCategory"
        case task = "taskCategory"
        case other = "otherCategory"
        
        var identifier: String {
            self.rawValue
        }
    }
    
    static let current = NotificationService()
    
    internal init () {
        
    }
    
    //MARK: requestAuthorization(_:)
    func requestAuthorization(_ completion: @escaping (Bool, Error?) -> Void) {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: completion)
        
    }
    
    //MARK: hasAuthorization(_:)
    func hasAuthorization(_ completion: @escaping (Bool) -> Void) {
        
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            completion(settings.authorizationStatus == .authorized)
        }
        
    }
    
    
    
    //MARK: notificationTrigger(for: )
    
    private func notificationTrigger(for dateComponents: DateComponents, repeats: Bool = false) -> UNCalendarNotificationTrigger {
        return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
    }
    
    private func notificationTrigger(for lesson: Lesson) -> UNCalendarNotificationTrigger {
        return notificationTrigger(for: lesson.startDateComponents, repeats: true)
    }
    
    private func notificationTrigger(for task: Task) -> UNCalendarNotificationTrigger? {
        guard let dueDate = task.due else {
            return nil
        }
        let comp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        return notificationTrigger(for: comp)
    }
    
    //MARK: notificationContent
    private func notificationContent(_ title: String, body: String, thread: NotificationThread, sound: UNNotificationSound, category: NotificationCategory) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        
        content.title = title
        content.body = body
        content.sound = sound
        content.categoryIdentifier = category.identifier
        
        content.threadIdentifier = thread.identifier
        
        return content
    }
    
    private func notificationContentForDueDate(task: Task) -> UNMutableNotificationContent {
        
        let title = task.title
        let body = ""
            
        return notificationContent(title, body: body, thread: .task
            , sound: .default, category: .task)
    }
    
    //MARK: notificationRequest(...)
    
    func notificationRequest(_ identifier: String, _ content: UNMutableNotificationContent, _ trigger: UNNotificationTrigger) -> UNNotificationRequest {
        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }
    
    func notificationDueDateRequest(for task: Task) -> UNNotificationRequest? {
        guard let trigger = notificationTrigger(for: task) else {
            return nil
        }
        
        let content = notificationContentForDueDate(task: task)
        let identfier = task.id.uuidString
        
        print("Trigger for date: \(trigger.nextTriggerDate()?.stringify(dateStyle: .full, timeStyle: .full))")
        
        return notificationRequest(identfier, content, trigger)
    }
    
    //MARK: scheduleNotification
    func scheduleNotification(_ request: UNNotificationRequest) {
        
        requestAuthorization { (res, err) in
            if res {
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
    
    func scheduleDueDateNotification(for task: Task) {
        guard let request = notificationDueDateRequest(for: task) else {
            return
        }
        
        scheduleNotification(request)
    }
    
    
    
}
