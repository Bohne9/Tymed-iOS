//
//  CalendarService.swift
//  Tymed
//
//  Created by Jonah Schueller on 22.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import Foundation

class CalendarService: Service {
    
    typealias T = CalendarService
    
    static var shared: CalendarService = CalendarService()
    
    private var calendar = Calendar(identifier: .gregorian)
    
    //MARK: eventsForDay
    /// Returns a list of lessons that match the weekday of the date.
    /// - Parameter date: Date
    /// - Returns: Returns a list of lessons that match the given weekday of the date.
    func eventsForDay(date: Date) -> [CalendarEvent] {
        return TimetableService.shared.calendarEventsFor(day: date)
    }
    
    //MARK: calendarDayEntry
    /// Generates a CalendarDayEntry for the given day
    /// - Parameter date: Date for the CalendarDayEntry
    /// - Returns: A CalendarDayEntry for the date.
    func calendarDayEntry(for date: Date) -> CalendarDayEntry {
        return CalendarDayEntry(for: date, entries: eventsForDay(date: date))
    }
    
    //MARK: calendarWeekEntries
    /// Returns a list of CalendarEntries for a given week.
    /// - Parameter week: Date within the requested date. The date does not necessarily has to be the start of the week.
    /// - Returns: Returns a list of CalendarEntries for each day within the week.
    func calendarWeekEntries(for week: Date) -> [CalendarDayEntry] {
        // Get the start date of the week (Monday)
        guard let startOfWeek = week.startOfWeek else {
            return []
        }
        
        var date = startOfWeek
        // Declare a list to save the entries
        var entries: [CalendarDayEntry] = []
        
        // For each day in the week
        for _ in 0..<7 {
            // Append a CalendarDayEntry for the current day to the list
            entries.append(calendarDayEntry(for: date))
            
            // Get the date of the next day
            if let next = nextDay(after: date) {
                date = next
            }else { // If there is no date -> break
                break
            }
        }
        
        // Return the list of entries
        return entries
    }
    
    //MARK: nextDay
    /// Returns the next day after the given day.
    /// - Parameter date: Date before the day.
    /// - Returns: Returns the next day after date
    private func nextDay(after date: Date) -> Date? {
        var components = DateComponents()
        
        // Set it to be the next day
        components.day = 1
        
        // Get the next day
        return calendar.date(byAdding: components, to: date)
    }
 
    //MARK: previousWeek
    /// Returns the date one week before the given day.
    /// - Parameter date: Current date
    /// - Returns: One week before the current date
    func previousWeek(before date: Date) -> Date? {
        var components = DateComponents()
        
        // Set it to be the previous week
        components.weekOfMonth = -1
        
        // Get the previous week
        return calendar.date(byAdding: components, to: date)
    }
    
    //MARK: nextWeek
    /// Returns the date one week after the given day.
    /// - Parameter date: Current date
    /// - Returns: One week after the current date
    func nextWeek(after date: Date) -> Date? {
        var components = DateComponents()
        
        // Set it to be the next week
        components.weekOfMonth = 1
        
        // Get the next week
        return calendar.date(byAdding: components, to: date)
    }
    
}


