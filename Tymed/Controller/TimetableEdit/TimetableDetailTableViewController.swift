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
    
    override func setupSections() {
        addSection(with: "deletion")
        addCell(with: deleteCell, at: "deletion")
    }
    
    @objc func toogleRightBarButton(_ sender: UIBarButtonItem) {
        mode = self.mode == .normal ? .editing : .normal
        
        sender.title = mode == .editing ? "Edit" : "Save"
        
        switch mode {
        case .editing:
            insertTitleEditCell()
        case .normal:
            removeTitleEditCell()
        }
    }
    
    private func insertTitleEditCell() {
        tableView.beginUpdates()
        
        addSection(with: "titleSection", at: 0)
        addCell(with: titleCell, at: "titleSection")
        
        tableView.insertSections(IndexSet(arrayLiteral: 0), with: .top)
        
        tableView.endUpdates()
    }
    
    private func removeTitleEditCell() {
        tableView.beginUpdates()
        
        removeSection(with: "titleSection")
        
        tableView.deleteSections(IndexSet(arrayLiteral: 0), with: .top)
        
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
