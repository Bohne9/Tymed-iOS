//
//  HomeWeekLessonCollectionViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 18.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//


import UIKit

class HomeWeekLessonCollectionViewCell: HomeBaseCollectionViewCell {

    static let identifier = "homeWeekLessonCollectionViewCell"
    
    static func register(_ collectionView: UICollectionView) {
        collectionView.register(HomeWeekLessonCollectionViewCell.self, forCellWithReuseIdentifier: identifier)
    }
    
    var lesson: Lesson? {
        didSet {
            reload()
        }
    }
    
    var configurator = HomeLessonCellConfigurator()
    
    var name = PaddingLabel()
    
    var time = UILabel()
    
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
        name.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        name.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        name.widthAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        
        name.textColor = .white
        name.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        //MARK: time
        addSubview(time)
        
        time.translatesAutoresizingMaskIntoConstraints = false
        
        time.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        
        // Setup two constraints for different cells
        time.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        
        time.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        time.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        
        time.textColor = .white
        name.textColor = .white
        
    }
    
    internal override func reload() {
        super.reload()
        
        guard let lesson = lesson else { return }
        
        name.text = lesson.subject?.name
        
        name.sizeToFit()
        
        time.text = "\(lesson.startTime.string() ?? "") - \(lesson.endTime.string() ?? "")"

        backgroundColor = UIColor(lesson)
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
