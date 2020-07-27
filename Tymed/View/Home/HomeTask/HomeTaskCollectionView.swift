//
//  HomeTaskCollectionView.swift
//  Tymed
//
//  Created by Jonah Schueller on 27.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

private let nowReuseIdentifier = "homeNowCell"
private let taskTypeSelectorIdentifier = "taskTypeSelectorIdentifier"
private let addTaskIdentifier = "addTaskIdentifier"

private let taskHeader = "taskHeader"

private let headerSection = "typeSection"
private let todaySection = "todaySection"
private let allSection = "allSection"
private let doneSection = "doneSection"
private let expiredSection = "expiredSection"
private let openSection = "openSection"
private let archivedSection = "archivedSection"
private let plannedSection = "plannedSection"

class HomeTaskCollectionView: HomeBaseCollectionView {
    
    var todayTasks: [Task]?
    var allTasks: [Task]?
    var doneTasks: [Task]?
    var expiredTasks: [Task]?
    var openTasks: [Task]?
    var archivedTasks: [Task]?
    var plannedTasks: [Task]?
    
    private var typeCellSelectors = [HomeDashTaskSelectorCellType]()
    private var taskSectionSize = [String : TaskOverviewSectionSize]()
    
    var taskOverviewDelegate: TaskOverviewTableviewCellDelegate?
    
    //MARK: UI setup
    internal override func setupUserInterface() {
        super.setupUserInterface()
        
        register(HomeCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "homeHeader")
        register(HomeDashTaskOverviewCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: taskHeader)
        
        register(HomeTaskCollectionViewCell.self, forCellWithReuseIdentifier: homeTaskCell)
        
        register(HomeDashTaskSelectorCollectionViewCell.self, forCellWithReuseIdentifier: taskTypeSelectorIdentifier)
        register(UINib(nibName: "HomeDashTaskOverviewCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: homeDashTaskOverviewCollectionViewCell)
        
        register(HomeDashTaskOverviewNoTasksCollectionViewCell.self, forCellWithReuseIdentifier: addTaskIdentifier)
        
        
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            
            flowLayout.minimumInteritemSpacing = 16
            
        }
    }
    
    private func identifier(for indexPath: IndexPath) -> String {
        let identifier = self.section(for: indexPath.section)
        
        switch identifier {
        case headerSection:
            return indexPath.row < typeCellSelectors.count ?  taskTypeSelectorIdentifier : addTaskIdentifier
        case todaySection, allSection, doneSection, expiredSection, openSection, archivedSection, plannedSection:
            return homeDashTaskOverviewCollectionViewCell
        default:
            return ""
        }
        
    }
    
    private func setupSections(_ tasks: [Task]?, section: String, type: HomeDashTaskSelectorCellType) {
        if tasks?.count ?? 0 > 0 {
            addSection(id: section)
            typeCellSelectors.append(type)
            
            if taskSectionSize[section] == nil {
                taskSectionSize[section] = .compact
            }
        }
    }
    
    private func getTasks(of type: HomeDashTaskSelectorCellType) -> [Task] {
        return type.tasks()
    }
    
    //MARK: fetchData()
    internal override func fetchData() {
        
        todayTasks = getTasks(of: .today)
        allTasks = getTasks(of: .all)
        doneTasks = getTasks(of: .done)
        expiredTasks = getTasks(of: .expired)
        openTasks = getTasks(of: .open)
        archivedTasks = getTasks(of: .archived)
        plannedTasks = getTasks(of: .planned)
        
        sectionIdentifiers = []
        typeCellSelectors = []
        
        addSection(id: headerSection)
        
        setupSections(todayTasks, section: todaySection, type: .today)
        setupSections(openTasks, section: openSection, type: .open)
        setupSections(plannedTasks, section: plannedSection, type: .planned)
        setupSections(doneTasks, section: doneSection, type: .done)
        setupSections(expiredTasks, section: expiredSection, type: .expired)
        setupSections(archivedTasks, section: archivedSection, type: .archived)
        setupSections(allTasks, section: allSection, type: .all)
        
    }
    
    // MARK: - UICollectionViewDataSource

    //MARK: numberOfItemsInSection
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let identifier = self.section(for: section)
        
        if identifier == headerSection {
            return typeCellSelectors.count + 1
        }
        
        // The section 
        return (taskSectionSize[identifier] ?? .compact) != .collapsed ? 1 : 0
    }
    
