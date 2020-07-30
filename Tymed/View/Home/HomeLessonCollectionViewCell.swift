//
//  HomeLessonCollectionViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 08.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

let homeLessonCell = "homeLessonCell"
class HomeLessonCollectionViewCell: HomeBaseCollectionViewCell {
    
    static func register(_ collectionView: UICollectionView) {
        collectionView.register(HomeLessonCollectionViewCell.self, forCellWithReuseIdentifier: homeLessonCell)
    }
    
    var lesson: Lesson? {
        didSet {
            reload()
            configurator.configure(self)
        }
    }
    
    var configurator = HomeLessonCellConfigurator()
    
    var colorIndicator = UIView()
    
    var name = PaddingLabel()
    
    var time = UILabel()
    
    var tasksImage = UIImageView()
    var tasksLabel = UILabel()
    
    // Layout constraint for anchoring the time label to the top of the cell
    var timeTopConstraint: NSLayoutConstraint?
    var timeBottomConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUserInterface()
        
    }
    
    internal override func setupUserInterface() {
        super.setupUserInterface()
        
        //MARK: name
        addSubview(name)
        
        name.translatesAutoresizingMaskIntoConstraints = false
        
        name.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        name.topAnchor.constraint(equalTo: topAnchor, constant: 11).isActive = true
        name.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        name.widthAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        
        name.textColor = .white
        name.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        
        //MARK: time
        addSubview(time)
        
        time.translatesAutoresizingMaskIntoConstraints = false
        
        time.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        
        // Setup two constraints for different cells
        timeTopConstraint = time.topAnchor.constraint(equalTo: topAnchor, constant: 11)
        timeBottomConstraint = time.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        
        timeTopConstraint?.isActive = false
        timeBottomConstraint?.isActive = false
        
        time.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        time.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        
        time.textColor = .white
        name.textColor = .white
        
        setupTaskUserInterface()
        
    }
    
    private func setupTaskUserInterface() {
        
        // Make sure the lesson has tasks attached
        guard lesson?.unarchivedTasks?.count ?? 0 > 0 else {
            tasksImage.isHidden = true
            tasksLabel.isHidden = true
            return
        }
        tasksImage.isHidden = false
        tasksLabel.isHidden = false
        
        if tasksImage.superview == nil {
            let image = UIImage(systemName: "list.dash")?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold))
            tasksImage = UIImageView(image: image)
            tasksImage.tintColor = .label
            
            addSubview(tasksImage)
            
            tasksImage.translatesAutoresizingMaskIntoConstraints = false
            tasksLabel.translatesAutoresizingMaskIntoConstraints = false
            
            tasksImage.leadingAnchor.constraint(equalTo: name.leadingAnchor).isActive = true
            tasksImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
            tasksImage.widthAnchor.constraint(equalToConstant: 17).isActive = true
            tasksImage.heightAnchor.constraint(equalToConstant: 17).isActive = true
            
            tasksImage.tintColor = .white
            
        }
        
        if tasksLabel.superview == nil {
            
            addSubview(tasksLabel)
            
            tasksLabel.text = "-"
            
            tasksLabel.leadingAnchor.constraint(equalTo: tasksImage.trailingAnchor, constant: 5).isActive = true
            tasksLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
            tasksLabel.widthAnchor.constraint(equalToConstant: 15).isActive = true
            tasksLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
            
            tasksLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            
            tasksLabel.textColor = .white
        }
        
        
        
    }
    
    
    internal override func reload() {
        super.reload()
        
        guard let lesson = lesson else { return }
        
        setupTaskUserInterface()
        
        name.text = lesson.subject?.name
        
        name.sizeToFit()
        
        time.text = "\(lesson.day.shortString()) \u{2022} \(lesson.startTime.string() ?? "") - \(lesson.endTime.string() ?? "")"

        backgroundColor = UIColor(lesson)
        
        tasksLabel.text = "\(lesson.unarchivedTasks?.count ?? 0)"
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
