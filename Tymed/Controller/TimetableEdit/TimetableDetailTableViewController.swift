//
//  TimetableDetailTableViewController.swift
//  Tymed
//
//  Created by Jonah Schueller on 22.07.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

private let deleteCell = "deleteCell"

class TimetableDetailTableViewController: TimetableAddViewController {

    var timetableDeletionDelegate: TimetableOverviewDeleteDelegate?
    
    override func setupNavigationBar() {
        
        title = "Timetable"
        
        navigationController?.navigationBar.prefersLargeTitles = false
        
    }
    
    override func setup() {
        super.setup()
        
        register(TimetableDetailDeleteTableViewCell.self, identifier: deleteCell)
        
        addSection(with: "deletion")
        addCell(with: deleteCell, at: "deletion")
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
