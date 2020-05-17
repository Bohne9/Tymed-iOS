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
        colorIndicator.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        colorIndicator.heightAnchor.constraint(equalToConstant: 20).isActive = true
        colorIndicator.widthAnchor.constraint(equalToConstant: 7).isActive = true
        
        colorIndicator.layer.cornerRadius = 3.5
        
        //MARK: name
        addSubview(name)
        
        name.translatesAutoresizingMaskIntoConstraints = false
        
        name.leadingAnchor.constraint(equalTo: colorIndicator.trailingAnchor, constant: 15).isActive = true
        name.topAnchor.constraint(equalTo: topAnchor, constant: 6).isActive = true
        name.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        name.widthAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        
        name.textColor = UIColor.label
        name.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        
        //MARK: time
        addSubview(time)
        
        time.translatesAutoresizingMaskIntoConstraints = false
        
        time.leadingAnchor.constraint(equalTo: name.leadingAnchor).isActive = true
        time.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 5).isActive = true
        time.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        time.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        time.textColor = .label
        
        let image = UIImage(systemName: "list.dash")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold))
        let imageView = UIImageView(image: image)
        imageView.tintColor = .label
        
        addSubview(tasksLabel)
        
        tasksLabel.text = "5"
        
        addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        tasksLabel.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.leadingAnchor.constraint(equalTo: name.leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 17).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 17).isActive = true
        
        tasksLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 5).isActive = true
        tasksLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        tasksLabel.widthAnchor.constraint(equalToConstant: 15).isActive = true
        tasksLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        tasksLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
    }
    
   
    
    internal override func reload() {
        super.reload()
        
        guard let lesson = lesson else { return }
        
        name.text = lesson.subject?.name
        
        name.sizeToFit()
        
        time.text = "\(lesson.day.string()) - \(lesson.startTime.string() ?? "") - \(lesson.endTime.string() ?? "")"
        
        let color: UIColor? = UIColor(named: lesson.subject?.color ?? "dark") ?? UIColor(named: "dark")

        colorIndicator.backgroundColor = color
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
