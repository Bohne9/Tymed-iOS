//
//  NoTimetablesTableViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 20.07.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class NoTimetablesTableViewCell: UITableViewCell {

    var addButton = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        contentView.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.setTitle("Add your first timetable", for: .normal)
        
        addButton.constraintToSuperview(top: 0, bottom: 0, leading: 0, trailing: 0)
    }

    
}
