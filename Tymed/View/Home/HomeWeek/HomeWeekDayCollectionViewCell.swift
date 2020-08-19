//
//  HomeWeekDayCollectionViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 17.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

private let lessonCell = "lessonCell"

//MARK: HomeWeekDayCollectionViewCell
class HomeWeekDayCollectionViewCell: UICollectionViewCell, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    static let identifier = "HomeWeekDayCollectionViewCell"
    
    /// CollectionView to display the day items
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    /// Delegate for displaying LessonEditView etc.
    var lessonDelegate: HomeCollectionViewDelegate?
    
    /// List of lessons of the day
    var lessons: [Lesson] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: setupView
    private func setupView() {
        // Add the collectionView to the cell
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.constraintToSuperview()
        
        setupCollectionView()
    }
    
    //MARK: setupCollectionView
    private func setupCollectionView() {
        // Register the HomeWeekLesson cell
        HomeWeekLessonCollectionViewCell.register(collectionView)
        
        // Set delegate + dataSource
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Set content insets
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        
        // Set background color
        collectionView.backgroundColor = .systemBackground
    }
    
    //MARK: lesson(for: UUID)
    /// Returns the lesson for a given uuid
    /// - Parameter uuid: UUID of the lesson
    /// - Returns: Lesson with the given uuid. Nil if lesson does not exist in lessons list.
    private func lesson(for uuid: UUID) -> Lesson? {
        return lessons.filter { return $0.id == uuid }.first
    }
    
    //MARK: lesson(_: IndexPath)
    private func lesson(_ indexPath: IndexPath) -> Lesson? {
        return lessons[indexPath.row]
    }

    //MARK: - DataSource
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
    
    //MARK: didSelectItem
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let lesson = self.lesson(indexPath) else {
            return
        }
        // Present a LessonEditView when a lesson cell is selected
        lessonDelegate?.lessonDetail(collectionView, for: lesson)
    }

    //MARK: cellForItemAt
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = dequeueLessonCell(for: indexPath) else {
            return UICollectionViewCell()
        }
        // Get lesson for the row
        let lesson = lessons[indexPath.row]
        
        // Set cell lesson and reload UI of the cell
        cell.lesson = lesson
        cell.reload()
        
        return cell
    }
    //MARK: duration(of: Lesson)
    private func duration(of lesson: Lesson) -> Int {
        return Int(lesson.end - lesson.start)
    }
    
    //MARK: heightRelativeToDuration(of: Lesson)
    /// Calculates the height for a lesson cell relative to the duration of the lesson
    /// Minimum cell height is 25. The formula is: d * 0.75, where d is the duration of the lesson in minutes.
    /// - Parameter lesson: Lesson whichs height will be calculated
    /// - Returns: Height for a lesson cell relative to the duration of the lesson (min: 25)
    private func heightRelativeToDuration(of lesson: Lesson) -> CGFloat {
        
        let duration = Double(self.duration(of: lesson)) * 0.75
        
        return CGFloat(max(25, duration))
    }
    
    //MARK: sizeForItemAt
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let lesson = self.lesson(indexPath) else {
            return .zero
        }
        
        let height = heightRelativeToDuration(of: lesson)
        
        return CGSize(width: collectionView.frame.width - 40, height: height)
    }
    
    //MARK: - ContextMenu/-Content
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
            
            let lesson = self.lesson(indexPath)
            
            guard let uuid = lesson?.id else {
                return nil
            }
            
            let config = UIContextMenuConfiguration(identifier: uuid as NSUUID, previewProvider: { () -> UIViewController? in
                
                let lessonDetail = LessonEditViewWrapper()
                
                lessonDetail.lesson = lesson
                
                return lessonDetail
            }) { (elements) -> UIMenu? in
                
                let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash")) { (action) in
                    
                    guard let lesson = self.lesson(indexPath) else {
                        return
                    }
                    
                    TimetableService.shared.deleteLesson(lesson)
                    
                    self.lessonDelegate?.lessonDidDelete(self.collectionView, lesson: lesson)
                    
                }
                
                return UIMenu(title: "", image: nil, children: [delete])
            }
            
            return config
        }
        
        func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
            
            guard let id = (configuration.identifier as? NSUUID) as UUID? else {
                return
            }
            
            animator.addCompletion {
                guard let lesson = self.lesson(for: id) else {
                    return
                }
                
                self.lessonDelegate?.lessonDetail(self.collectionView, for: lesson)
            }
        }
}
