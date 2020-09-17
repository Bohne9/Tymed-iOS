//
//  EventModel.swift
//  Tymed
//
//  Created by Jonah Schueller on 15.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

//MARK: EventModel
public class EventModel: ObservableObject {
    
    @Published
    public var title: String = ""
    
    @Published
    public var body: String = ""
    
    @Published
    public var start: Date = Date()
    
    @Published
    public var end: Date = Date() + 3600
    
    @Published
    public var notes: String = ""
    
    @Published
    public var notification: Date? = Date()
    
    @Published
    public var task: Task?
    
    @Published
    public var subject: Subject?
    
    @Published
    public var lesson: Lesson?
    
    @Published
    public var timetable: Timetable? = TimetableService.shared.defaultTimetable()
    
    internal var event: Event?
    
    func isValid() -> Bool {
        return !title.isEmpty
    }
    
    func create() -> Event? {
        
        if !isValid() {
            return nil
        }
        
        let event = TimetableService.shared.event()
        
        event.title = title
        event.body = body
            
        event.start = start
        event.end = end
        
        event.notes = notes
        
        event.timetable = timetable
        
        TimetableService.shared.save()
        
        self.event = event
        
        return event
    }
    
}
