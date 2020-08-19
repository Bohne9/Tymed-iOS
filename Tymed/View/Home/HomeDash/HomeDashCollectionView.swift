//
//  HomeDashCollectionViewController.swift
//  Tymed
//
//  Created by Jonah Schueller on 28.04.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

private let nowReuseIdentifier = "homeNowCell"
private let taskSelectionCell = "taskSelection"

private let tasksSection = "tasksSection"
private let nowSection = "nowSection"
private let nextSection = "nextSection"
private let daySection = "daySection"
private let nextDaySection = "nextDaySection"
private let weekSection = "weekSection"

class HomeDashCollectionView: HomeBaseCollectionView {
    
    var cellColor: UIColor = .red
    
    var subjects: [Subject]?
    var lessons: [Lesson]?
    
    private var taskSelection: HomeDashTaskSelectorCellType = .today
    
    //MARK: Section lesson arrays
    var nowLessons: [Lesson]?
    
    var nextLessons: [Lesson]?
    
    var dayLessons: [Lesson]?
    
    var nextDay: Day?
    var nextDayLessons: [Lesson]?
    
    var tasks: [Task]?
    
    //MARK: UI setup
    override internal func setupUserInterface() {
        super.setupUserInterface()
        
        collectionView.register(HomeCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "homeHeader")
        collectionView.register(HomeLessonCollectionViewCell.self, forCellWithReuseIdentifier: homeLessonCell)
        collectionView.register(UINib(nibName: "HomeDashTaskOverviewCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: homeDashTaskOverviewCollectionViewCell)
        collectionView.register(HomeDashTaskSelectorCollectionViewCell.self, forCellWithReuseIdentifier: taskSelectionCell)
        collectionView.register(HomeDashTaskOverviewNoTasksCollectionViewCell.self, forCellWithReuseIdentifier: "noTaskCell")
        
        
    }
    
    /// Returns the lesson for a given uuid
    /// - Parameter uuid: UUID of the lesson
    /// - Returns: Lesson with the given uuid. Nil if lesson does not exist in lessons list.
    private func lesson(for uuid: UUID) -> Lesson? {
        return lessons?.filter { return $0.id == uuid }.first
    }
    
    private func lesson(for indexPath: IndexPath) -> Lesson? {
        let identifier = section(for: indexPath)
        
        switch identifier {
        case nowSection:
            return nowLessons?[indexPath.row]
        case nextSection:
            return nextLessons?[indexPath.row]
        case daySection:
            return dayLessons?[indexPath.row]
        case weekSection:
            return lessons?[indexPath.row]
        case nextDaySection:
            return nextDayLessons?[indexPath.row]
        default:
            return nil
        }
    }
    
    private func appendSection(_ lessons: [Lesson]?, with identifier: String) {
        if (lessons?.count ?? 0) > 0 {
            addSection(id: identifier)
        }
    }
    
    //MARK: fetchData()
    override internal func fetchData() {
        
        lessons = TimetableService.shared.fetchLessons()
        
        nowLessons = TimetableService.shared.getLessons(within: Date()).sorted(by: { (l1, l2) in
            return l1.startTime < l2.startTime
        })
        
        dayLessons = TimetableService.shared.getLessons(within: .current).sorted(by: { (l1, l2) in
            return l1.startTime < l2.startTime
        }).filter({ (lesson) -> Bool in
            Time(from: Date()) < lesson.endTime // Only include the lessons with are in the future
        })
        
        
        var day = Day.current
        
        for _ in 0..<6 {
            day = day.rotatingNext()
            nextDayLessons = TimetableService.shared.getLessons(within: day).sorted(by: { (l1, l2) in
                return l1.startTime < l2.startTime
            })
            nextDay = day
            if nextDayLessons?.count ?? 0 > 0 {
                break
            }
        }
        
        nextLessons = TimetableService.shared.getNextLessons()
        
        sectionIdentifiers = []
        
        loadTask(for: taskSelection)
        
        addSection(id: tasksSection)
        
        appendSection(nowLessons, with: nowSection)
        appendSection(nextLessons, with: nextSection)
        appendSection(dayLessons, with: daySection)
        appendSection(nextDayLessons, with: nextDaySection)
//        appendSection(lessons, with: weekSection)
        
    }

    private func loadTask(for selection: HomeDashTaskSelectorCellType) {
        
        tasks = taskSelection.tasks()
        tasks?.reverse()
    }
    
    // MARK: - UICollectionViewDataSource

    //MARK: numberOfItemsInSection
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection identifier: String) -> Int {
        
        switch identifier {
        case tasksSection:
            return 5
        case nowSection:
            return nowLessons?.count ?? 0
        case nextSection:
            return nextLessons?.count ?? 0
        case daySection:
            return dayLessons?.count ?? 0
        case weekSection:
            return lessons?.count ?? 0
        case nextDaySection:
            let count = nextDayLessons?.count ?? 0
            return count
        default:
            return 0
            
        }
    }
    
    //MARK: cellForItemAt
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let sectionId = self.section(for: indexPath)
        
        switch sectionId {
        case tasksSection:
            if indexPath.row < 4 {
                let cell = dequeueCell(taskSelectionCell, indexPath) as! HomeDashTaskSelectorCollectionViewCell
                
                let type = selectorType(for: indexPath.row)
                
                cell.isSelected = type == taskSelection
                cell.type = type
                
                
                return cell
            }else if tasks?.count ?? 0 > 0 {
                let cell = dequeueCell(homeDashTaskOverviewCollectionViewCell, indexPath) as! HomeDashTaskOverviewCollectionViewCell
                
                cell.size = .large
                cell.tasks = tasks
                cell.taskDelegate = taskDelegate
                cell.reload()
                
                return cell
            }else {
                let cell = dequeueCell("noTaskCell", indexPath) as! HomeDashTaskOverviewNoTasksCollectionViewCell
                
                cell.taskDelegate = taskDelegate
                cell.type = taskSelection
                
                return cell
            }
            
        case nowSection, nextSection, daySection, weekSection, nextDaySection:
            let cell = dequeueCell(homeLessonCell, indexPath) as! HomeLessonCollectionViewCell
            
            cell.lesson = lesson(for: indexPath)
            
            return cell
        default:
            return UICollectionViewCell()
        }
        
    }
    
