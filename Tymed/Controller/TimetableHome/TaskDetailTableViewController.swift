//
//  TaskDetailCollectionViewController.swift
//  Tymed
//
//  Created by Jonah Schueller on 28.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

private let taskDeleteCell = "taskDeleteIdentifier"

private let taskDeleteSection = "taskDeleteSection"
private let taskArchiveSection = "taskArchiveSection"

class TaskDetailTableViewController: TaskAddViewController {

    var task: Task? {
        didSet {
//            reload()
        }
    }
    
    private var isEditable: Bool = false
    
    var taskDelegate: HomeTaskDetailDelegate?
    
    override func setup() {
        super.setup()
        
        let item = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toogleEditing(_:)))
        
        navigationItem.rightBarButtonItem = item
        
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissDetailView))
        
        navigationItem.rightBarButtonItem = item
        navigationItem.leftBarButtonItem = cancel
        
        register(UINib(nibName: "TaskDeleteTableViewCell", bundle: nil), identifier: taskDeleteCell)
        register(TaskArchiveTableViewCell.self, identifier: TaskArchiveTableViewCell.identifier)
        
        addSection(with: taskArchiveSection)
        addCell(with: TaskArchiveTableViewCell.identifier, at: taskArchiveSection)
        
        addSection(with: taskDeleteSection)
        addCell(with: taskDeleteCell, at: taskDeleteSection)
        
        reload()
    }
    
    //MARK: updateTaskValues
    private func updateTaskValues() {
        guard let task = self.task else {
            return
        }
        
        task.title = taskTitle ?? ""
        task.text = taskDescription
        
        task.lesson = lesson
        
        task.due = dueDate
        
        TimetableService.shared.save()
    }
    
    //MARK: toogleEditing
    @objc func toogleEditing(_ btn: UIBarButtonItem) {
        if isEditable {
            updateTaskValues()
        }
        
        isEditable.toggle()
        
        btn.title = isEditable ? "Save" : "Edit"
        btn.style = isEditable ? .done : .plain
        
        reload()
    }
    
    @objc func dismissDetailView() {
        detailDelegate?.detailWillDismiss()
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: deleteTask
    private func deleteTask() {
        if let task = self.task {
            
            TimetableService.shared.deleteTask(task)
            
            self.task = nil
            self.dismiss(animated: true) {
                self.taskDelegate!.didDeleteTask(task)
            }
        }
    }
    
    //MARK: showDeleteConfirm
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
    
    //MARK: setupDeleteCell
    private func setupDeleteCell(_ cell: UITableViewCell) {
        
        guard let deleteCell = cell as? TaskDeleteTableViewCell else {
            return
        }

        deleteCell.deleteBtn?.addTarget(self, action: #selector(showDeleteConfirm), for: .touchUpInside)
    }
    
    //MARK: configureCell
    override func configureCell(_ cell: UITableViewCell, for identifier: String, at indexPath: IndexPath) {
        super.configureCell(cell, for: identifier, at: indexPath)
        
        switch identifier {
        case taskTitleCell:
            let cell = cell as! TaskTitleTableViewCell
            
            cell.setCompleteBtn(active: true)
            cell.setComplete(for: self.task)
            cell.textField.text = task?.title
            cell.textField.isEnabled = isEditable
            
            break
        case taskDescriptionCell:
            let cell = cell as! TaskDescriptionTableViewCell
            
            cell.textView.text = task?.text ?? ""
            cell.textView.isEditable = isEditable
            
            break
        case taskAttachedLessonCell:
            let cell = cell as! TaskAttachedLessonTableViewCell
            
            cell.selectionStyle = isEditable ? .default : .none
            
            cell.removeBtn.isHidden = !isEditable
            
            break
        case taskDueDateCell:
            
            cell.selectionStyle = isEditable ? .default : .none
            
            break
        case taskDeleteCell:
            setupDeleteCell(cell)
            
            break
        case TaskArchiveTableViewCell.identifier:
            let cell = cell as! TaskArchiveTableViewCell
            cell.task = task
        default:
            break
        }
        
    }
    
    //MARK: didSelectRow
    override func didSelectRow(at indexPath: IndexPath, with identifier: String) {
        
        // Disable any cell selection when the view is not in editing mode.
        if isEditable {
            super.didSelectRow(at: indexPath, with: identifier)
        }
        
    }
    
    //MARK: reload
    override func reload() {
        guard let task = task else {
            // Return since there is no task
            return
        }
        
        taskTitle = taskTitle ?? task.title
        taskDescription = taskDescription ?? task.text
//        lesson = lesson ?? task.lesson
        dueDate = dueDate ?? task.due
        
        // Reconfigure the cell for the corresponding mode (editing, none editing)
        if isEditable {
            reloadEditable(task)
        }else {
            reloadNoneEditable(task)
        }
        
        selectLesson(task.lesson)
        
//        if tableView.superview != nil {
            tableView.reloadData()
//        }
    }
    
    //MARK: onNotificationSwitchToogle
    override func onNotificationSwitchToogle(_ sender: UISwitch) {
        super.onNotificationSwitchToogle(sender)
        
        guard let task = self.task else {
            return
        }
        
        if shouldSendNotification {
            NotificationService.current.scheduleDueDateNotification(for: task)
        }else {
            NotificationService.current.removePendingNotifications(of: task)
        }
    }
    
    //MARK: iconForSection
    override func iconForSection(with identifier: String, at index: Int) -> String? {
        if identifier == taskArchiveSection {
            return "tray.full.fill"
        } else if identifier == taskDeleteSection {
            return "trash.fill"
        }
        return super.iconForSection(with: identifier, at: index)
    }
    
    //MARK: headerForSection
    override func headerForSection(with identifier: String, at index: Int) -> String? {
        if identifier == taskArchiveSection {
            return "Archive"
        } else if identifier == taskDeleteSection {
            return "Delete"
        }
        return super.headerForSection(with: identifier, at: index)
    }
    
    //MARK: reloadNoneEditable
    private func reloadNoneEditable(_ task: Task) {
        // Remove the description cell in case the task does not have a description
        if (task.text == nil || task.text == ""), let index = sectionIndex(for: descriptionSection) {
            tableViewUpdateAnimation = .automatic
            removeSection(at: index)
            tableViewUpdateAnimation = .top
        }
    }
    
    //MARK: reloadEditable
    private func reloadEditable(_ task: Task) {
        
        if sectionIndex(for: descriptionSection) == nil {
            tableViewUpdateAnimation = .automatic
            addSection(with: descriptionSection, at: 1)
            
            guard let secIndex = self.sectionIndex(for: descriptionSection) else {
                return
            }
            
            addCell(with: taskDescriptionCell, at: secIndex)
        }
        
    }
    
    //MARK: heightForRow
    override func heightForRow(at indexPath: IndexPath, with identifier: String) -> CGFloat {
        if identifier == taskDeleteCell || identifier == TaskArchiveTableViewCell.identifier {
            return 50
        }
        return super.heightForRow(at: indexPath, with: identifier)
    }
    
    /// Returns the due date of the task
    /// - Returns: Due date of the task
    override func dueDateForTask() -> Date? {
        return task?.due
    }
    
}

