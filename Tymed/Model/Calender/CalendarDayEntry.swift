//
//  CalendarDayEntry.swift
//  Tymed
//
//  Created by Jonah Schueller on 22.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

class CalendarDayEntry: ObservableObject, CalendarEntry {
    typealias Entry = CalendarEvent
    
    @Published
    var date: Date
    
    @Published
    var entries: [CalendarEvent]
    
    var eventCount: Int {
        return entries.count
    }
    
    var startOfDay: Date? {
        return entries.first?.startDate
    }
    
    var endOfDay: Date? {
        return entries.last?.endDate
    }
    
    init(for date: Date, entries: [CalendarEvent]) {
        self.date = date.startOfDay
        self.entries = entries.sorted()
    }
    
    
}