    private func presentLessonDetail(_ indexPath: IndexPath) {
        guard let lesson = self.lesson(for: indexPath) else {
            return
        }
        homeDelegate?.lessonDetail(self.collectionView, for: lesson)
    }
    
    private func selectorType(for index: Int) -> HomeDashTaskSelectorCellType {
        switch index {
        case 0:     return .today
        case 1:     return .done
        case 2:     return .planned
        case 3:     return .open
        default:    return .all
        }
    }
    
    //MARK: didSelectItemAt
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let sectionId = self.section(for: indexPath)
        
        switch sectionId {
        case tasksSection:
            if indexPath.row < 4 {
                taskSelection = selectorType(for: indexPath.row)
                
                loadTask(for: taskSelection)
                
                collectionView.reloadSections(IndexSet(arrayLiteral: 0))
            }
            
            break
        case nowSection, nextSection, daySection, weekSection, nextDaySection:
            presentLessonDetail(indexPath)
            break
        default:
            break
        }
        
    }

    private func headerTitle(for section: String) -> String {
        switch section {
        case tasksSection:      return "Tasks"
        case nowSection:        return "Now"
        case nextSection:       return "Next"
        case daySection:        return "Today"
        case nextDaySection:    return "\(nextDay?.string() ?? "")"
        case weekSection:       return "All"
        default:                return "-"
        }
    }
    
    //MARK: supplementaryView
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "homeHeader", for: indexPath) as! HomeCollectionViewHeader
            
            // Set the title of the section header according to the section type
            header.label.text = headerTitle(for: section(for: indexPath))
            
            return header
        }
        
        return UICollectionReusableView()
    }
    
    //MARK: sizeForHeaderInSection
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
    }
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard let lesson = self.lesson(for: indexPath) else {
            return nil
        }
        
        guard let uuid = lesson.id else {
            return nil
        }
        
        let config = UIContextMenuConfiguration(identifier: uuid as NSUUID, previewProvider: { () -> UIViewController? in
            
            // ViewController to give the user a preview of the lessonEditView
            let lessonEdit = UIHostingController(
                rootView: LessonEditContentView(lesson: lesson, dismiss: { }))
            
            return lessonEdit
        }) { (elements) -> UIMenu? in
            
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash")) { (action) in
                
                guard let lesson = self.lesson(for: indexPath) else {
                    return
                }
                
                TimetableService.shared.deleteLesson(lesson)
                
                self.homeDelegate?.lessonDidDelete(self.collectionView, lesson: lesson)
                
            }
            
            return UIMenu(title: "", image: nil, children: [delete])
        }
        
        return config
    }
    
    override func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        
        guard let id = (configuration.identifier as? NSUUID) as UUID? else {
            return
        }
        
        animator.addCompletion {
            guard let lesson = self.lesson(for: id) else {
                return
            }
            
            self.homeDelegate?.lessonDetail(self.collectionView, for: lesson)
        }
        
    }
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        homeDelegate?.didScroll(scrollView)
    }
    
    
}


extension HomeDashCollectionView {
    
    //MARK: sizeForItemAt
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionId = section(for: indexPath)
        
        switch sectionId {
        case tasksSection:
            // If the task is a selector task
            if indexPath.row < 4 {
                return CGSize(width: (collectionView.contentSize.width -  20) / 2, height: 45)
            } else if tasks?.count ?? 0 == 0 { // Task add cell
                return CGSize(width: collectionView.contentSize.width, height: 45)
            }
            // Task Overview cell
            return CGSize(width: collectionView.contentSize.width, height: 20 + CGFloat((tasks?.count ?? 0) * 60))
        case nowSection, nextSection, daySection, weekSection, nextDaySection:
            // Lesson cell
            let height = HomeLessonCellConfigurator.height(for: lesson(for: indexPath))
                
            return CGSize(width: collectionView.contentSize.width, height: height)
        default:
            return CGSize.zero
        }
        
    }

}



