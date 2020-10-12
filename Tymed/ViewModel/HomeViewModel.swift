//
//  HomeViewModel.swift
//  Tymed
//
//  Created by Jonah Schueller on 17.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI
import EventKit

class HomeViewModel: ObservableObject {
    
    private var timetableService = TimetableService.shared
    private var calendarService = CalendarService.shared
    private var eventService = EventService.shared
    
    @Published
    var tasks: [Task] = []
    
    var timetables: [Timetable] {
        return timetableService.fetchTimetables() ?? []
    }
    
    @Published
    var calendars: [EKCalendar] = []
    
    @Published
    var nextEvents: [EKEvent]?
    
    @Published
    var eventCountToday: Int = 0
    
    @Published
    var eventCountWeek: Int = 0
    
    @Published
    var nextCalendarEvent: EKEvent?
    
    @Published
    var calendarWeek: CalendarWeekEntry
    
    @Published
    var currentDate = Date()
    
    private var anchorDate: Date
    
    init(anchor: Date = Date()) {
        anchorDate = anchor
        
        nextEvents = eventService.nextEvents(in: eventService.calendars)
        
        eventCountToday = eventService.events(startingFrom: Date(), end: Date().endOfDay, in: eventService.calendars).count
        
        eventCountWeek = eventService.events(startingFrom: Date(), end: Date().endOfWeek ?? Date(), in: eventService.calendars).count
        
        tasks = timetableService.getTasks(after: anchorDate).sorted()
        
        calendarWeek = CalendarWeekEntry(startingFrom: anchorDate, expandsToEntireDay: false)
        
        calendarWeek.removeEmptyDays()
        
        calendars = eventService.calendars
        
        scheduleTimeUpdater()
        
        objectWillChange.send()
    }
    
    private func taskThresholdDate() -> Date {
        guard let offset = SettingsService.shared.taskAutoArchivingDelay else {
            return anchorDate
        }
        
        return anchorDate - offset.timeinterval
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
        anchorDate = Date()
        
        nextEvents = eventService.nextEvents(in: eventService.calendars)
        
        eventCountToday = eventService.events(startingFrom: Date(), end: Date().endOfDay, in: eventService.calendars).count
        
        eventCountWeek = eventService.events(startingFrom: Date(), end: Date().endOfWeek ?? Date(), in: eventService.calendars).count
        
        tasks = timetableService.getTasks(after: anchorDate).sorted()
        
        calendarWeek = CalendarWeekEntry(startingFrom: anchorDate, expandsToEntireDay: false)
        
        calendarWeek.removeEmptyDays()
        
        calendars = eventService.calendars
        
        objectWillChange.send()
    }
    
    
    func tasks(for timetable: Timetable) -> [Task] {
        return tasks.filter { task in
            return task.timetable == timetable
        }
    }
}


extension HomeViewModel: DetailViewPresentationDelegate {
    
    /// Dismisses the view
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
//        dismiss()
        reload()
    }
    
    func shouldDismiss() -> Bool {
        return !TimetableService.shared.hasChanges()
    }
    
}
