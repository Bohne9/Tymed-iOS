//
//  TaskArchiveTableViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 27.07.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class TaskArchiveTableViewCell: BaseTableViewCell {

    static let identifier = "taskArchiveTableViewCell"
    
    var task: Task? {
        didSet {
            switchBtn.isOn = task?.archived ?? false
        }
    }
    
    var switchBtn = UISwitch()
    var label = UILabel()
    
    override func setup() {
        super.setup()
        
        contentView.addSubview(switchBtn)
        contentView.addSubview(label)
        
        switchBtn.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.constraintLeadingToSuperview(constant: 20)
        label.constraintHeightToSuperview()
        label.constraintTrailingTo(anchor: contentView.centerXAnchor, constant: 0)
        label.constraintCenterYToSuperview(constant: 0)
        
        switchBtn.constraintTrailingToSuperview(constant: 20)
        switchBtn.constraintCenterYToSuperview(constant: 0)
        
        label.text = "Archive"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        switchBtn.addTarget(self, action: #selector(onToggleArchive(_:)), for: .valueChanged)
    }
    
    @objc func onToggleArchive(_ sender: UISwitch) {
        task?.archived = sender.isOn
        TimetableService.shared.save()
    }
}
