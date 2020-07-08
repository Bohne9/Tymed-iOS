//
//  HomeDashCollectionViewController.swift
//  Tymed
//
//  Created by Jonah Schueller on 28.04.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import Foundation
import UIKit

private let nowReuseIdentifier = "homeNowCell"
private let taskSelectionCell = "taskSelection"

private let tasksSection = "tasksSection"
private let nowSection = "nowSection"
private let nextSection = "nextSection"
private let weekSection = "weekSection"

class HomeDashCollectionView: HomeBaseCollectionView {
    
    var cellColor: UIColor = .red
    
    var subjects: [Subject]?
    var lessons: [Lesson]?
    
    private var taskSelection: HomeDashTaskSelectorCellType = .today
    
    //MARK: Section lesson arrays
    var nowLessons: [Lesson]?
    
    var nextLessons: [Lesson]?
    
    var tasks: [Task]?
    
    //MARK: UI setup
    override internal func setupUserInterface() {
        super.setupUserInterface()
        
        register(HomeCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "homeHeader")
        register(HomeLessonCollectionViewCell.self, forCellWithReuseIdentifier: homeLessonCell)
        register(UINib(nibName: "HomeDashTaskOverviewCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: homeDashTaskOverviewCollectionViewCell)
        register(HomeDashTaskSelectorCollectionViewCell.self, forCellWithReuseIdentifier: taskSelectionCell)
        
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
        case weekSection:
            return lessons?[indexPath.row]
        default:
            return nil
        }
    }
    
    //MARK: fetchData()
    override internal func fetchData() {
        
        lessons = TimetableService.shared.fetchLessons()
        
        nowLessons = TimetableService.shared.getLessons(within: Date()).sorted(by: { (l1, l2) in
            return l1.startTime < l2.startTime
        })
        
        sectionIdentifiers = []
        
        tasks = TimetableService.shared.getTasks()
        
        // Add tasks section only if there are any tasks
        if (tasks?.count ?? 0) > 0 {
            addSection(id: tasksSection)
        }
        
        // If there are lessons right now show the "now" section, else show the next
        if (nowLessons?.count ?? 0) > 0 {
            addSection(id: nowSection)
        }
        
        nextLessons = TimetableService.shared.getNextLessons()
        
        if (nextLessons?.count ?? 0) > 0 {
            addSection(id: nextSection)
        }
        
        if (lessons?.count ?? 0) > 0 {
            addSection(id: weekSection)
        }
        
    }
    
    private func loadTask(for selection: HomeDashTaskSelectorCellType) {
        
        switch selection {
        case .today:
            tasks = TimetableService.shared.getTasksOfToday()
            break
        case .all:
            tasks = TimetableService.shared.getTasks()
        case .done:
            tasks = TimetableService.shared.getCompletedTasks()
            break
        case .expired:
            tasks = TimetableService.shared.getExpiredTasks()
        }
        
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
        case weekSection:
            return lessons?.count ?? 0
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
                
                let type = HomeDashTaskSelectorCellType(rawValue: indexPath.row)!
                
                cell.isSelected = type == taskSelection
                cell.type = type
                
                
                return cell
            }else {
                let cell = dequeueCell(homeDashTaskOverviewCollectionViewCell, indexPath) as! HomeDashTaskOverviewCollectionViewCell
                
                cell.tasks = tasks
                cell.taskDelegate = taskDelegate
                cell.reload()
                
                return cell
            }
            
        case nowSection:
            let cell = dequeueCell(homeLessonCell, indexPath) as! HomeLessonCollectionViewCell
            
            cell.lesson = nowLessons?[indexPath.row]
            
            return cell
        case nextSection:
            let cell = dequeueCell(homeLessonCell, indexPath) as! HomeLessonCollectionViewCell
            
            cell.lesson = nextLessons?[indexPath.row]
            
            return cell
        case weekSection:
            let cell = dequeueCell(homeLessonCell, indexPath) as! HomeLessonCollectionViewCell
            
            cell.lesson = lessons?[indexPath.row]
            
            return cell
        default:
            return UICollectionViewCell()
        }
        
    }
    
    private func presentDetail(_ lessons: [Lesson]?, _ indexPath: IndexPath) {
        if let lesson = lessons?[indexPath.row] {
            homeDelegate?.lessonDetail(self, for: lesson)
        }
    }
    
    //MARK: didSelectItemAt
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let sectionId = self.section(for: indexPath)
        
        switch sectionId {
        case tasksSection:
            if indexPath.row < 4 {
                taskSelection = HomeDashTaskSelectorCellType(rawValue: indexPath.row)!
                
                loadTask(for: taskSelection)
                
                collectionView.reloadSections(IndexSet(arrayLiteral: 0))
            }
            
            break
        case nowSection:
            presentDetail(nowLessons, indexPath)
            break
        case nextSection:
            presentDetail(nextLessons, indexPath)
            break
        case weekSection:
            presentDetail(lessons, indexPath)
            break
        default:
            break
        }
        
    }

    //MARK: supplementaryView
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "homeHeader", for: indexPath) as! HomeCollectionViewHeader
            
            let sectionId = section(for: indexPath)
            
            switch sectionId{
            case tasksSection:
                header.label.text = "Tasks"
            case nowSection:
                header.label.text =  "Now"
            case nextSection:
                header.label.text =  "Next"
            case weekSection:
                header.label.text = "All"
            default:
                header.label.text = "-"
            }
            return header
        }
        
        return UICollectionReusableView()
    }
    
    //MARK: sizeForHeaderInSection
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let lesson = self.lesson(for: indexPath)
        
        guard let uuid = lesson?.id else {
            return nil
        }
        
        let config = UIContextMenuConfiguration(identifier: uuid as NSUUID, previewProvider: { () -> UIViewController? in
            
            let lessonDetail = LessonDetailTableViewController(style: .insetGrouped)
            
            lessonDetail.lesson = lesson
            
//            lessonDetail.reload()
            
            lessonDetail.tableView.isScrollEnabled = false
            lessonDetail.tableView.showsVerticalScrollIndicator = false
            
            lessonDetail.tableView.beginUpdates()
            
            lessonDetail.addSection(with: "subjectTitle", at: 0)
            lessonDetail.addCell(with: LessonDetailSubjectTitleCell.lessonDetailSubjectTitleCell, at: "subjectTitle")
            lessonDetail.timeSectionIndex += 1
            lessonDetail.colorSectionIndex += 1
            lessonDetail.lessonTaskOverviewIndex += 1
            lessonDetail.lessonDeleteSecionIndex += 1
            lessonDetail.noteSectionIndex += 1
            
            lessonDetail.tableView.insertSections(IndexSet(arrayLiteral: 0), with: .none)
            
            lessonDetail.tableView.endUpdates()
            
            
            
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


extension HomeDashCollectionView {
    
    //MARK: sizeForItemAt
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionId = section(for: indexPath)
        
        switch sectionId {
        case tasksSection:
            if indexPath.row < 4 {
                return CGSize(width: (collectionView.contentSize.width -  16) / 2, height: 50)
            }
            
            return CGSize(width: collectionView.contentSize.width, height: 20 + CGFloat(min(3, tasks?.count ?? 0) * 60))
        case nowSection, nextSection, weekSection:
            
            let height = HomeLessonCellConfigurator.height(for: lesson(for: indexPath))
                
            return CGSize(width: collectionView.contentSize.width, height: height)
        default:
            return CGSize.zero
        }
        
    }

}


//MARK: HomeCollectionViewHeader
class HomeCollectionViewHeader: UICollectionReusableView  {
    
    var label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.topAnchor.constraint(equalTo: topAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}




