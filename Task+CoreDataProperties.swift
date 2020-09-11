//
//  Task+CoreDataProperties.swift
//  Tymed
//
//  Created by Jonah Schueller on 03.07.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var completed: Bool
    @NSManaged public var due: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var priority: Int32
    @NSManaged public var text: String?
    @NSManaged public var title: String
    @NSManaged public var completionDate: Date?
    @NSManaged public var lesson: Lesson?
    @NSManaged public var archived: Bool
    @NSManaged public var timetable: Timetable

    func getNotifications(_ completion: @escaping NotificationFetchRequest) {
        NotificationService.current.getPendingNotifications(of: self, completion)
    }
    
    func iconForCompletion() -> String {
        if completed {
            return "checkmark.circle.fill"
        }else if due == nil {
            return "circle"
        } else if due != nil  && due! < Date() {
            return "exclamationmark.circle.fill"
        }
        // Just a default case
        return "circle"
    }
    
    func completeColor() -> UIColor {
        if completed {
            if due == nil || completionDate ?? Date() <= due ?? Date() {
                return .systemGreen
            }else {
                return .systemOrange
            }
        }else {
            if due == nil || Date() <= due ?? Date() {
                return .systemBlue
            }else {
                return .systemRed
            }
        }
    }
}

extension Task: Comparable {
    
    public static func < (lhs: Task, rhs: Task) -> Bool {
        guard let d1 = lhs.due, let d2 = rhs.due else {
            return true
        }
        return d1 < d2
    }
    
}


extension Task: CalendarEvent {
        
    var startDate: Date? {
        get {
            return due
        }
        set {
            due = newValue
        }
    }
    
    var endDate: Date? {
        get {
            return due
        }
        set {
            due = newValue
        }
    }
    
    var color: UIColor? {
        get {
            if lesson != nil {
                return UIColor(lesson)
            }
            return UIColor(timetable)
        }
        set {
            
        }
    }
    
}
