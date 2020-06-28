//
//  LessonDetailTaskOverviewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 28.06.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

private let taskOverviewItem = "taskOverviewItem"
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
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = .secondarySystemGroupedBackground
        
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let lesson = lesson else {
            return 0
        }
        let count = lesson.tasks?.count ?? 0
        return min(count, 3)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: taskOverviewItem, for: indexPath) as! TaskOverviewTableViewCell
        
        guard let lesson = self.lesson else {
            return cell
        }
        
        guard let tasks = lesson.tasks else {
            return cell
        }
        
        let task = tasks.allObjects as! [Task]
        cell.reload(task[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
        let id = "\(indexPath.row)" as NSString
        
        let config = UIContextMenuConfiguration(identifier: id, previewProvider: { () -> UIViewController? in
            
            let detail = TaskDetailTableViewController(style: .insetGrouped)
            
            detail.task = self.task(for: indexPath)
            detail.taskDelegate = self.taskDelegate
            
            return detail
        }) { (element) -> UIMenu? in
            
            let complete = UIAction(title: "Complete", image: UIImage(systemName: "checkmark")) { (action) in
                
                guard let task = self.task(for: indexPath) else {
                    return
                }
                
                task.completed.toggle()
                
                (tableView.cellForRow(at: indexPath) as! TaskOverviewTableViewCell).reload(task)

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
