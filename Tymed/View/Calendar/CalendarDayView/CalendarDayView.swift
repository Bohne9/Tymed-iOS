//
//  CalendarDayView.swift
//  Tymed
//
//  Created by Jonah Schueller on 30.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

struct CalendarDayView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = CalendarCollectionViewController
    
    class Coordinator: CalendarCollectionViewControllerDelegate {
        
        var calendarView: CalendarDayView
        
        internal init(_ calendarView: CalendarDayView) {
            self.calendarView = calendarView
        }
        
        func didReloadCollectionView(_ view: CalendarCollectionViewController) {
            
        }
        
        func scrollTo(_ date: Date) {
            
        }
        
        func didScrollTo(_ view: CalendarCollectionViewController, date: Date) {
            calendarView.calendarViewModel.currentDate = date
            
        }
        
    }
    
    @EnvironmentObject
    var calendarViewModel: CalendarViewModel
    
    func makeUIViewController(context: Context) -> CalendarCollectionViewController {
        let calendarViewController = CalendarCollectionViewController()
        
        calendarViewController.reloadData()
        
        calendarViewController.calendarDelegate = context.coordinator
        
        return calendarViewController
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func updateUIViewController(_ uiViewController: CalendarCollectionViewController, context: Context) {
        uiViewController.scrollTo(date: calendarViewModel.currentDate, animated: true, silent: true)
    }
    
}
