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

private let tasksSection = "tasksSection"
private let nowSection = "nowSection"
private let nextSection = "nextSection"
private let weekSection = "weekSection"

class HomeDashCollectionView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {

    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: self.frame, collectionViewLayout: UICollectionViewFlowLayout())
        
        view.delegate = self
        view.dataSource = self
        
        view.alwaysBounceVertical = true
        
        return view
    }()
    
    var cellColor: UIColor = .red
    
    var delegate: HomeCollectionViewDelegate?
    var taskDelegate: HomeTaskDetailDelegate?
    
    var subjects: [Subject]?
    var lessons: [Lesson]?
    
    
    //MARK: Section lesson arrays
    var nowLessons: [Lesson]?
    
    var nextLessons: [Lesson]?
    
    var tasks: [Task]?
    
    var sectionIdentifiers: [String] = []
    
    //MARK: init(frame: )
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUserInterface()
        
        fetchData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: UI setup
    private func setupUserInterface() {
        
        addSubview(collectionView)
        
        collectionView.backgroundColor = .systemGroupedBackground
        
        collectionView.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 10, right: 0)
        collectionView.register(HomeCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "homeHeader")
        collectionView.register(HomeLessonCollectionViewCell.self, forCellWithReuseIdentifier: homeLessonCell)
        collectionView.register(UINib(nibName: "HomeDashTaskOverviewCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: homeDashTaskOverviewCollectionViewCell)
        
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
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
    
    //MARK: - Section helper
    private func section(for section: Int) -> String {
        return sectionIdentifiers[section]
    }
    
    private func section(for indexPath: IndexPath) -> String {
        return section(for: indexPath.section)
    }
    
    private func section(for identifier: String) -> Int? {
        return sectionIdentifiers.firstIndex(of: identifier)
    }
    
    private func section(at section: Int, is identifier: String) -> Bool {
        return self.section(for: section) == identifier
    }
    
    private func section(at indexPath: IndexPath, is identifier: String) -> Bool {
        return section(at: indexPath.section, is: identifier)
    }
    
    private func addSection(id: String) {
        sectionIdentifiers.append(id)
    }
    
    //MARK: reload()
    func reload() {
        fetchData()
        collectionView.reloadData()
    }
    
    //MARK: fetchData()
    private func fetchData() {
        
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
    
    // MARK: - UICollectionViewDataSource
    
    //MARK: numberOfSections
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionIdentifiers.count
    }

    //MARK: numberOfItemsInSection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let sectionId = self.section(for: section)
        
        switch sectionId {
        case tasksSection:
            return 1
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
    
    
    private func dequeueCell(_ identifier: String, _ indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }
    
    //MARK: cellForItemAt
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let sectionId = self.section(for: indexPath)
        
        switch sectionId {
        case tasksSection:
            let cell = dequeueCell(homeDashTaskOverviewCollectionViewCell, indexPath) as! HomeDashTaskOverviewCollectionViewCell
        
            cell.tasks = tasks
            cell.taskDelegate = taskDelegate
            cell.reload()
            
            return cell
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
            delegate?.lessonDetail(self, for: lesson)
        }
    }
    
    //MARK: didSelectItemAt
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let sectionId = self.section(for: indexPath)
        
        switch sectionId {
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
    
    
//    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
//
//    }
//
//    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
//        print("fjweio")
//    }
//
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let lesson = self.lesson(for: indexPath)
        
        guard let uuid = lesson?.id else {
            return nil
        }
        
        let config = UIContextMenuConfiguration(identifier: uuid as NSUUID, previewProvider: { () -> UIViewController? in
            
            let lessonDetail = LessonDetailTableViewController(style: .insetGrouped)
            
            lessonDetail.lesson = lesson
            
            return lessonDetail
        }) { (elements) -> UIMenu? in
            
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash")) { (action) in
                
                guard let lesson = self.lesson(for: indexPath) else {
                    return
                }
                
                TimetableService.shared.deleteLesson(lesson)
                
                self.delegate?.lessonDidDelete(self, lesson: lesson)
                
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
            
            self.delegate?.lessonDetail(self, for: lesson)
        }
        
    }
}


extension HomeDashCollectionView: UICollectionViewDelegateFlowLayout {
    
    //MARK: sizeForItemAt
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionId = section(for: indexPath)
        
        if sectionId == tasksSection {
            return CGSize(width: collectionView.frame.width - 2 * 16, height: 50 + CGFloat(min(3, tasks?.count ?? 0) * 65))
        }
        
        switch sectionId {
        case tasksSection:
            return CGSize(width: collectionView.frame.width - 2 * 16, height: 50 + CGFloat(min(3, tasks?.count ?? 0) * 65))
        case nowSection, nextSection, weekSection:
            
            let height = HomeLessonCellConfigurator.height(for: lesson(for: indexPath))
                
            return CGSize(width: collectionView.frame.width - 2 * 16, height: height)
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
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}




