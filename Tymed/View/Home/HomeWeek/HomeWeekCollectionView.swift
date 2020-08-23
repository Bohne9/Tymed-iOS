//
//  HomeWeekCollectionView.swift
//  Tymed
//
//  Created by Jonah Schueller on 12.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit
//MARK: HomeWeekCollectionView
class HomeWeekCollectionView: HomeBaseCollectionView {
    
    /// Indicates that the scene will be showed for the first time
    private var firstAppear = true
    
    /// All lessons
//    var lessons: [Lesson] = []
    
    /// List of days which have lessons.
//    var weekDays: [Day] = []
    
    /// Dictionary of a list of lessons with their day as the key.
//    var week: [Day: [Lesson]] = [:]
    
    var weeks: [Date] = []
    var entries: [CalendarWeekEntry] = []
    
    
    //MARK: setupUI()
    override internal func setupUserInterface() {
        
        // Register the Day Cell
        collectionView.register(HomeWeekDayCollectionViewCell.self,
                                forCellWithReuseIdentifier: HomeWeekDayCollectionViewCell.identifier)
        
        // Remove scroll indicator
        collectionView.showsVerticalScrollIndicator = false
        
        // Enable paging
        collectionView.isPagingEnabled = true
        
        // Remove any content offset
        collectionView.contentInset = .zero
        
        collectionView.backgroundColor = .systemGroupedBackground
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Scroll to the current day (only for the first time)
        if firstAppear {
            scrollTo(date: Date())
            firstAppear = false
        }
    }
    
    //MARK: fetchDate()
    /// Fetches the lesson data from core data
    override func fetchData() {
        
        entries = [
            CalendarWeekEntry(date: CalendarService.shared.previousWeek(before: Date()) ?? Date()),
            CalendarWeekEntry.entryForCurrentWeek(),
            CalendarWeekEntry(date: CalendarService.shared.nextWeek(after: Date()) ?? Date())]
        
        collectionView.reloadData()
        
        if let cell = collectionView.visibleCells.first {
            updateCurrentDay(indexPath: collectionView.indexPath(for: cell)!)
        }
    }
    
    private func calendarDayEntry(for indexPath: IndexPath) -> CalendarDayEntry? {
        print(indexPath)
        return entries[indexPath.section].calendarDayEntry(for: indexPath.row)
    }
 
    //MARK: scrollTo(day: )
    func scrollTo(date: Date, _ animated: Bool = false) {
    
        outer : for (section, week) in entries.enumerated() {
            
            print("Week: \(String(describing: section)), Start: \(week.date.stringify(with: .medium)), End: \(week.date.endOfWeek!.stringify(with: .medium))")
            if date < week.endOfWeek ?? date {
                for (index, day) in week.entries.enumerated() {
                    print("\tDay: \(String(describing: index)), Start: \(day.startOfDay!.stringify(dateStyle: .medium, timeStyle: .medium)), End: \(day.endOfDay!.stringify(dateStyle: .medium, timeStyle: .medium))")
                    if date < day.endOfDay ?? date {
                        print("---Hit----")
                        let indexPath = IndexPath(item: index, section: section)
                        collectionView.scrollToItem(at: indexPath, at: .top
                                                    , animated: animated)
                        updateCurrentDay(indexPath: indexPath)
                        break outer
                    }
                }
            }
        }
        
    }
    
    //MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return entries.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return entries[section].entryCount
    }
    
    private func dequeueHomeDayCell(for indexPath: IndexPath) -> HomeWeekDayCollectionViewCell? {
        return collectionView.dequeueReusableCell(
            withReuseIdentifier: HomeWeekDayCollectionViewCell.identifier,
            for: indexPath) as? HomeWeekDayCollectionViewCell
    }
    
    //MARK: cellForItem
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = dequeueHomeDayCell(for: indexPath) else {
            return UICollectionViewCell()
        }
        
        cell.lessonDelegate = homeDelegate
        
        if let entry = calendarDayEntry(for: indexPath) {
            cell.entry = entry
        }
        
        return cell
    }
    
    //MARK: sizeForItemAt
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    //MARK: updateCurrentDay
    private func updateCurrentDay(indexPath: IndexPath) {
        guard let navBar = navigationController?.navigationBar as? NavigationBar else {
            return
        }
        
        if let entry = calendarDayEntry(for: indexPath) {
            navBar.setWeekTitle(entry.date)
        }
        
    }
    
    //MARK: scrollViewDidScroll
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.y / scrollView.frame.height)
        
//        let week = currentPage / 7
//        let day = currentPage % 7
//
//        updateCurrentDay(indexPath: IndexPath(row: day, section: week))
        
//        if let cell = collectionView.visibleCells.first {
//            updateCurrentDay(indexPath: collectionView.indexPath(for: cell)!)
//        }
        
        homeDelegate?.didScroll(scrollView)
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        collectionView.layoutIfNeeded()
        if let cell = collectionView.visibleCells.first {
            updateCurrentDay(indexPath: collectionView.indexPath(for: cell)!)
        }
    }
    
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        collectionView.layoutIfNeeded()
        if let cell = collectionView.visibleCells.first {
            updateCurrentDay(indexPath: collectionView.indexPath(for: cell)!)
        }
    }
    
}


