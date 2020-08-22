//
//  CalendarDayEntry.swift
//  Tymed
//
//  Created by Jonah Schueller on 22.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import Foundation

struct CalendarDayEntry: CalendarEntry {
    
    var date: Date
    
    var lessons: [Lesson]
    
    init(for date: Date, lessons: [Lesson]) {
        self.date = date
        self.lessons = lessons
    }
    
    
}

