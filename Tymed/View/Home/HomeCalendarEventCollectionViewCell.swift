//
//  HomeCalendarEventCollectionViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 12.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class HomeCalendarEventCollectionViewCell: HomeBaseCollectionViewCell {
    
    var calendarEvent: CalendarEvent? {
        didSet {
            reload()
        }
    }

}
