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
            [.atEvent,
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
    
    static let atEvent    = NotificationOffset(value: 0)
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
        case .atEvent:    return "at due date"
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
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            if requests.count > 0 {
                print("Currently scheduled notifications:")
            }
            requests.forEach { (request) in
                print("\t \(request.content.categoryIdentifier)/\(request.content.threadIdentifier): Id: \(request.identifier) - Title: '\(request.content.title)', Body: '\(request.content.body)', at: \((request.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate()?.stringify(dateStyle: .full, timeStyle: .medium) ?? "")")
            }
        }
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
    
    private func notificationTrigger(at date: Date, repeats: Bool = false) -> UNCalendarNotificationTrigger {
        let comp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        return notificationTrigger(for: comp, repeats: repeats)
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
        
        return notificationTrigger(at: date, repeats: true)
    }
    
    private func notificationTrigger(for lesson: Lesson, with offset: TimeInterval) -> UNCalendarNotificationTrigger? {
        guard var start = lesson.startTime.date else {
            return nil
        }
        
        start = start - offset
        
        return notificationTrigger(at: start)
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
    
    private func notificationStartTimeContentFor(lesson: Lesson) -> UNMutableNotificationContent {
        
        let title = lesson.subject?.name ?? ""
        
        return notificationContent(title, body: "", thread: .lesson
                                   , sound: .default, category: .lesson)
    }
    
    //MARK: notificationRequest(...)
    
    func notificationRequest(_ identifier: String, _ content: UNMutableNotificationContent, _ trigger: UNNotificationTrigger) -> UNNotificationRequest {
        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }
    
    func notificationDueDateRequest(for task: Task, _ offset: NotificationOffset = .atEvent) -> UNNotificationRequest? {
        guard let trigger = notificationTrigger(for: task, with: offset.timeInterval) else {
            return nil
        }
        
        guard let identifier = task.id?.uuidString else {
            return nil
        }
        
        let content = notificationContentForDueDate(task: task)
        
        return notificationRequest(identifier, content, trigger)
    }
    
    func notificationStartTimeRequest(for lesson: Lesson, _ offset: NotificationOffset = .atEvent) -> UNNotificationRequest? {
        let trigger = notificationTrigger(for: lesson.startDateComponents)
        
        let content = notificationStartTimeContentFor(lesson: lesson)
        guard let identifier = lesson.id?.uuidString else {
            return nil
        }
        
        print("Schedule notification for lesson \(lesson.subject!.name) at: \(trigger.nextTriggerDate())")
        
        return notificationRequest(identifier, content, trigger)
    }
    
    //MARK: scheduleNotification
    func scheduleNotification(_ request: UNNotificationRequest) {
        
        requestAuthorization { (res, err) in
            if res {
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
    
    func scheduleDueDateNotification(for task: Task, _ offset: NotificationOffset = .atEvent) {
        guard let request = notificationDueDateRequest(for: task, offset) else {
            return
        }
        
        scheduleNotification(request)
    }
    
    func scheduleStartNotification(for lesson: Lesson, _ offset: NotificationOffset = .atEvent) {
        guard let request = notificationStartTimeRequest(for: lesson, offset) else {
            return
        }
        
        scheduleNotification(request)
    }
    
    //MARK: removeNotifications
    
    func removePendingNotifications(of task: Task) {
        guard let identifier = task.id?.uuidString else {
            return
        }
        print("Removing task notifications: \(identifier)")
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func removeDeliveredNotifications(of task: Task) {
        guard let identifier = task.id?.uuidString else {
            return
        }
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
    }
    
    func removeAllNotifications(of task: Task) {
        removePendingNotifications(of: task)
        removeDeliveredNotifications(of: task)
    }
    
    func removePendingNotifications(of lesson: Lesson) {
        guard let id = lesson.id?.uuidString else {
            return
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    func removeDeliveredNotifications(of lesson: Lesson) {
        guard let id = lesson.id?.uuidString else {
            return
        }
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
    }
    
    func removeAllNotifications(of lesson: Lesson) {
        removePendingNotifications(of: lesson)
        removeDeliveredNotifications(of: lesson)
    }
    
    //MARK: getNotifications
    
    func getPendingNotifications(_ completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: completion)
    }
    
    
    private func getPendingNotifications(of identifier: String, _ completion: @escaping NotificationFetchRequest) {
        getPendingNotifications { (notifications) in
            let notifications = notifications.filter { (notification) -> Bool in
                return notification.identifier == identifier
            }
            completion(notifications)
        }
    }
    
    func getPendingNotifications(of task: Task, _ completion: @escaping NotificationFetchRequest) {
        guard let identifier = task.id?.uuidString else {
            return
        }
        getPendingNotifications(of: identifier, completion)
    }
    
    func getPendingNotifications(of lesson: Lesson, _ completion: @escaping NotificationFetchRequest) {
        guard let id = lesson.id?.uuidString else {
            return
        }
        getPendingNotifications(of: id, completion)
    }
}
