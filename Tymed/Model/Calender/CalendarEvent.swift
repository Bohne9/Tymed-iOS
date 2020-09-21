//
//  CalendarEvent.swift
//  Tymed
//
//  Created by Jonah Schueller on 11.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit
import CoreData
import SwiftUI


/// A protocol that defines an general event in a calendar
/// See also: Lesson, Task, Event
class CalendarEvent: ObservableObject {
    
    static func lessonEvents(lessons: [Lesson]) -> [CalendarEvent] {
        return lessons.map { (lesson) in
            return CalendarEvent(managedObject: lesson)
        }
    }

    static func taskEvents(tasks: [Task]) -> [CalendarEvent] {
        return tasks.map { (task) in
            return CalendarEvent(managedObject: task)
        }
    }
    
    static func eventEvents(events: [Event]) -> [CalendarEvent] {
        return events.map { (event) in
            return CalendarEvent(managedObject: event)
        }
    }
    
    @Published
    var managedObject: NSManagedObject
    
    @Published
    var anchorDate = Date()
    
    var isLesson: Bool {
        return managedObject is Lesson
    }
    
    var isTask: Bool {
        return managedObject is Task
    }
    
    var isEvent: Bool {
        return managedObject is Event
    }
    
    var asLesson: Lesson? {
        return managedObject as? Lesson
    }
    
    var asTask: Task? {
        return managedObject as? Task
    }
    
    var asEvent: Event? {
        return managedObject as? Event
    }
    
    init(managedObject: NSManagedObject) {
        self.managedObject = managedObject
    }
    
    var id: UUID? {
        if let lesson = asLesson { // If the CalendarEvent is a Lesson
            return lesson.id
        } else if let task = asTask { // If the CalendarEvent is a Task
            return task.id
        } else if let event = asEvent { // If the CalendarEvent is an Event
            return event.id
        }else {
            return nil
        }
    }
    
    var title: String {
        if let lesson = asLesson { // If the CalendarEvent is a Lesson
            return lesson.subject?.name ?? "-"
        } else if let task = asTask { // If the CalendarEvent is a Task
            return task.title
        } else if let event = asEvent { // If the CalendarEvent is an Event
            return event.title
        }else {
            return "-"
        }
    }
    
    var startDate: Date? {
        if let lesson = asLesson { // If the CalendarEvent is a Lesson
            return lesson.nextStartDate(startingFrom: anchorDate)
        } else if let task = asTask { // If the CalendarEvent is a Task
            return task.due
        } else if let event = asEvent { // If the CalendarEvent is an Event
            return event.start
        }else {
            return nil
        }
    }
    
    var endDate: Date? {
        if let lesson = asLesson { // If the CalendarEvent is a Lesson
            return lesson.nextEndDate(startingFrom: anchorDate)
        } else if let task = asTask { // If the CalendarEvent is a Task
            return task.due
        } else if let event = asEvent { // If the CalendarEvent is an Event
            return event.end
        }else {
            return nil
        }
    }
    
    var color: UIColor? {
        if let lesson = asLesson { // If the CalendarEvent is a Lesson
            return UIColor(lesson)
        } else if let task = asTask { // If the CalendarEvent is a Task
            return UIColor(task.timetable)
        } else if let event = asEvent { // If the CalendarEvent is an Event
            return UIColor(event)
        }else {
            return nil
        }
    }
    
    var timetable: Timetable? {
        if let lesson = asLesson { // If the CalendarEvent is a Lesson
            return lesson.subject?.timetable
        } else if let task = asTask { // If the CalendarEvent is a Task
            return task.timetable
        } else if let event = asEvent { // If the CalendarEvent is an Event
            return event.timetable
        }else {
            return nil
        }
    }
    
    func collisionRank(in events: [CalendarEvent]) -> Int {
        var rank = 0
        
        for event in events {
            if collides(with: event) {
                rank += 1
            }else if event.id == id {
                break
            }
        }
        
        return rank
    }
    
    func collides(with event: CalendarEvent) -> Bool {
        guard let startDate = self.startDate,
              let endDate = self.endDate else {
            return false
        }
        
        guard event.id != id,
              let start = event.startDate,
              let end = event.endDate else {
            return false
        }
        
        return Calendar.current.isDateBetween(date: start, left: startDate, right: endDate) ||
            Calendar.current.isDateBetween(date: end, left: startDate, right: endDate) ||
            Calendar.current.isDateBetween(date: startDate, left: start, right: end) ||
            Calendar.current.isDateBetween(date: endDate, left: start, right: end)
    }
    
    func collisionCount(within events: [CalendarEvent]) -> Int {
        guard let startDate = self.startDate,
              let endDate = self.endDate else {
            print("COLLISION ERROR")
            return 0
        }
        
        var count = 0
        
        events.forEach { event in
            guard event.id != id,
                  let start = event.startDate,
                  let end = event.endDate else {
                return
            }
            
            if  Calendar.current.isDateBetween(date: start, left: startDate, right: endDate) ||
                Calendar.current.isDateBetween(date: end, left: startDate, right: endDate) ||
                Calendar.current.isDateBetween(date: startDate, left: start, right: end) ||
                Calendar.current.isDateBetween(date: endDate, left: start, right: end) {
                    count += 1
            }
        }
        
        return count
    }
    
}


extension CalendarEvent: Comparable {
    static func < (lhs: CalendarEvent, rhs: CalendarEvent) -> Bool {
        if lhs.startDate != rhs.startDate {
            guard let lStart = lhs.startDate, let rStart = rhs.startDate else {
                return false
            }
            return lStart < rStart
        }
        guard let lEnd = lhs.endDate, let rEnd = rhs.endDate else {
            return false
        }
        return lEnd < rEnd
    }
    
    static func == (lhs: CalendarEvent, rhs: CalendarEvent) -> Bool {
        return lhs.startDate == rhs.startDate && lhs.endDate == rhs.endDate
    }
    
    
}

extension CalendarEvent: Hashable {
    
    func hash(into hasher: inout Hasher) {
        self.managedObject.hash(into: &hasher)
    }
    
}
