//
//  CaleanderWeekEntry.swift
//  Tymed
//
//  Created by Jonah Schueller on 22.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import Foundation

class CalendarWeekEntry: CalendarEntry {
    typealias Entry = CalendarDayEntry
    
    static func entryForCurrentWeek() -> CalendarWeekEntry {
        return CalendarWeekEntry(date: Date())
    }
    
    var entries: [CalendarDayEntry] = []
    
    var date: Date
    
    var startOfWeek: Date? {
        return entries.first?.startOfDay
    }
    
    var endOfWeek: Date? {
        return entries.last?.endOfDay
    }
    
    var entryCount: Int {
        return entries.count
    }
    
    init(date: Date) {
        self.date = date.startOfWeek ?? Date()
        self.entries = CalendarService.shared.calendarWeekEntries(for: date)
            .filter({ (entry) -> Bool in
            return entry.lessonCount > 0
        })
    }
    
    func calendarDayEntry(for day: Day) -> CalendarDayEntry? {
        return entries[day.index]
    }
    
    func calendarDayEntry(for index: Int) -> CalendarDayEntry {
        return entries[index]
    }
    
    func dayForEntry(at index: Int) -> Day? {
        return Day.from(date: entries[index].date)
    }
    
    
    
}
