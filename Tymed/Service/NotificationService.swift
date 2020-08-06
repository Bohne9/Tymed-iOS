//
//  NotificationService.swift
//  Tymed
//
//  Created by Jonah Schueller on 04.07.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import Foundation
import UserNotifications

struct NotificationOffset: Comparable, CaseIterable {
    typealias AllCases = [NotificationOffset]
    
    static var allCases: [NotificationOffset] {
        return
            [.atDueDate,
            .min5,
            .min10,
            .min15,
            .min30,
            .hour1,
            .hour2,
            .hour5,
            .hour10,
            .day1,
            .day3,
            .week1 ]
    }
    static func < (lhs: NotificationOffset, rhs: NotificationOffset) -> Bool {
        return lhs.value < rhs.value
    }
    
    static func ==(_ lhs: NotificationOffset, _ rhs: NotificationOffset) -> Bool {
        return lhs.value == rhs.value
    }
    
    static let atDueDate    = NotificationOffset(value: 0)
    static let min5         = NotificationOffset(value: 300)
    static let min10        = NotificationOffset(value: 600)
    static let min15        = NotificationOffset(value: 900)
    static let min30        = NotificationOffset(value: 1800)
    static let hour1        = NotificationOffset(value: 3600)
    static let hour2        = NotificationOffset(value: 7200)
    static let hour5        = NotificationOffset(value: 18000)
    static let hour10       = NotificationOffset(value: 32000)
    static let day1         = NotificationOffset(value: 86400)
    static let day3         = NotificationOffset(value: 259200)
    static let week1        = NotificationOffset(value: 604800)
    
    var timeInterval: TimeInterval {
        return TimeInterval(value)
    }
    
    var value: Int
    
    init(value: Int) {
        self.value = value
    }
    
    
    init(value: TimeInterval) {
        self.value = Int(value)
    }
    
    var title: String {
        switch self {
        case .atDueDate:    return "at due date"
        case .min5:         return "5 minutes before"
        case .min10:        return "10 minutes before"
        case .min15:        return "15 minutes before"
        case .min30:        return "30 minutes before"
        case .hour1:        return "1 hour before"
        case .hour2:        return "2 hours before"
        case .hour5:        return "5 hours before"
        case .hour10:       return "10 hours before"
        case .day1:         return "1 day before"
        case .day3:         return "3 days before"
        case .week1:        return "1 week before"
        default:
            if self < NotificationOffset.hour1 {
                return "\(value / 60) minutes before"
            }else if self < NotificationOffset.day1 {
                return "\(value / 3600) hours before"
            }else {
                return "\(value / 86400) days before"
            }
        }
    }
}

typealias NotificationFetchRequest = ([UNNotificationRequest]) -> Void

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
    
    private func notificationTrigger(at date: Date) -> UNCalendarNotificationTrigger {
        let comp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        return notificationTrigger(for: comp)
    }
    
    private func notificationTrigger(for lesson: Lesson) -> UNCalendarNotificationTrigger {
        return notificationTrigger(for: lesson.startDateComponents, repeats: true)
    }
    
    private func notificationTrigger(for task: Task) -> UNCalendarNotificationTrigger? {
        guard let date = task.due else { return nil }
        
        return notificationTrigger(at: date)
    }
    
    private func notificationTrigger(for task: Task, with offset: TimeInterval) -> UNCalendarNotificationTrigger? {
        guard var date = task.due else { return nil }
        
        date = date - offset
        
        return notificationTrigger(at: date)
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
        let body = task.text ?? ""
        
        return notificationContent(title, body: body, thread: .task
            , sound: .default, category: .task)
    }
    
    //MARK: notificationRequest(...)
    
    func notificationRequest(_ identifier: String, _ content: UNMutableNotificationContent, _ trigger: UNNotificationTrigger) -> UNNotificationRequest {
        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }
    
    func notificationDueDateRequest(for task: Task, _ offset: NotificationOffset = .atDueDate) -> UNNotificationRequest? {
        guard let trigger = notificationTrigger(for: task, with: offset.timeInterval) else {
            return nil
        }
        
        let content = notificationContentForDueDate(task: task)
        let identfier = task.id.uuidString
        
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
    
    func scheduleDueDateNotification(for task: Task, _ offset: NotificationOffset = .atDueDate) {
        guard let request = notificationDueDateRequest(for: task, offset) else {
            return
        }
        
        scheduleNotification(request)
    }
    
    //MARK: removeNotifications
    
    func removePendingNotifications(of task: Task) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
    }
    
    func removeDeliveredNotifications(of task: Task) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [task.id.uuidString])
    }
    
    func removeAllNotifications(of task: Task) {
        removePendingNotifications(of: task)
        removeDeliveredNotifications(of: task)
    }
    
    //MARK: getNotifications
    
    func getPendingNotifications(_ completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: completion)
    }
    
    func getPendingNotifications(of task: Task, _ completion: @escaping NotificationFetchRequest) {
        getPendingNotifications { (notifications) in
            let taskNotifications = notifications.filter { (notification) -> Bool in
                return notification.identifier == task.id.uuidString
            }
            completion(taskNotifications)
        }
    }
    
}
