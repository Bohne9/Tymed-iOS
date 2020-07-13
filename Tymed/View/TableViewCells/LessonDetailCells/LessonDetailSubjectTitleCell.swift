//
//  LessonDetailSubjectTitleCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 02.07.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class LessonDetailSubjectTitleCell: UITableViewCell {
    
    static let lessonDetailSubjectTitleCell = "lessonDetailSubjectTitleCell"
    
    var titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        contentView.backgroundColor = .systemGroupedBackground
        backgroundColor = .systemGroupedBackground
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        
        titleLabel.text = "Hallo"
    }
 
    func reload(_ lesson: Lesson?) {
        
        guard let lesson = lesson else {
            return
        }
        
        titleLabel.text = lesson.subject?.name
    }
}
