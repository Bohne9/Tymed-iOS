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
    
    func presentEventEditView(for event: Event)
    
    func dismiss(_ animated: Bool)
    
    func reload()
    
}

extension HomeViewSceneDelegate {
    
    func presentLessonEditView(for lesson: Lesson) {
        
        let lessonView = LessonEditViewWrapper()
        lessonView.lesson = lesson
        
        lessonView.homeDelegate = self
        
        present(lessonView, animated: true)
    }
    
    func presentTaskEditView(for task: Task) {
//        let taskView = TaskEditViewWrapper()
//        taskView.task = task
//        
//        taskView.homeDelegate = self
//        
//        present(taskView, animated: true)
    }
    
    func presentTaskAddView() {
        let taskAdd = TaskAddViewWrapper()
        
        taskAdd.homeDelegate = self
        
        present(taskAdd, animated: true)
    }
    
    func presentLessonAddView() {
        let lessonAdd = LessonAddViewWrapper()
        
        lessonAdd.homeDelegate = self
        
        present(lessonAdd, animated: true)
    }
    
    func presentEventEditView(for event: Event) {
//        let eventEdit = EventEditViewWrapper()
//        
//        eventEdit.event = event
//        
//        eventEdit.homeDelegate = self
//        
//        present(eventEdit, animated: true)
    }
    
}