    private func tasks(for section: String) -> [Task]? {
        switch section {
        case todaySection:
            return todayTasks
        case allSection:
            return allTasks
        case doneSection:
            return doneTasks
        case expiredSection:
            return expiredTasks
        case openSection:
            return openTasks
        case archivedSection:
            return archivedTasks
        case plannedSection:
            return plannedTasks
        default:
            return []
        }
    }
    
    private func configureCell(_ cell: UICollectionViewCell, identifier: String, indexPath: IndexPath) {
        
        if identifier == taskTypeSelectorIdentifier {
            let cell = (cell as! HomeDashTaskSelectorCollectionViewCell)
            
            cell.selectedIndicator.isHidden = true
            cell.type = typeCellSelectors[indexPath.row]
            
            
        }else if identifier == addTaskIdentifier {
            let addCell = (cell as! HomeDashTaskOverviewNoTasksCollectionViewCell)
            
            addCell.taskDelegate = taskDelegate
            
        } else if identifier == homeDashTaskOverviewCollectionViewCell {
            let taskCell = (cell as! HomeDashTaskOverviewCollectionViewCell)
            let section = self.section(for: indexPath.section)
            
            taskCell.size = taskSectionSize[section] ?? .compact
            taskCell.taskOverviewDelegate = taskOverviewDelegate
            
            taskCell.tasks = self.tasks(for: section)
            taskCell.taskDelegate = taskDelegate
            taskCell.reload()
            
        }

        
    }
    
    //MARK: cellForItemAt
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let identifier = self.identifier(for: indexPath)

        let cell = dequeueCell(identifier, indexPath)

        configureCell(cell, identifier: identifier, indexPath: indexPath)
        
        return cell

    }
    
    private func presentDetail(_ tasks: [Task]?, _ indexPath: IndexPath) {
        if let task = tasks?[indexPath.row] {
            homeDelegate?.taskDetail(self, for: task)
        }
    }
    
    private func sectionIdentifier(for type: HomeDashTaskSelectorCellType) -> String? {
        switch type {
        case .today:    return todaySection
        case .all:      return allSection
        case .done:     return doneSection
        case .expired:  return expiredSection
        case .open:     return openSection
        case .archived: return archivedSection
        case .planned:  return plannedSection
        }
    }
    
    //MARK: didSelectItemAt
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

