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
    
    var startOfWeek: Date
    
    var entryCount: Int {
        return entries.count
    }
    
    init(date: Date) {
        self.startOfWeek = date.startOfWeek ?? Date()
        self.entries = CalendarService.shared.calendarWeekEntries(for: startOfWeek).filter({ (entry) -> Bool in
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
