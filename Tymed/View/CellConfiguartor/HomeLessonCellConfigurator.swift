//
//  HomeLessonCellConfigurator.swift
//  Tymed
//
//  Created by Jonah Schueller on 21.06.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class HomeLessonCellConfigurator: BaseCollectionViewCellConfigurator<HomeLessonCollectionViewCell> {
    
    private func constraintTimeLabelToTop(_ cell: HomeLessonCollectionViewCell) {
        cell.updateConstraints()
        cell.timeBottomConstraint?.isActive = false
        cell.timeTopConstraint?.isActive = true
        
    }
    
    private func constraintTimeLabelToBottom(_ cell: HomeLessonCollectionViewCell) {
        cell.updateConstraints()
        cell.timeTopConstraint?.isActive = false
        cell.timeBottomConstraint?.isActive = true
        
    }
    
    override func configure(_ cell: HomeLessonCollectionViewCell) {
        guard cell.lesson != nil else {
            return
        }
        
        // If the lesson has any tasks attached
//        if lesson.unarchivedTasks?.count ?? 0 > 0 {
//            constraintTimeLabelToBottom(cell)
//            cell.backgroundColor = cell.backgroundColor?.withAlphaComponent(0.3)
//            let cl = UIColor(lesson)
//            cell.name.textColor = cl
//            cell.time.textColor = cl
//            cell.tasksLabel.textColor = cl
//            cell.tasksImage.tintColor = cl
//        }else {
        constraintTimeLabelToTop(cell)
//        }
        
    }
    
    static func height(for lesson: Lesson?) -> CGFloat {
        
        if lesson?.unarchivedTasks?.count ?? 0 > 0 {
            return 65
        }else {
            return 45
        }
    }
    
}
