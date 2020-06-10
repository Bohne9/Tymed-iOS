//
//  HomeCollectionViewDelegate.swift
//  Tymed
//
//  Created by Jonah Schueller on 03.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import Foundation
import UIKit

protocol HomeCollectionViewDelegate {
    
    func lessonDetail(_ view: UIView, for lesson: Lesson)
    
    func taskDetail(_ view: UIView, for task: Task)
}

extension HomeCollectionViewDelegate {
    
    func lessonDetail(_ view: UIView, for lesson: Lesson) {
        
    }
    
    func taskDetail(_ view: UIView, for task: Task) {
        
    }
    
}
