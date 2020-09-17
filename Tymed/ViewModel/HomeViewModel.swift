//
//  HomeViewModel.swift
//  Tymed
//
//  Created by Jonah Schueller on 17.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    
    @Published
    var tasks: [Task] = []
    
    @Published
    var events: [CalendarEvent] = []
    
    private var anchorDate: Date
    
    init(anchor: Date = Date()) {
        anchorDate = anchor
        
        tasks = TimetableService.shared.getTasks(after: anchorDate).sorted()
        
        events = TimetableService.shared.getNextCalendarEvents(startingFrom: anchorDate)
    }
    
    func reload() {
        tasks = TimetableService.shared.getTasks(after: anchorDate).sorted()
        
        events = TimetableService.shared.getNextCalendarEvents(startingFrom: anchorDate)
    }
    
}
