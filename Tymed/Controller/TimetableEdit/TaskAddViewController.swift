//
//  TaskAddViewController.swift
//  Tymed
//
//  Created by Jonah Schueller on 22.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit
private let taskTitleCell = "taskTitleCell"
private let taskDescriptionCell = "taskDescriptionCell"
private let taskDueDateTitleCell = "taskDueDateTitleCell"
private let taskDueDateCell = "taskDueDateCell"

class TaskAddViewController: TymedTableViewController {

    private var expandDueDateCell = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func setup() {
        super.setup()
        
        setupNavigationBar()
        
        
    }

    internal func setupNavigationBar() {
        
        title = "Task"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let rightItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addTask))
        
        navigationItem.rightBarButtonItem = rightItem
        
        let leftItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        
        navigationItem.leftBarButtonItem = leftItem
        
        register(UINib(nibName: "TaskTitleTableViewCell", bundle: nil), identifier: taskTitleCell)
        
        register(UINib(nibName: "TaskDescriptionTableViewCell", bundle: nil), identifier: taskDescriptionCell)
        
        register(UINib(nibName: "TaskDueDateTableViewCell", bundle: nil), identifier: taskDueDateCell)
        
        register(UINib(nibName: "TaskDueDateTitleTableViewCell", bundle: nil), identifier: taskDueDateTitleCell)
        
        addSection(with: "task")
        addCell(with: taskTitleCell, at: "task")
        
        addSection(with: "description")
        addCell(with: taskDescriptionCell, at: "description")
        
        addSection(with: "due")
        addCell(with: taskDueDateTitleCell, at: "due")
    }

    @objc func addTask() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }

    override func headerForSection(with identifier: String, at index: Int) -> String? {
        switch index {
        case 0:
            return ""
        case 1:
            return "Description"
        case 2:
            return "Due date"
        default:
            return ""
        }
    }
    
    override func heightForRow(at indexPath: IndexPath, with identifier: String) -> CGFloat {
        switch identifier {
        case taskTitleCell:
            return 40
        case taskDueDateTitleCell:
            return 80
        case taskDescriptionCell:
            return 120
        case taskDueDateCell:
            return 180
        default:
            return 0
        }
    }
    
    override func didSelectRow(at indexPath: IndexPath, with identifier: String) {
        super.didSelectRow(at: indexPath, with: identifier)
        
        let section = indexPath.section
        let row = indexPath.row
        let sectionIdentifer = sectionIdentifier(for: section)
        
        switch sectionIdentifer {
        case "due":
            if row == 0 {
                
                if expandDueDateCell {
                    removeCell(at: section, row: 1)
                    tableView.deleteRows(at: [IndexPath(row: 1, section: section)], with: .top)
                }else {
                    addCell(with: taskDueDateCell, at: "due")
                    tableView.insertRows(at: [IndexPath(row: 1, section: section)], with: .top)
                }
                expandDueDateCell.toggle()

            }
        default:
            break
        }
    }
    
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        switch section {
//        case 0:
//            return 0
//        case 1:
//            return super.tableView(tableView, heightForHeaderInSection: section)
//        default:
//            return 0
//        }
//    }
//
    
}
