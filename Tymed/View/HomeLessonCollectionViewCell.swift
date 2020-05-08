//
//  HomeLessonCollectionViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 08.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

let homeLessonCell = "homeLessonCell"
class HomeLessonCollectionViewCell: UICollectionViewCell {
    
    var lesson: Lesson? {
        didSet {
            guard let lesson = lesson else { return }
            
            name.text = lesson.subject?.name
            
            time.text = "\(lesson.dayOfWeek?.dayToStringShort() ?? "") - \(lesson.startTime?.timeToString() ?? "") - \(lesson.endTime?.timeToString() ?? "")"
            
            let color: UIColor? = UIColor(named: lesson.subject?.color ?? "dark") ?? UIColor(named: "dark")

            backgroundColor = color
        }
    }
    
    var name = PaddingLabel()
    
    var time = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(name)
        
        backgroundColor = .systemGray6
        
        name.translatesAutoresizingMaskIntoConstraints = false
        
        name.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        name.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        name.heightAnchor.constraint(equalToConstant: 30).isActive = true
        name.widthAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        
        name.textColor = UIColor.white
        name.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        
        addSubview(time)
        
        time.translatesAutoresizingMaskIntoConstraints = false
        
        time.leadingAnchor.constraint(equalTo: name.leadingAnchor, constant: 0).isActive = true
        time.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 5).isActive = true
        time.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        time.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        time.textColor = .label
        
        layer.cornerRadius = 10
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
