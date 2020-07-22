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
        
        deleteButton.addTarget(self, action: #selector(onDelete), for: .touchUpInside)
    }
    
    @objc func onDelete() {
        guard let timetable = self.timetable else {
            return
        }
        
        timetableDeletionDelgate?.requestForDeletion(of: timetable)
        timetableDeletionDelgate?.popNavigationViewController()
        
    }
}
