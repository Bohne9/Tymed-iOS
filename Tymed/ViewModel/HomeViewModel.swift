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
    
    var timetables: [Timetable] {
        return timetableService.fetchTimetables() ?? []
    }
    
    @Published
    var upcomingCalendarDay: CalendarDayEntry
    
    @Published
    var nextCalendarDay: CalendarDayEntry?
    
    @Published
    var currentDate = Date()
    
    private var anchorDate: Date
    
    init(anchor: Date = Date()) {
        anchorDate = anchor
        
        tasks = timetableService.getTasks(after: anchorDate.prevDay).sorted()
        
        upcomingCalendarDay = calendarService.getNextCalendarDayEntry(startingFrom: anchorDate)
        
        if let upcomingEndDate = upcomingCalendarDay.endOfDay?.nextDay {
            nextCalendarDay = calendarService.getNextCalendarDayEntry(startingFrom: upcomingEndDate)
        }
        
        scheduleTimeUpdater()
    }
    
    func scheduleTimeUpdater() {
        
        var zeroSeconds = DateComponents()
        zeroSeconds.second = 0
        guard let nextMinute = Calendar(identifier: .gregorian).nextDate(after: Date(), matching: zeroSeconds, matchingPolicy: .nextTime, direction: .forward) else {
          // This should not happen since there should always be a next minute
          return
        }

        let timer = Timer(fire: nextMinute.advanced(by: 0.1), interval: 60, repeats: true) { _ in
            self.currentDate = Date()
        }
        RunLoop.current.add(timer, forMode: .default)
    }
    
    func reload() {
        tasks = timetableService.getTasks(after: anchorDate).sorted()
        
        upcomingCalendarDay = calendarService.getNextCalendarDayEntry(startingFrom: anchorDate)
        
        if let upcomingEndDate = upcomingCalendarDay.endOfDay?.nextDay {
            nextCalendarDay = calendarService.getNextCalendarDayEntry(startingFrom: upcomingEndDate)
        }
        
        objectWillChange.send()
    }
    
    
    func tasks(for timetable: Timetable) -> [Task] {
        return tasks.filter { task in
            return task.timetable == timetable
        }
    }
}


extension HomeViewModel: DetailViewPresentationDelegate {
    
    /// Dismisses the view controller
    func dismiss() {
        objectWillChange.send()
    }
    
    /// Resets the core data model and dismisses the view controller
    func cancel() {
        TimetableService.shared.rollback()
        dismiss()
    }
    
    /// Saves the core data model and dismisses the view controller
    func done() {
        TimetableService.shared.save()
        dismiss()
    }
    
    func shouldDismiss() -> Bool {
        return !TimetableService.shared.hasChanges()
    }
    
}
