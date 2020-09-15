//
//  HomeCalendarCellSupplier.swift
//  Tymed
//
//  Created by Jonah Schueller on 15.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import Foundation
import UIKit

class HomeCalendarCollectionViewCellSupplier: Supplier {
    
    typealias T = HomeCalendarEventCollectionViewCell
    
    typealias V = CalendarEvent
    
    var collectionView: UICollectionView?
    private var indexPath: IndexPath?
    
    private func dequeueCell(for identifier: String) -> HomeCalendarEventCollectionViewCell? {
        guard let index = indexPath else {
            return nil
        }
        
        return collectionView?.dequeueReusableCell(withReuseIdentifier: identifier, for: index) as? HomeCalendarEventCollectionViewCell
    }
    
    func get(_ value: CalendarEvent?) -> HomeCalendarEventCollectionViewCell? {
        guard let event = value else {
            return nil
        }
        
        var identifier = homeLessonCell
        
        if event.isEvent {
            identifier = homeEventCell
        }
        
        let cell = dequeueCell(for: identifier)
        cell?.calendarEvent = value
        
        return cell
    }
    
    func get(for indexPath: IndexPath, event: CalendarEvent?) -> HomeCalendarEventCollectionViewCell? {
        self.indexPath = indexPath
        
        return get(event)
    }
    
}
