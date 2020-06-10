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
        }
    }
    
    var colorIndicator = UIView()
    
    var name = PaddingLabel()
    
    var time = UILabel()
    
    internal var tasksImage: UIImageView!
    var tasksLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUserInterface()
        
    }
    
    internal override func setupUserInterface() {
        super.setupUserInterface()
        
        //MARK: colorIndicator
//        addSubview(colorIndicator)
//
//        colorIndicator.translatesAutoresizingMaskIntoConstraints = false
//
//        colorIndicator.backgroundColor = .label
//
//        colorIndicator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
//        colorIndicator.topAnchor.constraint(equalTo: topAnchor, constant: 14).isActive = true
//        colorIndicator.heightAnchor.constraint(equalToConstant: 20).isActive = true
//        colorIndicator.widthAnchor.constraint(equalToConstant: 8).isActive = true
//
//        colorIndicator.layer.cornerRadius = 3.5
//
        //MARK: name
        addSubview(name)
        
        name.translatesAutoresizingMaskIntoConstraints = false
        
        name.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        name.topAnchor.constraint(equalTo: topAnchor, constant: 11).isActive = true
        name.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        name.widthAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        
        name.textColor = .white
        name.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        //MARK: time
        addSubview(time)
        
        time.translatesAutoresizingMaskIntoConstraints = false
        
        time.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        time.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        time.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        time.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        
        time.textColor = .white
        
        let image = UIImage(systemName: "list.dash")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold))
        tasksImage = UIImageView(image: image)
        tasksImage.tintColor = .label
        
        addSubview(tasksLabel)
        
        tasksLabel.text = "5"
        
        addSubview(tasksImage)
        
        tasksImage.translatesAutoresizingMaskIntoConstraints = false
        tasksLabel.translatesAutoresizingMaskIntoConstraints = false
        
        tasksImage.leadingAnchor.constraint(equalTo: name.leadingAnchor).isActive = true
        tasksImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        tasksImage.widthAnchor.constraint(equalToConstant: 17).isActive = true
        tasksImage.heightAnchor.constraint(equalToConstant: 17).isActive = true
        
        tasksLabel.leadingAnchor.constraint(equalTo: tasksImage.trailingAnchor, constant: 5).isActive = true
        tasksLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        tasksLabel.widthAnchor.constraint(equalToConstant: 15).isActive = true
        tasksLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        tasksLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        tasksImage.tintColor = .white
        tasksLabel.textColor = .white
        
    }
    
    
    internal override func reload() {
        super.reload()
        
        guard let lesson = lesson else { return }
        
        name.text = lesson.subject?.name
        
        name.sizeToFit()
        
        time.text = "\(lesson.day.shortString()) \u{2022} \(lesson.startTime.string() ?? "") - \(lesson.endTime.string() ?? "")"
        
        let color: UIColor? = UIColor(named: lesson.subject?.color ?? "dark") ?? UIColor(named: "dark")

        backgroundColor = color
        
        tasksLabel.text = "\(lesson.tasks?.count ?? 0)"
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
