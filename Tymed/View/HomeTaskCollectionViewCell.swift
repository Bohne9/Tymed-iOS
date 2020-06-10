//
//  HomeTaskCollectionViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 27.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit
let homeTaskCell = "homeTaskCell"
class HomeTaskCollectionViewCell: HomeBaseCollectionViewCell {
    
    static func register(_ collectionView: UICollectionView) {
        collectionView.register(HomeLessonCollectionViewCell.self, forCellWithReuseIdentifier: homeLessonCell)
    }
    
    var task: Task? {
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
        addSubview(colorIndicator)
        
        colorIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        colorIndicator.backgroundColor = .label
        
        colorIndicator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        colorIndicator.topAnchor.constraint(equalTo: topAnchor, constant: 14).isActive = true
        colorIndicator.heightAnchor.constraint(equalToConstant: 20).isActive = true
        colorIndicator.widthAnchor.constraint(equalToConstant: 8).isActive = true
        
        colorIndicator.layer.cornerRadius = 3.5
        
        //MARK: name
        addSubview(name)
        
        name.translatesAutoresizingMaskIntoConstraints = false
        
        name.leadingAnchor.constraint(equalTo: colorIndicator.trailingAnchor, constant: 15).isActive = true
        name.topAnchor.constraint(equalTo: topAnchor, constant: 11).isActive = true
        name.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        name.widthAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        
        name.textColor = UIColor.label
        name.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        //MARK: time
        addSubview(time)
        
        time.translatesAutoresizingMaskIntoConstraints = false
        
        time.leadingAnchor.constraint(equalTo: name.leadingAnchor).isActive = true
        time.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 5).isActive = true
        time.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        time.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        time.textColor = .label
        
    }
    
    
    internal override func reload() {
        super.reload()
        
        guard let task = task else { return }
        
        name.text = task.title
        
        name.sizeToFit()
        
        time.text = task.due?.stringify(dateStyle: .short, timeStyle: .short)
//        time.text = "\(lesson.day.string()) \u{2022} \(lesson.startTime.string() ?? "") \u{2022} \(lesson.endTime.string() ?? "")"
        
        let color: UIColor? = UIColor(named: task.lesson?.subject?.color ?? "dark") ?? UIColor(named: "dark")

        colorIndicator.backgroundColor = color
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
