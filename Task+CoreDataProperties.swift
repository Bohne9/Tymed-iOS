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


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var completed: Bool
    @NSManaged public var due: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var priority: Int32
    @NSManaged public var text: String?
    @NSManaged public var title: String?
    @NSManaged public var completionDate: Date?
    @NSManaged public var lesson: Lesson?

}
