//
//  CalendarDayEntry.swift
//  Tymed
//
//  Created by Jonah Schueller on 22.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI
import EventKit

class CalendarDayEntry: ObservableObject, CalendarEntry {
    typealias Entry = EKEvent
    
    @Published
    var date: Date
    
    @Published
    var entries: [EKEvent] = []
    
    @Published
    var allDayEntries: [EKEvent] = []
    
    var eventCount: Int {
        return entries.count
    }
    
    private(set) var startOfDay: Date?
    
    private(set) var endOfDay: Date?
    
    init(for date: Date, entries: [EKEvent]) {
        self.date = date.startOfDay
                
        setEntries(entries)
        
        startOfDay = firstEventBegin()
        endOfDay = lastEventEnding()
    }
    
    func firstEventBegin() -> Date? {
        return entries.sorted { (lhs, rhs) -> Bool in
            guard let lhsStart = lhs.startDate,
                  let rhsStart = rhs.startDate else {
                return false
            }
            
            return lhsStart < rhsStart
        }.first?.startDate
    }
    
    func lastEventEnding() -> Date? {
        return entries.sorted { (lhs, rhs) -> Bool in
            guard let lhsEnd = lhs.endDate,
                  let rhsEnd = rhs.endDate else {
                return false
            }
            
            return lhsEnd < rhsEnd
        }.last?.endDate
    }
    
    func setEntries(_ entries: [EKEvent]) {
        let allEntries = entries.sorted(by: { (lhs, rhs) -> Bool in
            return lhs.startDate < rhs.startDate
        })
        
        self.allDayEntries = allEntries
            .filter { $0.isAllDay }
        
        self.entries = allEntries
            .filter { !$0.isAllDay }
    }
    
    func expandToEntireDay() {
        startOfDay = date.startOfDay
        endOfDay = date.endOfDay
        objectWillChange.send()
    }
    
    
    
    
    func collisionRank(for event: EKEvent) -> Int {
        var rank = 0
        
        for entry in entries {
            if collides(event, entry) {
                rank += 1
            }else if entry.eventIdentifier == event.eventIdentifier {
                break
            }
        }
        
        return rank
    }
    
    func collides(_ lhs: EKEvent, _ rhs: EKEvent) -> Bool {
        guard let startDate = lhs.startDate,
              let endDate = lhs.endDate else {
            return false
        }
        
        guard lhs.eventIdentifier != rhs.eventIdentifier,
              let start = rhs.startDate,
              let end = rhs.endDate else {
            return false
        }
        
        return Calendar.current.isDateBetween(date: start, left: startDate, right: endDate) ||
            Calendar.current.isDateBetween(date: end, left: startDate, right: endDate) ||
            Calendar.current.isDateBetween(date: startDate, left: start, right: end) ||
            Calendar.current.isDateBetween(date: endDate, left: start, right: end)
    }
    
    func collisionCount(for event: EKEvent, within events: [EKEvent]) -> Int {
        guard let startDate = event.startDate,
              let endDate = event.endDate else {
            return 0
        }
        
        var count = 0
        
        events.forEach { entry in
            guard entry.eventIdentifier != event.eventIdentifier,
                  let start = entry.startDate,
                  let end = entry.endDate else {
                return
            }
            
            if Calendar.current.isDateBetween(date: start, left: startDate, right: endDate) ||
               Calendar.current.isDateBetween(date: end, left: startDate, right: endDate) ||
               Calendar.current.isDateBetween(date: startDate, left: start, right: end) ||
               Calendar.current.isDateBetween(date: endDate, left: start, right: end) {
                    count += 1
            }
        }
        
        return count
    }
    
    /// Returns the number of events where the difference of the startDates is less than or equal to the given threshold.
    /// - Parameters:
    ///   - event: Anchor event.
    ///   - events: Events for the comparision.
    ///   - withMaximumDistance: TimeInterval threshold.
    func collisionsOfStartDate(for event: EKEvent, in events: [EKEvent], withMaximumDistance distance: TimeInterval) -> Int {
        guard let startDate = event.startDate else {
            return 0
        }
        
        var count = 0
        
        events.forEach { entry in
            guard collides(event, entry), // Make sure only colliding events count
                  let start = entry.startDate // Prevent force-unwrapping
            else {
                return
            }
            
            if abs(startDate.timeIntervalSince(start)) <= distance {
                count += 1
            }
        }
        
        return count
    }
}

