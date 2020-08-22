//
//  CalendarDayEntry.swift
//  Tymed
//
//  Created by Jonah Schueller on 22.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import Foundation

class CalendarDayEntry: CalendarEntry {
    typealias Entry = Lesson
    
    var date: Date
    
    var entries: [Lesson]
    
    var lessonCount: Int {
        return entries.count
    }
    
    init(for date: Date, entries: [Lesson]) {
        self.date = date
        self.entries = entries.sorted(by: { (lhs, rhs) -> Bool in
            if lhs.startTime != rhs.endTime {
                return lhs.startTime < rhs.endTime
            }
            return lhs.endTime < rhs.endTime
        })
    }
    
    
}

