//
//  TaskViewModel.swift
//  Tymed
//
//  Created by Jonah Schueller on 01.10.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI
import EventKit

class TaskViewModel: ObservableObject {
    
    private let timetable = TimetableService.shared
    private let reminderService = ReminderService.shared
    
    @Published
    var includeDone = true {
        didSet {
            reload()
        }
    }
    
    /// Contains all tasks that aren't archived at the moment
    @Published
    var tasks: [EKReminder] = []
    
    /// Contains all tasks without a due date.
    @Published
    var unlimitedTasks: [EKReminder] = []
    
    /// Contains all tasks with a due date in the past
    @Published
    var overdueTasks: [EKReminder] = []
    
    /// Contains all tasks that with a due date within today
    @Published
    var todayTasks: [EKReminder] = []
    
    /// Contains all tasks that with a due date within a week
    @Published
    var weekTasks: [EKReminder] = []
    
    /// Contains all tasks that are scheduled for a date more than a month ahead.
    @Published
    var laterTasks: [EKReminder]  = []
    
    /// Contains all tasks that were archived via the automatics archive process at the start cycle of the app.
    @Published
    var recentlyArchived: [EKReminder] = []
    
    /// Contains all tasks that are archived.
    @Published
    var archivedTasks: [EKReminder] = []
 
    var hasTasks: Bool {
        return !tasks.isEmpty
    }
    
    init() {
        reload()
    }
    
    /// Reloads all task lists
    func reload() {
        
        // Get all unarchived tasks
        reminderService.reminders(in: reminderService.calendars) { (reminders) in
            self.tasks = reminders ?? []
            
            if !self.includeDone {
                self.tasks = self.tasks.filter { !$0.isCompleted }
            }
        }
        
        
        // Filter the tasks again just in case the user unarchived a task.
//        recentlyArchived = BackgroundRoutineService.standard.archivedTasksOfSession?.filter { $0.archived } ?? []
        
//        archivedTasks = timetable.getArchivedTasks()
        
    }
    
    private func dueDate(for reminder: EKReminder) -> Date? {
        guard let components = reminder.dueDateComponents else {
            return nil
        }
        
        return Calendar.current.date(from: components)
    }
    
    private func reloadValues() {
        let now = Date()
        
        overdueTasks = tasks.filter { task in
            guard let dueDate = dueDate(for: task),
                  task.isCompleted else {
                return false
            }
            return dueDate < now
        }
        
        todayTasks = tasks.filter { task in
            guard let dueDate = dueDate(for: task) else {
                return false
            }
            return dueDate >= now && Calendar.current.isDateInToday(dueDate)
        }
        
        weekTasks = tasks.filter { task in
            guard let dueDate = dueDate(for: task),
                  let endOfWeek = now.endOfWeek else {
                return false
            }
            return dueDate >= now.endOfDay && dueDate < endOfWeek
        }
        
        laterTasks = tasks.filter { task in
            guard let dueDate = dueDate(for: task),
                  let endOfWeek = now.endOfWeek else {
                return false
            }
            return dueDate > endOfWeek
        }
        
        unlimitedTasks = tasks.filter { task in
            return dueDate(for: task) == nil
        }
    }
    
    /// Filters all tasks by the given timetable
    /// - Parameter timetable: EKCalendar for the tasks
    /// - Returns: Returns a list of reminders attached to the given calendar.
    func tasks(for calendar: EKCalendar) -> [EKReminder] {
        return tasks.filter { $0.calendar == calendar }
    }
    
    func completedTasks(for calendar: EKCalendar) -> [EKReminder] {
        return tasks(for: calendar).filter { $0.isCompleted }
    }

    func remainingTasks(for calendar: EKCalendar) -> [EKReminder] {
        return tasks(for: calendar).filter { !$0.isCompleted }
    }
    
}
