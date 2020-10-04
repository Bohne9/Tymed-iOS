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
    
    convenience init(date: Date) {
        self.init(startingFrom: date.startOfWeek ?? date)
    }
    
    init(startingFrom date: Date, expandsToEntireDay: Bool = true) {
        self.date = date
        self.entries = CalendarService.shared.calendarWeekEntries(for: date)
        
        if expandsToEntireDay {
            entries.forEach { (entry) in
                entry.expandToEntireDay()
            }
        }
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
