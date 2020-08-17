//
//  HomeWeekDayCollectionViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 17.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

private let lessonCell = "lessonCell"

class HomeWeekDayCollectionViewCell: UICollectionViewCell, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    static let identifier = "HomeWeekDayCollectionViewCell"
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    var lessons: [Lesson] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .red
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.constraintToSuperview()
        
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.register(HomeWeekLessonCollectionViewCell.self, forCellWithReuseIdentifier: lessonCell)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lessons.count
    }
    
    private func dequeueLessonCell(for indexPath: IndexPath) -> HomeLessonCollectionViewCell? {
        return collectionView.dequeueReusableCell(withReuseIdentifier: lessonCell, for: indexPath) as? HomeLessonCollectionViewCell
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = dequeueLessonCell(for: indexPath) else {
            return UICollectionViewCell()
        }
        
        let lesson = lessons[indexPath.row]
        
        cell.tasksImage.isHidden = true
        cell.tasksLabel.isHidden = true
        cell.lesson = lesson
        cell.reload()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 40, height: 45)
    }
    
}
