//
//  ReminderViewModel.swift
//  Tymed
//
//  Created by Jonah Schueller on 25.10.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import Foundation
import EventKit

class ReminderViewModel: ObservableObject {
    
    private(set) var reminder: EKReminder
    
    @Published var title: String! {
        didSet { reminder.title = title }
    }
    
    @Published var dueDateComponents: DateComponents? {
        didSet { reminder.dueDateComponents = dueDateComponents }
    }
    
    @Published var isCompleted: Bool = false {
        didSet { reminder.isCompleted = isCompleted }
    }
    
    @Published var completionDate: Date? {
        didSet { reminder.completionDate = completionDate }
    }
    
    @Published var calendar: EKCalendar! {
        didSet { reminder.calendar = calendar }
    }
    
    @Published var notes: String? {
        didSet { reminder.notes = notes }
    }
    
    @Published var url: URL? {
        didSet { reminder.url = url }
    }
    
    var isNew: Bool {
        reminder.isNew
    }
    
    var hasChanges: Bool {
        reminder.hasChanges
    }
    
    var hasNotes: Bool {
        reminder.hasNotes
    }
    
    var hasAlarms: Bool {
        reminder.hasAlarms
    }
    
    
    init(_ reminder: EKReminder) {
        self.reminder = reminder
    }
    
    func refresh() {
        reminder.refresh()
        
        title = reminder.title
        dueDateComponents = reminder.dueDateComponents
        isCompleted = reminder.isCompleted
        completionDate = reminder.completionDate
        calendar = reminder.calendar
        notes = reminder.notes
        url = reminder.url
        
    }
}
