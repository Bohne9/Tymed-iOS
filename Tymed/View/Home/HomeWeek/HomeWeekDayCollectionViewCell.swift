//
//  HomeWeekDayCollectionViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 17.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit
import SwiftUI

private let lessonCell = "lessonCell"

//MARK: HomeWeekDayCollectionViewCell
class HomeWeekDayCollectionViewCell: UICollectionViewCell, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    static let identifier = "HomeWeekDayCollectionViewCell"
    
    /// CollectionView to display the day items
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    /// Delegate for displaying LessonEditView etc.
    var homeDelegate: HomeViewSceneDelegate?
    
    /// CalendarDayEntry for the cell
    var entry: CalendarDayEntry? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var calendarCellSupplier = HomeCalendarCollectionViewCellSupplier()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reload() {
        collectionView.reloadData()
    }
    
    //MARK: setupView
    private func setupView() {
        calendarCellSupplier.collectionView = collectionView
        
        backgroundColor = .systemGroupedBackground
        
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
        HomeEventCollectionViewCell.register(collectionView)
        
        // Set delegate + dataSource
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Set drag & drop delegate
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        
        // Enable drag interaction for the collectionView
        collectionView.dragInteractionEnabled = true
        
        // Set content insets
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        
        // Set background color
        collectionView.backgroundColor = .systemGroupedBackground
    }
    
    func events() -> [CalendarEvent] {
        return entry?.entries ?? []
    }
    
    //MARK: lesson(for: UUID)
    /// Returns the lesson for a given uuid
    /// - Parameter uuid: UUID of the lesson
    /// - Returns: Lesson with the given uuid. Nil if lesson does not exist in lessons list.
    private func event(for uuid: UUID) -> CalendarEvent? {
        return events().filter { return $0.id == uuid }.first
    }
    
    //MARK: lesson(_: IndexPath)
    private func event(_ indexPath: IndexPath) -> CalendarEvent? {
        return events()[indexPath.row]
    }

    //MARK: - DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events().count
    }
    
    private func dequeueLessonCell(for indexPath: IndexPath) -> HomeWeekLessonCollectionViewCell? {
        return collectionView.dequeueReusableCell(
            withReuseIdentifier: HomeWeekLessonCollectionViewCell.identifier,
            for: indexPath) as? HomeWeekLessonCollectionViewCell
    }
    
    private func presentDetail(_ indexPath: IndexPath) {
        guard let calendarEvent = self.event(indexPath) else {
            return
        }
        
        if let lesson = calendarEvent.asLesson {
            homeDelegate?.presentLessonEditView(for: lesson)
        }else if let event = calendarEvent.asEvent {
            homeDelegate?.presentEventEditView(for: event)
        }
        
    }
    
    //MARK: didSelectItem
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presentDetail(indexPath)
    }

    //MARK: cellForItemAt
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Get event for the row
        let event = self.event(indexPath)
        
        calendarCellSupplier.indexPath = indexPath
        
        if let cell = calendarCellSupplier.get(for: indexPath, event: event) {
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    //MARK: duration(of: Lesson)
    private func duration(of event: CalendarEvent) -> Int {
        guard let start = event.startDate, let end = event.endDate else {
            return 0
        }
        
        return Int(end.timeIntervalSince(start))
    }
    
    //MARK: heightRelativeToDuration(of: Lesson)
    /// Calculates the height for a lesson cell relative to the duration of the lesson
    /// Minimum cell height is 25. The formula is: d * 0.75, where d is the duration of the lesson in minutes.
    /// - Parameter lesson: Lesson whichs height will be calculated
    /// - Returns: Height for a lesson cell relative to the duration of the lesson (min: 25)
    private func heightRelativeToDuration(of event: CalendarEvent) -> CGFloat {
        
        let duration = Double(self.duration(of: event) / 60) * 0.75
        
        return CGFloat(max(25, duration))
    }
    
    //MARK: sizeForItemAt
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let event = self.event(indexPath) else {
            return .zero
        }
        
        let height = heightRelativeToDuration(of: event)
        
        return CGSize(width: collectionView.frame.width - 40, height: height)
    }
    
    //MARK: - ContextMenu/-Content
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        // Get the lesson for the context menu
        guard let event = self.event(indexPath) else {
            return nil
        }
        
        guard let lesson = event.asLesson else {
            return nil
        }
            
        // Extract the id of the lesson
        guard let uuid = lesson.id else {
            return nil
        }
            
        // Create a context menu configuration
        let config = UIContextMenuConfiguration(identifier: uuid as NSUUID, previewProvider: { () -> UIViewController? in
            
            // ViewController to give the user a preview of the lessonEditView
            let lessonEdit = UIHostingController(
                rootView: LessonEditContentView(lesson: lesson, dismiss: { }))
            
            return lessonEdit
        }) { (elements) -> UIMenu? in
            // Provide a menu for the context menu
            
            // Delete button for the context menu
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash")) { (action) in
                // Get the lesson of the context menu
                guard let event = self.event(indexPath) else {
                    return
                }
                
                guard let lesson = event.asLesson else {
                    return
                }
                
                // Remove the lesson
                TimetableService.shared.deleteLesson(lesson)
                
                // Call delegate to reload the home scene
                self.homeDelegate?.presentLessonEditView(for: lesson)
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
            guard let event = self.event(for: id) else {
                return
            }
            
            guard let lesson = event.asLesson else {
                return
            }
            
            self.homeDelegate?.presentLessonEditView(for: lesson)
        }
    }
}


//MARK: - Drag & Drop
extension HomeWeekDayCollectionViewCell: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let item = event(indexPath) else {
            return []
        }
        
        guard let id = (item.id?.uuidString ?? "") else {
            return []
        }
        
        let itemProvider = NSItemProvider(object: id as NSString)
        
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
}

extension HomeWeekDayCollectionViewCell: UICollectionViewDropDelegate {
    
    func updateLesson(_ lesson: Lesson, destinationIndexPath: IndexPath) {
//        lesson.dayOfWeek = Int32(weekDays[destinationIndexPath.section].rawValue)
//        TimetableService.shared.save()
    }
    
    func reorderItems(coordinator: UICollectionViewDropCoordinator, destination: IndexPath, _ collectionView: UICollectionView) {
        guard let dragItem = coordinator.items.first,
              let first = dragItem.dragItem.localObject as? Lesson,
              let source = dragItem.sourceIndexPath else {
            return
        }
        
        collectionView.performBatchUpdates ({
            #warning("Fix HomeWeekDayCollectionView drop reordering!")
//            lessons().remove(at: source.row)
//            lessons.insert(first, at: destination.row)
            
            updateLesson(first, destinationIndexPath: destination)
            
            collectionView.deleteItems(at: [source])
            collectionView.insertItems(at: [destination])
        }, completion: nil)
        collectionView.reloadData()
        
        coordinator.drop(dragItem.dragItem, toItemAt: destination)

    }
    
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        
        var destinationIndexPath: IndexPath
        
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        }else {
            destinationIndexPath = IndexPath(row: 0, section: 0)
        }
        
        if coordinator.proposal.operation == .move {
            reorderItems(coordinator: coordinator, destination: destinationIndexPath, collectionView)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
    
    
}
