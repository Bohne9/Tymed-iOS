//
//  HomeDashTaskSelectorCellType.swift
//  Tymed
//
//  Created by Jonah Schueller on 19.07.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

enum HomeDashTaskSelectorCellType : Int {
    
    case today = 0
    case done = 1
    case all = 2
    case expired = 3
    case archived = 4
    case open = 5
    case planned = 6
    
    var title: String {
        switch self {
        case .today:    return "Today"
        case .done:     return "Done"
        case .all:      return "All"
        case .expired:  return "Expired"
        case .open:     return "Open"
        case .archived: return "Archived"
        case .planned:  return "Planned"
        }
    }
    
    var systemIcon: String {
        switch self {
        case .today:    return "calendar"
        case .done:     return "checkmark.circle.fill"
        case .all:      return "tray.fill"
        case .expired:  return "exclamationmark.circle.fill"
        case .open:     return "circle"
        case .archived: return "tray.full.fill"
        case .planned:  return "calendar.badge.clock"
        }
    }
    
    var color: UIColor {
        switch self {
        case .today:    return .systemBlue
        case .done:     return .systemGreen
        case .all:      return .systemGray
        case .expired:  return .systemRed
        case .open:     return .systemBlue
        case .archived: return .systemGray
        case .planned:  return .systemOrange
        }
    }
    
    func tasks() -> [Task] {
        let service = TimetableService.shared
        
        switch self {
        case .today:
            return service.getTasksOfToday()
        case .all:
            return service.getAllTasks()
        case .done:
            return service.getCompletedTasks()
        case .expired:
            return service.getExpiredTasks()
        case .archived:
            return service.getArchivedTasks()
        case .open:
            return service.getOpenTasks()
        case .planned:
            return service.getPlannedTasks()
        }
    }
}
