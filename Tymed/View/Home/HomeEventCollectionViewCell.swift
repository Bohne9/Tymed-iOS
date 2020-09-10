//
//  HomeEventCollectionViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 10.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class HomeEventCollectionViewCell: HomeBaseCollectionViewCell {
    static func register(_ collectionView: UICollectionView) {
        collectionView.register(HomeLessonCollectionViewCell.self, forCellWithReuseIdentifier: homeLessonCell)
    }
    
    var event: Event? {
        didSet {
            reload()
        }
    }
    
    var name = PaddingLabel()
    
    var time = UILabel()
    
    
    internal override func setupUserInterface() {
        super.setupUserInterface()
        
        //MARK: name
        contentView.addSubview(name)
        name.translatesAutoresizingMaskIntoConstraints = false
        
        name.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        name.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        name.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        name.widthAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        
        name.textColor = .white
        name.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        //MARK: time
        contentView.addSubview(time)
        
        time.translatesAutoresizingMaskIntoConstraints = false
        
        time.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        
        // Setup two constraints for different cells
        time.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        
        time.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        time.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        
        time.textColor = .white
        name.textColor = .white
        
    }
    
    
    internal override func reload() {
        super.reload()
        
        guard let event = event else { return }
        
        name.text = event.title
        
        name.sizeToFit()
        
//        time.text = "\(vev.day.shortString()) \u{2022} \(lesson.startTime.string() ?? "") - \(lesson.endTime.string() ?? "")"

        backgroundColor = UIColor(event)?.withAlphaComponent(0.6)
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
