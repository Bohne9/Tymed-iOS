//
//  TimetableDetailTableViewController.swift
//  Tymed
//
//  Created by Jonah Schueller on 22.07.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

private let deleteCell = "deleteCell"

enum TimetableDetailMode {
    case normal
    case editing
}

class TimetableDetailTableViewController: TimetableAddViewController {

    var timetableDeletionDelegate: TimetableOverviewDeleteDelegate?
    var mode: TimetableDetailMode = .normal
    
    override func setupNavigationBar() {
        
        title = timetable?.name
        
        navigationController?.navigationBar.prefersLargeTitles = false
        
    }
    
    override func reconfigure() {
        super.reconfigure()
        
    }
    
    override func setup() {
        super.setup()
        
        register(TimetableDetailDeleteTableViewCell.self, identifier: deleteCell)
        
        
        
        let rightItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toogleRightBarButton(_:)))
        
        navigationItem.rightBarButtonItem = rightItem
    }
    
    // Override the setup of the superclass
    override func setupSections() { }
    
    func saveTimetable() {
        timetable?.name = timetableTitle ?? ""
                
        TimetableService.shared.save()
        
        reload()
    }
    
    @objc func toogleRightBarButton(_ sender: UIBarButtonItem) {
        mode = self.mode == .normal ? .editing : .normal
        
        sender.title = mode == .editing ? "Save" : "Edit"
        
        switch mode {
        case .editing:
            insertTitleEditCell()
        case .normal:
            saveTimetable()
            removeTitleEditCell()
        }
    }
    
    override func onTitleTextChanges(_ textField: UITextField) {
        super.onTitleTextChanges(textField)
        title = textField.text
    }
    
    private func insertTitleEditCell() {
        tableView.beginUpdates()
        
        addSection(with: "titleSection", at: 0)
        addCell(with: titleCell, at: "titleSection")
        
        addSection(with: "deletion")
        addCell(with: deleteCell, at: "deletion")
        
        tableView.insertSections(IndexSet(arrayLiteral: 0, 1), with: .top)
        
        tableView.endUpdates()
    }
    
    private func removeTitleEditCell() {
        tableView.beginUpdates()
        
        removeSection(with: "titleSection")
        removeSection(with: "deletion")
        
        tableView.deleteSections(IndexSet(arrayLiteral: 0, 1), with: .top)
        
        tableView.endUpdates()
    }
    
    override func configureCell(_ cell: UITableViewCell, for identifier: String, at indexPath: IndexPath) {
        switch identifier {
        case deleteCell:
            let cell = cell as! TimetableDetailDeleteTableViewCell
            
            cell.timetable = timetable
            cell.timetableDeletionDelgate = timetableDeletionDelegate
            
        default:
            super.configureCell(cell, for: identifier, at: indexPath)
        }
    }
    
    override func heightForRow(at indexPath: IndexPath, with identifier: String) -> CGFloat {
        if identifier == deleteCell {
            return 50
        }else {
            return super.heightForRow(at: indexPath, with: identifier)
        }
    }
    
}
