//
//  HomeWeekDayCollectionViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 17.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit
import SwiftUI

private let lessonCell = "lessonCell"

//MARK: CalendarDayCollectionView
class CalendarDayCollectionView: UICollectionViewCell  {
    
    static let identifier = "CalendarDayCollectionView"
    
    /// Delegate for displaying LessonEditView etc.
    var homeDelegate: HomeViewSceneDelegate?
    
    var viewController: UIViewController?
    
    /// CalendarDayEntry for the cell
    var entry: CalendarDayEntry? {
        didSet {
            calendarDayEntry.date = entry?.date ?? Date()
            calendarDayEntry.expandToEntireDay()
            if let entry = self.entry {
                calendarDayEntry.setEntries(entry.entries + entry.allDayEntries)
            }
        }
    }
    
    
    private var calendarDayEntry = CalendarDayEntry(for: Date(), entries: [])
    var homeCalendarView = HomeDayCalendarViewWrapper()
    
    var homeViewModel: HomeViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reload() {
        
    }
    
    //MARK: setupView
    func setupView() {
        homeCalendarView.homeViewModel = homeViewModel
        homeCalendarView.calendarEntry = calendarDayEntry
        
        
        contentView.addSubview(homeCalendarView.view)
        homeCalendarView.view.translatesAutoresizingMaskIntoConstraints = false
        homeCalendarView.view.constraintToSuperview()
        
        print("Entry \(entry?.date) - \(entry?.entries.count)")
        print(homeCalendarView.view.frame)
        
        viewController?.addChild(homeCalendarView)

        backgroundColor = .systemGroupedBackground
        
    }
   

    
}
