//
//  LessonDetailDeleteCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 29.06.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

//MARK: LessonDetailDeleteCell
class LessonDetailDeleteCell: UITableViewCell {
    
    let deleteButton = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        
        setupView()
    }
    
    private func setupView() {
        
        addSubview(deleteButton)
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setTitle("Delete", for: .normal)
        
        deleteButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        deleteButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        deleteButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
        deleteButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        deleteButton.setTitleColor(.red, for: .normal)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
