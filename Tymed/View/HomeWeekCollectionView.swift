//
//  HomeWeekCollectionView.swift
//  Tymed
//
//  Created by Jonah Schueller on 12.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit
//MARK: HomeWeekCollectionView
class HomeWeekCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: self.frame, collectionViewLayout: UICollectionViewFlowLayout())
        
        view.delegate = self
        view.dataSource = self
        
        return view
    }()
    
    var delegate: HomeCollectionViewDelegate?
    
    var lessons: [Lesson] = []
    
    private var weekDays: [Day] = []
    private var week: [Day: [Lesson]] = [:]
    
    //MARK: init(frame: )
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: setup()
    private func setup() {
        
        setupUI()
        
        reload()
    }
    
    //MARK: setupUI()
    private func setupUI() {
        
        addSubview(collectionView)
        
        collectionView.backgroundColor = .systemGroupedBackground
        
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        collectionView.register(HomeDashCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "homeHeader")
        collectionView.register(HomeWeekLessonCollectionViewCell.self, forCellWithReuseIdentifier: homeLessonCell)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
    }
    
    //MARK: reload()
    /// Fetches the data from core data and reloads the collection view.
    /// After that it scrolls to the first lesson that is right now (in case the is one).
    /// If not it scrolls to the next lesson
    func reload() {
        fetchData()
        
        collectionView.reloadData()
        scrollTo(date: Date())
        
    }
    
    //MARK: fetchDate()
    /// Fetches the lesson data from core data
    func fetchData() {
        
        // Fetch all lessons
        lessons = TimetableService.shared.fetchLessons() ?? []
        
        
        week = TimetableService.shared.sortLessonsByWeekDay(lessons)
        
        /*
        // Sort the lessons into the day slots
        lessons.forEach({ (lesson) in
            if ((week[lesson.day]) != nil) {
                week[lesson.day]?.append(lesson)
            }else {
                week[lesson.day] = [lesson]
            }
        })
        
        // Sort each day slot by time
        week.forEach { (arg0) in
            let (key, value) = arg0
            week[key] = value.sorted(by: { (l1, l2) -> Bool in
                if l1.startTime != l2.startTime {
                    return l1.startTime < l2.startTime
                }
                return l1.endTime < l2.endTime
            })
        }*/
        
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
            collectionView.scrollToItem(at: IndexPath(row: 0, section: section), at: .top, animated: animated)
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
            collectionView.scrollToItem(at: IndexPath(row: row, section: section), at: .top, animated: animated)
        }else {
            if !week.isEmpty {
                scrollTo(day: day.rotatingNext(), time: Time.zero, animated)
            }
        }
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
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return week.keys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return week[weekDays[section]]?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeLessonCell, for: indexPath) as! HomeWeekLessonCollectionViewCell
        
        cell.lesson = lesson(for: indexPath)
        
        return cell
    }
    
    //MARK: supplementaryView
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "homeHeader", for: indexPath) as! HomeDashCollectionViewHeader
            
            header.label.text = lesson(for: indexPath)?.day.date()?.dayToString()
            
            return header
        }
        
        return UICollectionReusableView()
    }
    
    //MARK: sizeForItemAt
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 2 * 16, height: 100)
    }
    
    //MARK: sizeForHeaderInSection
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    
    private func presentDetail(_ lessons: [Lesson]?, _ indexPath: IndexPath) {
        if let lesson = lessons?[indexPath.row] {
            delegate?.lessonDetail(self, for: lesson)
        }
    }
    
    //MARK: didSelectItemAt
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        presentDetail(lessons(for: indexPath.section), indexPath)
        
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
