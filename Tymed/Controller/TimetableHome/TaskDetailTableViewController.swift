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
            selectLesson(task?.lesson)
        }
    }
    
    private var isEditable: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    override func configureCell(_ cell: UITableViewCell, for identifier: String, at indexPath: IndexPath) {
        super.configureCell(cell, for: identifier, at: indexPath)
        
        let section = indexPath.section
        
        switch identifier {
        case taskTitleCell:
            guard section == 0 else {
                break
            }
            let cell = cell as! TaskTitleTableViewCell
            cell.textField.text = task?.title
            cell.textField.isEnabled = isEditable
            
            break
        case taskDescriptionCell:
            guard section == 1 else {
                break
            }
            let cell = cell as! TaskDescriptionTableViewCell
            
            cell.textView.text = task?.text ?? ""
            cell.textView.isEditable = isEditable
            
            break
        case taskDueDateCell:
            
            break
        default:
            break
        }
        
    }

}
