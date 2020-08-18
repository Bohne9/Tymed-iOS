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
    
    private func lesson(_ indexPath: IndexPath) -> Lesson? {
        return lessons[indexPath.row]
    }
    
    private func setupCollectionView() {
        HomeWeekLessonCollectionViewCell.register(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        
        collectionView.backgroundColor = .systemBackground
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lessons.count
    }
    
    private func dequeueLessonCell(for indexPath: IndexPath) -> HomeWeekLessonCollectionViewCell? {
        return collectionView.dequeueReusableCell(
            withReuseIdentifier: HomeWeekLessonCollectionViewCell.identifier,
            for: indexPath) as? HomeWeekLessonCollectionViewCell
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = dequeueLessonCell(for: indexPath) else {
            return UICollectionViewCell()
        }
        
        let lesson = lessons[indexPath.row]
        
        cell.lesson = lesson
        cell.reload()
        
        return cell
    }
    
    private func duration(of lesson: Lesson) -> Int {
        return Int(lesson.end - lesson.start)
    }
    
    private func heightRelativeToDuration(of lesson: Lesson) -> CGFloat {
        
        let duration = Double(self.duration(of: lesson)) * 0.75
        
        return CGFloat(max(25, duration))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let lesson = self.lesson(indexPath) else {
            return .zero
        }
        
        let height = heightRelativeToDuration(of: lesson)
        
        return CGSize(width: collectionView.frame.width - 40, height: height)
    }
    
}
