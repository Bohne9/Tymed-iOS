//
//  HomeViewModel.swift
//  Tymed
//
//  Created by Jonah Schueller on 17.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    
    private var timetableService = TimetableService.shared
    private var calendarService = CalendarService.shared
    
    @Published
    var tasks: [Task] = []
    
    var events: [CalendarEvent] {
        upcomingCalendarDay.entries
    }
    
    @Published
    var upcomingCalendarDay: CalendarDayEntry
    
    @Published
    var nextCalendarDay: CalendarDayEntry?
    
    private var anchorDate: Date
    
    init(anchor: Date = Date()) {
        anchorDate = anchor
        
        tasks = timetableService.getTasks(after: anchorDate).sorted()
        
        upcomingCalendarDay = calendarService.getNextCalendarDayEntry(startingFrom: anchorDate)
        
        if let upcomingEndDate = upcomingCalendarDay.endOfDay?.nextDay {
            nextCalendarDay = calendarService.getNextCalendarDayEntry(startingFrom: upcomingEndDate)
        }
    }
    
    func reload() {
        tasks = timetableService.getTasks(after: anchorDate).sorted()
        
        upcomingCalendarDay = calendarService.getNextCalendarDayEntry(startingFrom: anchorDate)
        
        if let upcomingEndDate = upcomingCalendarDay.endOfDay?.nextDay {
            nextCalendarDay = calendarService.getNextCalendarDayEntry(startingFrom: upcomingEndDate)
        }
        
        objectWillChange.send()
    }
    
}
