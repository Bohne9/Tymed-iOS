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
        self.entries = entries.sorted(by: { (lhs, rhs) -> Bool in
            return lhs < rhs
        })
         
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
    
    func expandToEntireDay() {
        startOfDay = date.startOfDay
        endOfDay = date.endOfDay
        objectWillChange.send()
    }
    
}

