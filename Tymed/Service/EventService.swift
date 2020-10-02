//
//  EventService.swift
//  Tymed
//
//  Created by Jonah Schueller on 02.10.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import Foundation
import EventKit

class EventService: Service {
    
    static var shared = EventService()
    
    private let eventStore: EKEventStore
    
    var calendars: [EKCalendar] = []

    init() {
        
        eventStore = EKEventStore()
        
        requestAccess { (res, err) in
            if res {
                print("Got access!")
            }
            
            self.events(startingFrom: Date(), end: self.oneYearFromNow(), in: self.eventStore.calendars(for: .event))
                .forEach { (event) in
                    print(event)
                }
        }
        
        calendars = eventStore.calendars(for: .event)
    }
    
    func requestAccess(_ completion: @escaping EKEventStoreRequestAccessCompletionHandler) {
        eventStore.requestAccess(to: .event, completion: completion)
    }
    
    func save(_ event: EKEvent, span: EKSpan) {
        try? eventStore.save(event, span: span, commit: true)
    }
    
    //MARK: Create events
    func addEvent() -> EKEvent {
        let event = EKEvent(eventStore: eventStore)
        
        return event
    }
    
    //MARK: Date
    func oneYearFrom(date: Date) -> Date {
        var comp = DateComponents()
        comp.year = 1
        let nextDate = Calendar.current.date(byAdding: comp, to: date)
        return nextDate ?? Date()
    }
    
    func oneMonthFrom(date: Date) -> Date {
        var comp = DateComponents()
        comp.month = 1
        let nextDate = Calendar.current.date(byAdding: comp, to: date)
        return nextDate ?? Date()
    }
    
    func oneDayFrom(date: Date) -> Date {
        var comp = DateComponents()
        comp.day = 1
        let nextDate = Calendar.current.date(byAdding: comp, to: date)
        return nextDate ?? Date()
    }
    
    //MARK: Retrieving Events
    func oneYearFromNow() -> Date {
        return oneYearFrom(date: Date())
    }
    
    func events(startingFrom: Date, end: Date, in calendars: [EKCalendar]) -> [EKEvent] {
        let predicate = eventStore.predicateForEvents(withStart: startingFrom, end: end, calendars: calendars)
        
        return eventStore.events(matching: predicate)
    }
 
    func events(forDay date: Date, in calendar: [EKCalendar]) -> [EKEvent] {
        return events(startingFrom: date.startOfDay, end: date.endOfDay, in: calendar)
    }
    
    func eventsForToday(in calendar: [EKCalendar]) -> [EKEvent] {
        return events(forDay: Date(), in: calendar)
    }
    
    func nextEvents(in calendar: [EKCalendar]) -> [EKEvent] {
        let now = Date()
        let nextYear = oneYearFrom(date: now)
        
        return events(startingFrom: now, end: nextYear, in: calendar)
    }
    
}
