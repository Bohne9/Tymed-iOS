//
//  TimetableDetailDeleteTableViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 22.07.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class TimetableDetailDeleteTableViewCell: BaseTableViewCell {

    var timetable: Timetable?
    var timetableDeletionDelgate: TimetableOverviewDeleteDelegate?
    
    let deleteButton = UIButton()
    
    override func setup() {
        super.setup()
        
        contentView.addSubview(deleteButton)
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        deleteButton.constraintToSuperview(top: 0, bottom: 0, leading: 0, trailing: 0)
        
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitleColor(.systemRed, for: .normal)
        
        deleteButton.addTarget(self, action: #selector(presentDeletionConformation(_:)), for: .touchUpInside)
    }
    
    func onDelete() {
        guard let timetable = self.timetable else {
            return
        }
        
        if timetableDeletionDelgate?.requestForDeletion(of: timetable) == true {
            timetableDeletionDelgate?.popNavigationViewController()
        }
        
    }
    
    @objc func presentDeletionConformation(_ sender: UIButton) {
        
        let action = UIAlertController(title: "Are you sure?", message: "You cannot undo this action. All associated tasks, subjects and lessons will be deleted aswell.", preferredStyle: .actionSheet)
        
        action.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (alert) in
            self.onDelete()
        }))
        
        action.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let popOver = action.popoverPresentationController {
            popOver.sourceView = sender
        }
        
        timetableDeletionDelgate?.present(action)
    }
    
}
