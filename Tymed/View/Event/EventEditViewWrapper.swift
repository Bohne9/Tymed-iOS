//
//  EventEditViewWrapper.swift
//  Tymed
//
//  Created by Jonah Schueller on 20.10.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI
import EventKit
import EventKitUI

struct EventEditViewWrapper: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = EKEventEditViewController
    
    
    func makeUIViewController(context: Context) -> EKEventEditViewController {
        
        let viewController = EKEventEditViewController()
        
        viewController.eventStore = EventService.shared.eventStore
        viewController.event = EventService.shared.addEvent()
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {
        
    }
    
    
}
