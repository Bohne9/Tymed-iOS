//
//  TaskDetailCollectionViewController.swift
//  Tymed
//
//  Created by Jonah Schueller on 28.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

private let taskDeleteCell = "taskDeleteIdentifier"

class TaskDetailTableViewController: TaskAddViewController {

    var task: Task? {
        didSet {
            reload()
        }
    }
    
    private var isEditable: Bool = false
    private var taskDeleteSection = -1
    
    var taskDelegate: HomeTaskDetailDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let item = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toogleEditing(_:)))
        
        navigationItem.rightBarButtonItem = item
        
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissDetailView))
        
        navigationItem.rightBarButtonItem = item
        navigationItem.leftBarButtonItem = cancel
        
        register(UINib(nibName: "TaskDeleteTableViewCell", bundle: nil), identifier: taskDeleteCell)
        
        addSection(with: "delete")
        
        taskDeleteSection = sectionIndex(for: "delete") ?? -1
        
        addCell(with: taskDeleteCell, at: taskDeleteSection)
        
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
    
    private func deleteTask() {
        if let task = self.task {
            
            TimetableService.shared.deleteTask(task)
            
            self.task = nil
            self.dismiss(animated: true) {
                self.taskDelegate!.didDeleteTask(task)
            }
            print("delete")
        }
    }
    
    @objc func showDeleteConfirm(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "", message: "Are you sure?", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive , handler:{ (action) in
            // Delete task
            self.deleteTask()
        }))

        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (action) in
            print("Dismiss")
        }))
        
        if let popOver = alert.popoverPresentationController {
            popOver.sourceView = sender
        }
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    private func setupDeleteCell(_ cell: UITableViewCell) {
        
        guard let deleteCell = cell as? TaskDeleteTableViewCell else {
            return
        }
        print("setting up delete cell")

        deleteCell.deleteBtn?.addTarget(self, action: #selector(showDeleteConfirm), for: .touchUpInside)
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
            
            cell.selectionStyle = isEditable ? .default : .none
            
            cell.removeBtn.isHidden = !isEditable
            
            break
        case taskDueDateCell:
            guard section == taskDescriptionSection else {
                break
            }
            
            cell.selectionStyle = isEditable ? .default : .none
            
            break
        case taskDeleteCell:
            guard section == taskDeleteSection else {
                break
            }
            
            setupDeleteCell(cell)
            
            break
        default:
            break
        }
        
    }

    override func didSelectRow(at indexPath: IndexPath, with identifier: String) {
        
        // Disable any cell selection when the view is not in editing mode.
        if isEditable {
            super.didSelectRow(at: indexPath, with: identifier)
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
            taskDeleteSection = taskDeleteSection - 1
        }
    }
    
    private func reloadEditable(_ task: Task) {
        
        if sectionIndex(for: "description") == nil {
            taskDescriptionSection =  1
            taskLessonSection = taskLessonSection + 1
            taskDueSection = taskDueSection + 1
            taskDeleteSection = taskDeleteSection + 1
            addSection(with: "description", at: taskDescriptionSection)
            
            addCell(with: taskDescriptionCell, at: taskDescriptionSection)
        }
        
    }
    
    override func heightForRow(at indexPath: IndexPath, with identifier: String) -> CGFloat {
        if identifier == taskDeleteCell {
            return 50
        }
        return super.heightForRow(at: indexPath, with: identifier)
    }
    
    
}
