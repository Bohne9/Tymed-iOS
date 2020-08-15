//
//  Subject+CoreDataProperties.swift
//  Tymed
//
//  Created by Jonah Schueller on 14.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//
//

import Foundation
import CoreData


extension Subject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Subject> {
        return NSFetchRequest<Subject>(entityName: "Subject")
    }

    @NSManaged public var color: String
    @NSManaged public var createdAt: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String
    @NSManaged public var lessons: NSSet?
    @NSManaged public var timetable: Timetable?

}

// MARK: Generated accessors for lessons
extension Subject {

    @objc(addLessonsObject:)
    @NSManaged public func addToLessons(_ value: Lesson)

    @objc(removeLessonsObject:)
    @NSManaged public func removeFromLessons(_ value: Lesson)

    @objc(addLessons:)
    @NSManaged public func addToLessons(_ values: NSSet)

    @objc(removeLessons:)
    @NSManaged public func removeFromLessons(_ values: NSSet)

}

extension Subject : Identifiable {

}
