//
//  HomeViewSceneDelegate.swift
//  Tymed
//
//  Created by Jonah Schueller on 25.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

protocol HomeViewSceneDelegate {

    func present(_ viewController: UIViewController, animated: Bool)
    
    func presentLessonEditView(for lesson: Lesson)
    
    func presentTaskEditView(for task: Task)
    
    func presentTaskAddView()
    
    func presentLessonAddView()
    
    func dismiss(_ animated: Bool)
    
    func reload()
    
}

extension HomeViewSceneDelegate {
    
    func presentLessonEditView(for lesson: Lesson) {
        
        let lessonView = LessonEditViewWrapper()
        lessonView.lesson = lesson
        
        present(lessonView, animated: true)
    }
    
    func presentTaskEditView(for task: Task) {
        let taskView = TaskEditViewWrapper()
        taskView.task = task
        
        present(taskView, animated: true)
    }
    
    func presentTaskAddView() {
        let taskAdd = TaskAddViewWrapper()
        
        present(taskAdd, animated: true)
    }
    
    func presentLessonAddView() {
        let lessonAdd = LessonAddViewWrapper()
        
        present(lessonAdd, animated: true)
    }
    
}
