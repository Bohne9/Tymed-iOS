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
//            scrollTo(day: .current)
            firstAppear = false
        }
    }
    
    //MARK: fetchDate()
    /// Fetches the lesson data from core data
    override func fetchData() {
        
        // Fetch all lessons
//        lessons = TimetableService.shared.fetchLessons() ?? []
//
//        // Get the lesson grouped by their day
//        week = TimetableService.shared.sortLessonsByWeekDay(lessons)
//
//        weekDays = Array(week.keys)
//
//        // Sort the days from monday to sunday
//        weekDays.sort(by: { (d1, d2) -> Bool in
//            return d1 < d2
//        })
        
        
        entries = [CalendarWeekEntry.entryForCurrentWeek()]
    }
    
    private func calendarDayEntry(for indexPath: IndexPath) -> CalendarDayEntry? {
        return entries[indexPath.section].calendarDayEntry(for: indexPath.row)
    }
    
    /*
    
    //MARK: scrollTo(date: )
    /// Scrolls the collection view to the first lesson that fits the date.
    /// If there is no lesson that fits the date. The next lesson after that date will be chosen
    /// - Parameters:
    ///   - date: Date to search for the alogorithm
    ///   - animated: scroll animation yes/no
    func scrollTo(date: Date, _ animated: Bool = false) {
        // Get the day of the date
        guard let day = Day(rawValue: Calendar.current.component(.weekday, from: date)) else {
            print("scrollTo(date:) failed")
            return
        }
        
        scrollTo(day: day, animated)
    }
    
    //MARK: scrollTo(day: )
    func scrollTo(day: Date, _ animated: Bool = false) {
        // If the day is in the list of days
        if let day = weekDays.firstIndex(of: day) {
            collectionView.scrollToItem(at: IndexPath(row: day, section: 0), at: .top, animated: animated)
            updateCurrentDay(index: day)
        }else { // Otherwise scroll recursivly to the next day
            if !week.isEmpty {
                scrollTo(day: day.rotatingNext(), animated)
            }
        }
    } */
    
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
        
        let week = currentPage / 7
        let day = currentPage % 7
        
        updateCurrentDay(indexPath: IndexPath(row: day, section: week))
        
        homeDelegate?.didScroll(scrollView)
    }
    
}
