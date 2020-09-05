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
            CalendarWeekEntry(date: CalendarService.shared.nextWeek(after: Date()) ?? Date())
        ]
        
        collectionView.reloadData()
        
        if let cell = collectionView.visibleCells.first {
            updateCurrentDay(indexPath: collectionView.indexPath(for: cell)!)
        }
    }
    
    private func fetchPreviousWeek() {
        guard let firstWeek = entries.first?.date,
              let previousWeek = CalendarService.shared.previousWeek(before: firstWeek) else {
            return
        }
        
        entries.insert(CalendarWeekEntry(date: previousWeek), at: 0)
        collectionView.reloadData()
    }
    
    private func fetchNextWeek() {
        guard let lastWeek = entries.last?.date,
              let nextWeek = CalendarService.shared.nextWeek(after: lastWeek) else {
            return
        }
        
        entries.append(CalendarWeekEntry(date: nextWeek))
        collectionView.reloadData()
    }
    
    private func calendarDayEntry(for indexPath: IndexPath) -> CalendarDayEntry? {
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
        
        cell.homeDelegate = homeDelegate
        
        if let entry = calendarDayEntry(for: indexPath) {
            cell.entry = entry
        }
        
        cell.reload()
        
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
        if let cell = collectionView.visibleCells.first {
            updateCurrentDay(indexPath: collectionView.indexPath(for: cell)!)
        }
        
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        collectionView.layoutIfNeeded()
        if let cell = collectionView.visibleCells.first {
            let indexPath = collectionView.indexPath(for: cell)!
            
            updateCurrentDay(indexPath: indexPath)
            
            if indexPath.section == 0 && indexPath.row == 0 {
                fetchPreviousWeek()
                collectionView.scrollToItem(at: IndexPath(row: indexPath.row, section: indexPath.section + 1), at: .top, animated: false)
            } else if indexPath.section == entries.count - 1 && indexPath.row == (entries.last?.entryCount ?? 0) - 1 {
                fetchNextWeek()
            }
            
        }
    }
    
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        collectionView.layoutIfNeeded()
        if let cell = collectionView.visibleCells.first {
            updateCurrentDay(indexPath: collectionView.indexPath(for: cell)!)
        }
    }
    
}