//        presentDetail(tasks, indexPath)
        let section = self.section(for: indexPath.section)
        let identifier = self.identifier(for: indexPath)

        if section == headerSection {
            if identifier == addTaskIdentifier {
                taskDelegate?.onAddTask(nil, completion: nil)
            }else {
                guard let id = sectionIdentifier(for: typeCellSelectors[indexPath.row]) else {
                    return
                }
                
                guard let index = self.section(for: id) else {
                    return
                }
                
                let headerOffset = collectionView.collectionViewLayout
                    .layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at:
                                                        IndexPath(row: 0, section: index))?.frame.origin.y ?? 0
                
                collectionView.setContentOffset(CGPoint(x: collectionView.contentOffset.x, y: headerOffset - collectionView.contentInset.top), animated: true)
                
//                collectionView.scrollToItem(at: IndexPath(row: 0, section: index), at: .top, animated: true)
            }

        }
    }
    
    private func sectionTitle(for sectionId: String) -> String {
        switch sectionId{
            case headerSection:     return "Tasks"
            case todaySection:      return "Today"
            case allSection:        return "All"
            case doneSection:       return "Done"
            case expiredSection:    return "Expired"
            case openSection:       return "Open"
            case archivedSection:   return "Archived"
            case plannedSection:    return "Planned"
            default:                return ""
        }
    }
    
    //MARK: supplementaryView
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let sectionTitle = self.sectionTitle(for: section(for: indexPath))
        
        if kind == UICollectionView.elementKindSectionHeader && indexPath.section == 0 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "homeHeader", for: indexPath) as! HomeCollectionViewHeader
            
            header.label.text = sectionTitle
            
            return header
        }else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: taskHeader, for: indexPath) as! HomeDashTaskOverviewCollectionViewHeader
            
            header.sectionIdentifier = self.section(for: indexPath.section)
            header.size = taskSectionSize[self.section(for: indexPath.section)] ?? .compact
            header.label.text = sectionTitle
            header.delegate = self
            
            return header
        }
    }
    
    //MARK: sizeForHeaderInSection
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let height: CGFloat = 50
        
        return CGSize(width: collectionView.frame.width, height: height)
    }
    
    private func taskCount(for section: String, size: TaskOverviewSectionSize) -> Int {
        let taskCount = self.tasks(for: section)?.count ?? 0
        
        return min(size.maxItems, taskCount)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let identifier = self.identifier(for: indexPath)
        
        var width: CGFloat = (collectionView.frame.width - 2 * 20)
        var height: CGFloat = 50
        
        if identifier == taskTypeSelectorIdentifier ||
            (identifier == addTaskIdentifier && typeCellSelectors.count % 2 != 0) {
            width = (collectionView.frame.width - 60) / 2
        }
        
        if identifier == homeDashTaskOverviewCollectionViewCell {
            
            let section = self.section(for: indexPath.section)
            let taskCount = self.taskCount(for: section, size: taskSectionSize[section] ?? .compact)
            
            height = 20 + CGFloat(taskCount * 60)
        }
        
        return CGSize(width: width, height: height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        homeDelegate?.didScroll(scrollView)
    }
    
}



extension HomeTaskCollectionView: TaskOverviewHeaderDelegate {
    
    /// Handles the deletion, insertion, reloading of the sections when a task header changes it's size
    /// - Parameters:
    ///   - header: Task Header that is tapped
    ///   - identifier: Section identifier of the section
    func onCollapseToogle(_ header: HomeDashTaskOverviewCollectionViewHeader, identifier: String) {
        taskSectionSize[identifier] = header.size
        let section = self.section(for: identifier) ?? 0
        
        switch header.size {
        case .collapsed:
            deleteItems(at: [IndexPath(row: 0, section: section)])
        case .compact:
            insertItems(at: [IndexPath(row: 0, section: section)])
        case .large:
            reloadItems(at: [IndexPath(row: 0, section: section)])
        }
        
    }
    
    /// Determines the next size when a task section header is tapped.
    /// Usually it will return .collapsed -> .compact -> .large -> ...
    /// But if the tasks for the section aren't more than the .compact can show, displaing
    /// the large is unnecessary
    /// - Parameters:
    ///   - header: Task Header that is tapped
    ///   - current: Current size of the header
    ///   - identifier: Section identifier of the section
    /// - Returns: The next size the header/ section should have
    func nextSizeFor(_ header: HomeDashTaskOverviewCollectionViewHeader, current: TaskOverviewSectionSize, with identifier: String) -> TaskOverviewSectionSize {
        let nextSize = current.next()
        let tasksCount = self.taskCount(for: identifier, size: nextSize)
            
        if nextSize == .large {
            // If there aren't enough tasks to show a large section -> skip .large and go to .collapsed
            if tasksCount <= TaskOverviewSectionSize.compact.maxItems {
                return .collapsed
            }
        }
        return nextSize
    }
}
