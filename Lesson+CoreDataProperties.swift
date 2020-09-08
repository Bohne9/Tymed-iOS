//
//  Lesson+CoreDataProperties.swift
//  Tymed
//
//  Created by Jonah Schueller on 18.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//
//

import Foundation
import CoreData


extension Lesson: Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Lesson> {
        return NSFetchRequest<Lesson>(entityName: "Lesson")
    }

    @NSManaged public var dayOfWeek: Int32
    @NSManaged public var end: Int32
    @NSManaged public var id: UUID?
    @NSManaged public var note: String?
    @NSManaged public var start: Int32
    @NSManaged public var subject: Subject?
    @NSManaged public var tasks: NSSet?
    
    var unarchivedTasks: [Task]? {
        return (tasks?.allObjects)?.filter { task in
            !(task as! Task).archived
        } as? [Task]
    }
    
    var day: Day {
        get {
            return Day(rawValue: Int(dayOfWeek)) ?? .monday
        }
        set {
            dayOfWeek = Int32(newValue.rawValue)
        }
    }
    
    var startTime: Time {
        get {
            Time(timeInterval: Int(start))
        }
        set {
            start = Int32(newValue.timeInterval)
        }
    }
    
    var endTime: Time {
        get {
            Time(timeInterval: Int(end))
        }
        set {
            end = Int32(newValue.timeInterval)
        }
    }
    
    private func nextDate(_ start: Date, _ components: DateComponents) -> Date? {
        Calendar.current.nextDate(after: start, matching: components, matchingPolicy: .strict)
    }
    
    func nextStartDate(startingFrom date: Date = Date()) -> Date? {
        nextDate(date, startDateComponents)
    }
    
    
    func nextEndDate(startingFrom date: Date = Date()) -> Date? {
        nextDate(date, endDateComponents)
    }
    
    var startDateComponents: DateComponents {
        var components = DateComponents()
        components.weekday = Int(dayOfWeek)
        components.hour = startTime.hour
        components.minute = startTime.minute
        
        return components
    }
    
    var endDateComponents: DateComponents {
        var components = DateComponents()
        components.weekday = Int(dayOfWeek)
        components.hour = endTime.hour
        components.minute = endTime.minute
        
        return components
    }
    
    func getNotifications(_ completion: @escaping NotificationFetchRequest) {
        NotificationService.current.getPendingNotifications(of: self, completion)
    }
}

// MARK: Generated accessors for tasks
extension Lesson {

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: Task)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: Task)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)

}
