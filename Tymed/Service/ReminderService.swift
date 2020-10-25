//
//  ReminderService.swift
//  Tymed
//
//  Created by Jonah Schueller on 25.10.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import EventKit

class ReminderService: Service {
    
    static var shared: ReminderService = ReminderService()
    
    let eventStore: EKEventStore
    
    var calendars: [EKCalendar] = []
    
    init() {
        eventStore = EKEventStore()
        
    
        requestAccess { (res, err) in
            if res {
                print("Got access to reminder store!")
            }
            
            self.calendars = self.eventStore.calendars(for: .reminder)
        }
    }
    
    func requestAccess(_ completion: @escaping EKEventStoreRequestAccessCompletionHandler) {
        eventStore.requestAccess(to: .reminder, completion: completion)
    }

    func save(_ reminder: EKReminder) {
        try? eventStore.save(reminder, commit: true)
    }
    
    func addReminder() -> EKReminder {
        let reminder = EKReminder(eventStore: eventStore)
        
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        
        return reminder
    }
    
    
    func deleteReminder(_ reminder: EKReminder) {
        do {
            try eventStore.remove(reminder, commit: true)
            save(reminder)
        } catch {
            
        }
    }
    
    func incompleteReminders(in calendars: [EKCalendar]?, dueDateStart: Date? = Date(), _ completion: @escaping (([EKReminder]?) -> Void)) {
        let predicate = eventStore.predicateForIncompleteReminders(withDueDateStarting: dueDateStart, ending: nil, calendars: calendars)
        
        eventStore.fetchReminders(matching: predicate, completion: completion)
    }
    
    func incompleteReminders(_ completion: @escaping (([EKReminder]?) -> Void)) {
        incompleteReminders(in: calendars, completion)
    }
    
    func incompleteReminders(in calendar: EKCalendar, _ completion: @escaping (([EKReminder]?) -> Void)) {
        incompleteReminders(in: [calendar], completion)
    }
    
    func completeReminders(in calendars: [EKCalendar]?, dueDateStart: Date? = Date(), _ completion: @escaping (([EKReminder]?) -> Void)) {
        let predicate = eventStore.predicateForCompletedReminders(withCompletionDateStarting: dueDateStart, ending: nil, calendars: calendars)
        
        eventStore.fetchReminders(matching: predicate, completion: completion)
    }
    
    func completeReminders(_ completion: @escaping (([EKReminder]?) -> Void)) {
        completeReminders(in: calendars, completion)
    }
    
    func completeReminders(in calendar: EKCalendar, _ completion: @escaping (([EKReminder]?) -> Void)) {
        completeReminders(in: [calendar], completion)
    }
    
    
}


