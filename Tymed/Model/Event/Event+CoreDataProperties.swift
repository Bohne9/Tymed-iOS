//
//  Event+CoreDataProperties.swift
//  Tymed
//
//  Created by Jonah Schueller on 08.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

extension Event {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Event> {
        return NSFetchRequest<Event>(entityName: "Event")
    }

    @NSManaged public var title: String
    @NSManaged public var start: Date?
    @NSManaged public var end: Date?
    @NSManaged public var createdAt: Date?
    @NSManaged public var body: String?
    @NSManaged public var notes: String?
    @NSManaged public var notificationID: UUID?
    @NSManaged public var allDay: Bool
    @NSManaged public var notificationDate: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var task: Task?
    @NSManaged public var subject: Subject?
    @NSManaged public var lesson: Lesson?
    @NSManaged public var timetable: Timetable?

    
    var isValid: Bool {
        return !title.isEmpty &&
                start != nil &&
                end != nil &&
                id != nil &&
                timetable != nil
    }
}

extension Event : Identifiable {

}
