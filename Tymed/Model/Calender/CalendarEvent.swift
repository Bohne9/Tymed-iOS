//
//  CalendarEvent.swift
//  Tymed
//
//  Created by Jonah Schueller on 11.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

/// A protocol that defines an general event in a calendar
/// See also: Lesson, Task, Event
protocol CalendarEvent {
    
    var title: String {
        get set
    }
    
    var startDate: Date? {
        get set
    }
    
    var endDate: Date? {
        get set
    }
    
    var color: UIColor? {
        get set
    }
}
