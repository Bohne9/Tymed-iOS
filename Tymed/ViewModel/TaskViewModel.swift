//
//  TaskViewModel.swift
//  Tymed
//
//  Created by Jonah Schueller on 01.10.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

class TaskViewModel: ObservableObject {
    
    private let timetable = TimetableService.shared
    
    @Published
    var includeDone = true {
        didSet {
            reload()
        }
    }
    
    /// Contains all tasks that aren't archived at the moment
    @Published
    var tasks: [Task] = []
    
    /// Contains all tasks without a due date.
    @Published
    var unlimitedTasks: [Task] = []
    
    /// Contains all tasks with a due date in the past
    @Published
    var overdueTasks: [Task] = []
    
    /// Contains all tasks that with a due date within today
    @Published
    var todayTasks: [Task] = []
    
    /// Contains all tasks that with a due date within a week
    @Published
    var weekTasks: [Task] = []
    
    /// Contains all tasks that are scheduled for a date more than a month ahead.
    @Published
    var laterTasks: [Task]  = []
    
    /// Contains all tasks that were archived via the automatics archive process at the start cycle of the app.
    @Published
    var recentlyArchived: [Task] = []
 
    init() {
        reload()
    }
    
    /// Reloads all task lists
    func reload() {
        
        // Get all unarchived tasks
        tasks = timetable.getAllTasks()
        if !includeDone {
            tasks = tasks.filter { !$0.completed }
        }
        
        // Filter the tasks again just in case the user unarchived a task.
        recentlyArchived = BackgroundRoutineService.standard.archivedTasksOfSession?.filter { $0.archived } ?? []
        
        let now = Date()
        
        overdueTasks = tasks.filter { task in
            guard let dueDate = task.due else {
                return false
            }
            return dueDate < now
        }
        
        todayTasks = tasks.filter { task in
            guard let dueDate = task.due else {
                return false
            }
            return dueDate >= now && Calendar.current.isDateInToday(dueDate)
        }
        
        weekTasks = tasks.filter { task in
            guard let dueDate = task.due,
                  let endOfWeek = now.endOfWeek else {
                return false
            }
            return dueDate >= now && dueDate < endOfWeek
        }
        
        laterTasks = tasks.filter { task in
            guard let dueDate = task.due,
                  let endOfWeek = now.endOfWeek else {
                return false
            }
            return dueDate > endOfWeek
        }
        
        unlimitedTasks = tasks.filter { task in
            return task.due == nil
        }
    }
    
    /// Filters all tasks by the given timetable
    /// - Parameter timetable: Timetable for the tasks
    /// - Returns: Returns a list of tasks attached to the given timetable.
    func tasks(for timetable: Timetable) -> [Task] {
        return tasks.filter { $0.timetable == timetable }
    }
    
    func completedTasks(for timetable: Timetable) -> [Task] {
        return tasks(for: timetable).filter { $0.completed }
    }
    
    func remainingTasks(for timetable: Timetable) -> [Task] {
        return tasks(for: timetable).filter { !$0.completed }
    }
    
}
