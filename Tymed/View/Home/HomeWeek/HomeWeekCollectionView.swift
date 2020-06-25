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
    
    
    var lessons: [Lesson] = []
    
    private var weekDays: [Day] = []
    private var week: [Day: [Lesson]] = [:]
    
    //MARK: setupUI()
    override internal func setupUserInterface() {
        super.setupUserInterface()
        
        register(HomeCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "homeHeader")
        register(HomeWeekLessonCollectionViewCell.self, forCellWithReuseIdentifier: homeLessonCell)
        
    }
    
    //MARK: fetchDate()
    /// Fetches the lesson data from core data
    override func fetchData() {
        
        // Fetch all lessons
        lessons = TimetableService.shared.fetchLessons() ?? []
        
        
        week = TimetableService.shared.sortLessonsByWeekDay(lessons)
        
        weekDays = Array(week.keys)
        
        // Sort the days from monday to sunday
        weekDays.sort(by: { (d1, d2) -> Bool in
            return d1 < d2
        })
    }
    
    //MARK: scrollTo(date: )
    /// Scrolls the collection view to the first lesson that fits the date.
    /// If there is no lesson that fits the date. The next lesson after that date will be chosen
    /// - Parameters:
    ///   - date: Date to search for the alogorithm
    ///   - animated: scroll animation yes/no
    func scrollTo(date: Date, _ animated: Bool = false) {
        guard let day = Day(rawValue: Calendar.current.component(.weekday, from: date)) else {
            print("scrollTo(date:) failed")
            return
        }
        let time = Time(from: date)
        
        scrollTo(day: day, time: time, animated)
    }
    
    //MARK: scrollTo(day: )
    func scrollTo(day: Day, _ animated: Bool = false) {
        if let section = weekDays.firstIndex(of: day) {
            scrollToItem(at: IndexPath(row: 0, section: section), at: .top, animated: animated)
        }else {
            if !week.isEmpty {
                scrollTo(day: day.rotatingNext(), animated)
            }
        }
    }
    
    //MARK: scrollTo(day:, time: )
    func scrollTo(day: Day, time: Time, _ animated: Bool = false) {
        if let section = weekDays.firstIndex(of: day) {
            let lessons = self.lessons(for: day) ?? []
            
            // In case the last lesson of today ends before the requested time
            // -> Go to next day
            if let l = lessons.last, l.endTime < time {
                if !week.isEmpty { // Avoid endless recursion for the case there are no lessons
                    scrollTo(day: day.rotatingNext(), time: Time.zero, animated)
                }
                return
            }
            // Search for the lesson that is closest to the req. time
            let closest = lessons.reduce(lessons.first) { (l1, l2) -> Lesson? in
                guard let s1 = l1?.startTime, let e1 = l1?.startTime else {
                    return nil
                }
                // In case the requested time is within a lesson -> return that lesson
                if Time.between(s1, time, t3: e1) {
                    return l1
                }
                
                // In case the requested time is before the first lesson -> return that lesson
                if let t1 = l1?.startTime, time <= t1 {
                    return l1
                }
                
                return l2
            }
            
            var row = 0
            
            if closest != nil {
                row = lessons.firstIndex(of: closest!) ?? 0
                print("scrolling to \(closest!.day) - \(closest!.startTime.string()!)")
            }
            
            // Scroll to the lesson
            scrollToItem(at: IndexPath(row: row, section: section), at: .top, animated: animated)
        }else {
            if !week.isEmpty {
                scrollTo(day: day.rotatingNext(), time: Time.zero, animated)
            }
        }
    }
    
    /// Returns the lesson for a given uuid
    /// - Parameter uuid: UUID of the lesson
    /// - Returns: Lesson with the given uuid. Nil if lesson does not exist in lessons list.
    private func lesson(for uuid: UUID) -> Lesson? {
        return lessons.filter { return $0.id == uuid }.first
    }
    
    //MARK: lesson(for: )
    private func lesson(for indexPath: IndexPath) -> Lesson? {
        return week[weekDays[indexPath.section]]?[indexPath.row]
    }
    
    private func lessons(for day: Day) -> [Lesson]? {
        return week[day]
    }
    
    private func lessons(for section: Int) -> [Lesson]? {
        return week[weekDays[section]]
    }
    
    //MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return week.keys.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return week[weekDays[section]]?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: homeLessonCell, for: indexPath) as! HomeWeekLessonCollectionViewCell
        
        cell.lesson = lesson(for: indexPath)
        
        return cell
    }
    
    //MARK: supplementaryView
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "homeHeader", for: indexPath) as! HomeCollectionViewHeader
            
            header.label.text = lesson(for: indexPath)?.day.date()?.dayToString()
            
            return header
        }
        
        return UICollectionReusableView()
    }
    
    //MARK: sizeForItemAt
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 2 * 16, height: 100)
    }
    
    //MARK: sizeForHeaderInSection
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    
    private func presentDetail(_ lessons: [Lesson]?, _ indexPath: IndexPath) {
        if let lesson = lessons?[indexPath.row] {
            homeDelegate?.lessonDetail(self, for: lesson)
        }
    }
    
    //MARK: didSelectItemAt
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        presentDetail(lessons(for: indexPath.section), indexPath)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let lesson = self.lesson(for: indexPath)
        
        guard let uuid = lesson?.id else {
            return nil
        }
        
        let config = UIContextMenuConfiguration(identifier: uuid as NSUUID, previewProvider: { () -> UIViewController? in
            
            let lessonDetail = LessonDetailTableViewController(style: .insetGrouped)
            
            lessonDetail.lesson = self.lesson(for: indexPath)
            
            return lessonDetail
        }) { (elements) -> UIMenu? in
            
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash")) { (action) in
                
                guard let lesson = self.lesson(for: indexPath) else {
                    return
                }
                
                TimetableService.shared.deleteLesson(lesson)
                
                self.homeDelegate?.lessonDidDelete(self, lesson: lesson)
                
            }
            
            return UIMenu(title: "", image: nil, children: [delete])
        }
        
        return config
    }
    
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        
        guard let id = (configuration.identifier as? NSUUID) as UUID? else {
            return
        }
        
        animator.addCompletion {
            guard let lesson = self.lesson(for: id) else {
                return
            }
            
            self.homeDelegate?.lessonDetail(self, for: lesson)
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        homeDelegate?.didScroll(scrollView)
    }
    
}
 
//MARK: HomeWeekLessonCollectionViewCell
class HomeWeekLessonCollectionViewCell: HomeLessonCollectionViewCell {
    
    override func reload() {
        
        if let lesson = lesson, Time.between(lesson.startTime, Time.now, t3: lesson.endTime), lesson.day.isToday() {
            
            name.text = lesson.subject?.name
            
            name.textColor = .white
            
            name.sizeToFit()
            
            time.text = "\(lesson.day.string()) - \(lesson.startTime.string() ?? "") - \(lesson.endTime.string() ?? "")"
            
            time.textColor = .white
            
            let color: UIColor? = UIColor(named: lesson.subject?.color ?? "dark") ?? UIColor(named: "dark")

            colorIndicator.backgroundColor = .white
            
            tasksLabel.textColor = .white
            tasksImage.tintColor = .white
            backgroundColor = color
            return
        }
        name.textColor = .label
        time.textColor = .label
        tasksLabel.textColor = .label
        tasksImage.tintColor = .label
        backgroundColor = .secondarySystemGroupedBackground
        super.reload()
    }
    
}
