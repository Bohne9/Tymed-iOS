//
//  LessonDetailTaskOverviewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 28.06.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

private let taskOverviewItem = "taskOverviewItem"
private let taskOverviewSeeAll = "taskOverviewSeeAll"

protocol LessonDetailTaskOverviewDelegate {
    
    func lessonDetailPresentAllTasks(_ cell: LessonDetailTaskOverviewCell)
    
}

class LessonDetailTaskOverviewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    

    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        
        return tableView
    }()
    
    var lesson: Lesson? {
        didSet {
            tableView.reloadData()
        }
    }
    var taskDelegate: HomeTaskDetailDelegate?
    
    var taskOverviewDelegate: LessonDetailTaskOverviewDelegate?
    
    private var cellInsets: UIEdgeInsets?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        contentView.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.constraintToSuperview(top: 10, bottom: 10, leading: 20, trailing: 20)
        
        tableView.register(TaskOverviewTableViewCell.self, forCellReuseIdentifier: taskOverviewItem)
        tableView.register(LessonDetailTaskOverviewSeeAllCell.self, forCellReuseIdentifier: taskOverviewSeeAll)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = .secondarySystemGroupedBackground
        
        tableView.isScrollEnabled = false
        
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let lesson = lesson else {
            return 0
        }
        var count = lesson.tasks?.count ?? 0
        
        if count > 0 {
            print("CHANGE LessonDetailTaskOverviewCell.tableView(.. numberOfRowsInSection > 0!")
            count += 1
        }
        
        return min(count, 4)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // If this is the last cell (see all)
        let cellCount = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
        
        if cellCount >= 0 && indexPath.row == cellCount - 1 {
            print("dequeue task see all")
            let cell = tableView.dequeueReusableCell(withIdentifier: taskOverviewSeeAll, for: indexPath) as! LessonDetailTaskOverviewSeeAllCell
            
            if indexPath.row == min(self.lesson?.tasks?.count ?? 0, 3) - 1 {
                if cellInsets == nil {
                    cellInsets = cell.separatorInset
                }
                cell.separatorInset = UIEdgeInsets(top: 0, left: cell.frame.width, bottom: 0, right: 0)
            }else if let insets = cellInsets {
                cell.separatorInset = insets
            }
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: taskOverviewItem, for: indexPath) as! TaskOverviewTableViewCell
        
        guard let lesson = self.lesson else {
            return cell
        }
        
        guard let tasks = lesson.tasks else {
            return cell
        }
         
        if indexPath.row == min(self.lesson?.tasks?.count ?? 0, 3) - 1 {
            if cellInsets == nil {
                cellInsets = cell.separatorInset
            }
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.frame.width, bottom: 0, right: 0)
        }else if let insets = cellInsets {
            cell.separatorInset = insets
        }
        
        let task = tasks.allObjects as! [Task]
        cell.reload(task[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // If this is the last cell (see all)
        let cellCount = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
        
        if cellCount >= 0 && indexPath.row == cellCount - 1 {
            return 35
        }
        
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // If this is the last cell (see all)
        let cellCount = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
        
        if cellCount >= 0 && indexPath.row == cellCount - 1 {
            
            taskOverviewDelegate?.lessonDetailPresentAllTasks(self)
            
            return
        }
        
        guard let task = self.task(for: indexPath) else {
            return
        }
        
        taskDelegate?.showTaskDetail(task)
    }
    
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        
        let item = Int((configuration.identifier as! NSString) as String) ?? 0
        
        animator.addCompletion {
            let task = self.task(for: IndexPath(row: item, section: 0))!
            
            self.taskDelegate?.showTaskDetail(task)
        }
        
    }
    
    private func task(for indexPath: IndexPath) -> Task? {
        let tasks = self.lesson?.tasks?.allObjects as! [Task]
        
        return tasks[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        // If this is the last cell (see all)
        let cellCount = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
        
        if cellCount >= 0 && indexPath.row == cellCount - 1 {
            return nil
        }
        
        let id = "\(indexPath.row)" as NSString
        
        let config = UIContextMenuConfiguration(identifier: id, previewProvider: { () -> UIViewController? in
            
            let detail = TaskDetailTableViewController(style: .insetGrouped)
            
            detail.task = self.task(for: indexPath)
            detail.taskDelegate = self.taskDelegate
            
            return detail
        }) { (element) -> UIMenu? in
            
            let complete = UIAction(title: "Complete", image: UIImage(systemName: "checkmark")) { (action) in
                
                let cell = (tableView.cellForRow(at: indexPath) as! TaskOverviewTableViewCell)
                
                // Delay the complete toogle for the animation.
                // The context menu animation has to end
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    cell.completeToogle()
                }
                
            }
            
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash")) { (action) in
                
                guard let task = self.task(for: indexPath) else {
                    return
                }
                
                TimetableService.shared.deleteTask(task)
                
                self.taskDelegate?.didDeleteTask(task)
                
            }
            
            return UIMenu(title: "", image: nil, children: [complete, delete])
        }
        
        
        return config
    }
    
    
    
}
