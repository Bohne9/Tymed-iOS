//
//  CalendarViewModel.swift
//  Tymed
//
//  Created by Jonah Schueller on 29.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

class CalendarViewModel: ObservableObject {
    
    private let calendarService = CalendarService.shared
    
//    @Published
    var dayEntries: [CalendarDayEntry] = []

    @Published
    var weekEntries: [CalendarWeekEntry] = []

    @Published
    var index = 1
    
    @Published
    var currentDate = Date()
    
    init() {
        let now = Date()
        
        dayEntries = [
            calendarService.calendarDayEntry(for: now.prevDay),
            calendarService.calendarDayEntry(for: now),
            calendarService.calendarDayEntry(for: now.nextDay)
        ]
        
        
        dayEntries.forEach { entry in
            entry.expandToEntireDay()
        }
        
    }
    
    
    func reload() {
        dayEntries.forEach { (entry) in
            entry.setEntries(calendarService.eventsForDay(date: entry.date))
        }
        
        dayEntries.forEach { entry in
            entry.expandToEntireDay()
        }
        
        objectWillChange.send()
    }
    
    
    func titleForDay() -> String {
        return currentDate.stringify(with: .medium)
    }
    
    func fetchPrev() {
        guard let date = dayEntries.first?.date else {
            return
        }
        
        dayEntries.insert(calendarService.calendarDayEntry(for: date.prevDay), at: 0)
//        index += 1
        objectWillChange.send()
    }
    
    func fetchNext() {
        guard let date = dayEntries.last?.date else {
            return
        }
        
        dayEntries.insert(calendarService.calendarDayEntry(for: date.nextDay), at: dayEntries.count)
        objectWillChange.send()
    }
    
    func nextDay() {
        currentDate = currentDate.nextDay
    }
    
    func prevDay() {
        currentDate = currentDate.prevDay
    }
    
    func currentDay() {
        currentDate = Date()
    }
}

