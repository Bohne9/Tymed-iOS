//
//  AppStartupPreset.swift
//  Tymed
//
//  Created by Jonah Schueller on 26.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import Foundation

class AppStartupPreset {
    
    // Type alias to make the code cleaner
    private typealias TimetableModel = (name: String, color: String, default: Bool)
    private typealias TaskModel = (title: String, body: String, due: Date, calendar: String)
    private typealias LessonModel = (title: String, body: String, start: Date, end: Date, calendar: String)
    private typealias EventModel = (title: String, body: String, start: Date, end: Date, calendar: String)
    
    
    //MARK: Presets
    static func preset(for preset: String) -> AppStartupPreset? {
        
        switch preset {
        case "School":
            return school
        case "University":
            return university
        case "Productivity":
            return productivity
        case "Other":
            return other
        default:
            return nil
        }
    }
    
    static let school: AppStartupPreset = {
        let calendars: [TimetableModel] = [
            (name: "School", color: "blue", default: true),
            (name: "Private", color: "red", default: false),
        ]
        
        let tasks: [TaskModel] = [
            (title: "This is a task!", body: "You can add tasks to remind you to do your homework", due: Date() + 24 * 3600, calendar: "School")
        ]
        
        let events: [LessonModel] = [
            (title: "Tap me!", body: "Here you can see details of an event.", start: Date() + 300, end: Date() + 2100, calendar: "Private"),
            (title: "This is an event.", body: "Events mark single events in your calendar.", start: Date() + 3600, end: Date() + 7200, calendar: "School")
        ]
        
        return AppStartupPreset(calendars: calendars, tasks: tasks, events: events, schoolMode: true)
    }()
    
    static let university: AppStartupPreset = {
        let calendars: [TimetableModel] = [
            (name: "University", color: "blue", default: true),
            (name: "Work", color: "orange", default: false),
            (name: "Private", color: "red", default: false),
        ]
        
        let tasks: [TaskModel] = [
            (title: "This is a task!", body: "You can add tasks to remind you to do your excercises", due: Date() + 24 * 3600, calendar: "University")
        ]
        
        let events: [LessonModel] = [
            (title: "Tap me!", body: "Here you can see details of an event.", start: Date() + 300, end: Date() + 2100, calendar: "Private"),
            (title: "This is an event.", body: "Events mark single events in your calendar.", start: Date() + 3600, end: Date() + 7200, calendar: "University")
        ]
        
        return AppStartupPreset(calendars: calendars, tasks: tasks, events: events, schoolMode: true)
    }()
    
    static let productivity: AppStartupPreset = {
        let calendars: [TimetableModel] = [
            (name: "Work", color: "blue", default: true),
            (name: "Private", color: "red", default: false),
        ]
        
        let tasks: [TaskModel] = [
            (title: "This is a task!", body: "You can add tasks to remind you to do your work", due: Date() + 24 * 3600, calendar: "Work")
        ]
        
        let events: [LessonModel] = [
            (title: "Tap me!", body: "Here you can see details of an event.", start: Date() + 300, end: Date() + 2100, calendar: "Private"),
            (title: "This is an event.", body: "Events mark single events in your calendar.", start: Date() + 3600, end: Date() + 7200, calendar: "Work")
        ]
        
        return AppStartupPreset(calendars: calendars, tasks: tasks, events: events, schoolMode: false)
    }()
    
    static let other: AppStartupPreset = {
        let calendars: [TimetableModel] = [
            (name: "Work", color: "blue", default: true),
            (name: "Private", color: "red", default: false),
            (name: "Other", color: "yellow", default: true),
        ]
        
        let tasks: [TaskModel] = [
            (title: "This is a task!", body: "You can add tasks to remind you to do your work", due: Date() + 24 * 3600, calendar: "Work")
        ]
        
        let events: [LessonModel] = [
            (title: "Tap me!", body: "Here you can see details of an event.", start: Date() + 300, end: Date() + 2100, calendar: "Private"),
            (title: "This is an event.", body: "Events mark single events in your calendar.", start: Date() + 3600, end: Date() + 7200, calendar: "Work")
        ]
        
        return AppStartupPreset(calendars: calendars, tasks: tasks, events: events, schoolMode: false)
    }()
    
    
    //MARK: Fields
    
    /// The Calendars in a preset
    private var calendars: [TimetableModel]
    
    /// The Tasks in a preset
    private var tasks: [TaskModel]
    
    /// The Events in a preset
    private var events: [EventModel]
    
    private var schoolMode: Bool
 
    private init(calendars: [TimetableModel], tasks: [TaskModel], events: [EventModel], schoolMode: Bool) {
        self.calendars = calendars
        self.tasks = tasks
        self.events = events
        self.schoolMode = schoolMode
    }
    
    //MARK: storePreset
    /// Generates the Core Data objects from the preset models
    func storePreset() {
        
        let calendars = createCalendars()
        
        createTasks(calendars)
        
        createEvents(calendars)
        
//        TimetableService.shared.save()
    }
    
    private func createCalendars() -> [Timetable] {
        return calendars.map { (calendar) in
            let timetable = TimetableService.shared.timetable()
            
            timetable.name = calendar.name
            timetable.color = calendar.color
            timetable.isDefault = calendar.default
            
            return timetable
        }
    }
    
    private func createTasks(_ timetables: [Timetable]) {
        tasks.forEach { (taskModel) in
            let task = TimetableService.shared.task()
            
            task.title = taskModel.title
            task.text = taskModel.body
            task.due = taskModel.due
            task.timetable = timetables.first(where: { $0.name == taskModel.calendar }) ?? timetables.first!
            
        }
    }
    
    private func createEvents(_ timetables: [Timetable]) {
        events.forEach { (eventModel) in
            let event = TimetableService.shared.event()
            
            event.title = eventModel.title
            event.body = eventModel.body
            event.start = eventModel.start
            event.end = eventModel.end
            event.timetable = timetables.first(where: { $0.name == eventModel.calendar }) ?? timetables.first!
            
        }
    }
    
}
