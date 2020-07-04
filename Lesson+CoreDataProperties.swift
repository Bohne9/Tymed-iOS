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


extension Lesson {

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

    var day: Day {
        return Day(rawValue: Int(dayOfWeek)) ?? .monday
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
