//
//  CalendarDayView.swift
//  Tymed
//
//  Created by Jonah Schueller on 30.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

struct CalendarDayView: UIViewControllerRepresentable {
    typealias UIViewControllerType = HomeWeekCollectionView
    
    func makeUIViewController(context: Context) -> HomeWeekCollectionView {
        let homeViewController = HomeWeekCollectionView()
        
        homeViewController.reloadData()
        
        return homeViewController
    }
    
    func updateUIViewController(_ uiViewController: HomeWeekCollectionView, context: Context) {
        
    }
}
