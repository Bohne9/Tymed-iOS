//
//  TaskAttachedLessonTableViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 25.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class TaskAttachedLessonTableViewCell: UITableViewCell {

    var colorIndicator = UIView()
    
    var name = PaddingLabel()
    
    var time = UILabel()
    
    var lesson: Lesson?
    
    var removeBtn = UIButton()
    
    internal var tasksImage: UIImageView!
    var tasksLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUserInterface()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func setupUserInterface() {
        
        //MARK: colorIndicator
        addSubview(colorIndicator)
        
        colorIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        colorIndicator.backgroundColor = .label
        
        colorIndicator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        colorIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        colorIndicator.heightAnchor.constraint(equalToConstant: 10).isActive = true
        colorIndicator.widthAnchor.constraint(equalToConstant: 10).isActive = true
        
        colorIndicator.layer.cornerRadius = 5
        
        //MARK: name
        addSubview(name)
        
        name.translatesAutoresizingMaskIntoConstraints = false
        
        name.leadingAnchor.constraint(equalTo: colorIndicator.trailingAnchor, constant: 15).isActive = true
        name.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        name.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        name.widthAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        
        name.textColor = UIColor.label
        name.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        addSubview(removeBtn)
        
        removeBtn.translatesAutoresizingMaskIntoConstraints = false

        removeBtn.setImage(UIImage(systemName: "trash"), for: .normal)
        
        removeBtn.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
        removeBtn.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        removeBtn.heightAnchor.constraint(equalToConstant: 20).isActive = true
        removeBtn.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        //MARK: time
        addSubview(time)
        
        time.translatesAutoresizingMaskIntoConstraints = false
        
        time.trailingAnchor.constraint(equalTo: removeBtn.leadingAnchor, constant: -15).isActive = true
        time.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        time.leadingAnchor.constraint(equalTo: centerXAnchor).isActive = true
        time.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        time.textAlignment = .right
        
        time.adjustsFontSizeToFitWidth = true
        
        time.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        time.textColor = .label
        
        
    }
    
    func setLesson(_ lesson: Lesson?) {
        guard let lesson = lesson else {
            return
        }
        
        self.lesson = lesson
        
        name.text = lesson.subject?.name
        
        name.sizeToFit()
        
        time.text = "\(lesson.day.shortString()) \u{2022} \(lesson.startTime.string() ?? "") \u{2022} \(lesson.endTime.string() ?? "")"
        
        let color: UIColor? = UIColor(named: lesson.subject?.color ?? "dark") ?? UIColor(named: "dark")

        colorIndicator.backgroundColor = color
    }
}
