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
    
    private(set) var startOfDay: Date?
    
    private(set) var endOfDay: Date?
    
    init(for date: Date, entries: [CalendarEvent]) {
        self.date = date.startOfDay
        self.entries = entries.sorted()
         
        startOfDay = entries.first?.startDate
        endOfDay = entries.last?.endDate
    }
    
    func expandToEntireDay() {
        startOfDay = date.startOfDay
        endOfDay = date.endOfDay
        objectWillChange.send()
    }
    
}

