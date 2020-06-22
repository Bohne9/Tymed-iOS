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
        guard let lesson = cell.lesson else {
            return
        }
        
        // If the lesson has any tasks attached
        if lesson.tasks?.count ?? 0 > 0 {
            constraintTimeLabelToBottom(cell)
        }else {
            constraintTimeLabelToTop(cell)
        }
        
    }
    
    static func height(for lesson: Lesson?) -> CGFloat {
        
        if lesson?.tasks?.count ?? 0 > 0 {
            return 80
        }else {
            return 60
        }
    }
    
}
