//
//  BackgroundService.swift
//  Tymed
//
//  Created by Jonah Schueller on 28.07.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit
import BackgroundTasks

class BackgroundRoutineService {
    
    static let standard = BackgroundRoutineService()
    
    /// A list of tasks that have been archived at the start of the session
    var archivedTasksOfSession: [Task]?
    
    internal init () { }
    
    func appLaunchRoutine() {
        
        archiveExpiredTasks()
        
    }
    
    /// A routine that will archive all tasks where the dueDate + taskArchivingDelay is in the past.
    func archiveExpiredTasks() {
        // Make sure the user has specified a taskAutoArchvingDelay
        guard let taskArchivingDelay = SettingsService.shared.taskAutoArchivingDelay else {
            return
        }
        
        archivedTasksOfSession = []
        
        let tasks = TimetableService.shared.getAllTasks()
        
        for task in tasks {
            guard let due = task.due else {
                continue
            }
            
            let now = Date()
            
            if (due.addingTimeInterval(taskArchivingDelay.timeinterval) < now) {
                archivedTasksOfSession?.append(task)
                NotificationService.current.removeDeliveredNotifications(of: task)
                task.archived = true
            }
        }
        TimetableService.shared.save()
    }
    
    
    
    func appStartSetupRoutine() {
        
//        let calendars = []
        
        
    }
    
    //MARK: Background Tasks
    

}

