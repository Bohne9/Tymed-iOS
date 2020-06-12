//
//  TaskDetailCollectionViewController.swift
//  Tymed
//
//  Created by Jonah Schueller on 28.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class TaskDetailTableViewController: TaskAddViewController {

    
    var task: Task? {
        didSet {
            reload()
        }
    }
    
    private var isEditable: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let item = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toogleEditing(_:)))
        
        navigationItem.rightBarButtonItem = item
        
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissDetailView))
        
        navigationItem.rightBarButtonItem = item
        navigationItem.leftBarButtonItem = cancel
        
        reload()
    }
    
    @objc func toogleEditing(_ btn: UIBarButtonItem) {
        isEditable.toggle()
        
        btn.title = isEditable ? "Save" : "Edit"
        btn.style = isEditable ? .done : .plain
        
        
        reload()
    }
    
    @objc func dismissDetailView() {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    override func configureCell(_ cell: UITableViewCell, for identifier: String, at indexPath: IndexPath) {
        super.configureCell(cell, for: identifier, at: indexPath)
        
        let section = indexPath.section
        
        switch identifier {
        case taskTitleCell:
            guard section == taskTitleSection else {
                break
            }
            let cell = cell as! TaskTitleTableViewCell
            cell.textField.text = task?.title
            cell.textField.isEnabled = isEditable
            
            break
        case taskDescriptionCell:
            guard section == taskDescriptionSection else {
                break
            }
            let cell = cell as! TaskDescriptionTableViewCell
            
            cell.textView.text = task?.text ?? ""
            cell.textView.isEditable = isEditable
            
            break
        case taskAttachedLessonCell:
            guard section == taskLessonSection else {
                break
            }
            let cell = cell as! TaskAttachedLessonTableViewCell
            
            cell.removeBtn.isHidden = !isEditable
            
            break
        case taskDueDateCell:
            guard section == taskDescriptionSection else {
                break
            }
            break
        default:
            break
        }
        
    }

    
    func reload() {
        guard let task = task else {
            // Return since there is no task
            return
        }
        
        
        // Reconfigure the cell for the corresponding mode (editing, none editing)
        if isEditable {
            reloadEditable(task)
        }else {
            reloadNoneEditable(task)
        }
        
        selectLesson(task.lesson)
        
        if tableView.superview != nil {
            tableView.reloadData()
        }
    }
    
    private func reloadNoneEditable(_ task: Task) {
        // Remove the description cell in case the task does not have a description
        if (task.text == nil || task.text == ""), let index = sectionIndex(for: "description") {
            removeSection(at: index)
            taskLessonSection = taskLessonSection - 1
            taskDueSection = taskDueSection - 1
            taskDescriptionSection = -1
        }
    }
    
    private func reloadEditable(_ task: Task) {
        
        if sectionIndex(for: "description") == nil {
            taskDescriptionSection = 1
            taskLessonSection = 2
            taskDueSection = 3
            addSection(with: "description", at: taskDescriptionSection)
            
            addCell(with: taskDescriptionCell, at: taskDescriptionSection)
        }
        
    }
    
    
}
