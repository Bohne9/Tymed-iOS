//
//  ViewWrapper.swift
//  Tymed
//
//  Created by Jonah Schueller on 26.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit
import SwiftUI


class ViewWrapperPresentationHandler: ObservableObject {

    @Published
    var shouldDismiss = true
    
    @Published
    var showDiscardWarning = false
    
}

protocol DetailViewPresentationDelegate {
    
    func dismiss()
    
    func cancel()
    
    func done()
    
    func shouldDismiss() -> Bool
}

class ViewWrapper<T: View>: UIViewController {
    
    var homeDelegate: HomeViewSceneDelegate?
    
    var hostingConroller: UIHostingController<T>?
    
    var presentationDelegate: DetailViewPresentationDelegate?
    
    var presentationHandler = ViewWrapperPresentationHandler()
    
    internal func createContent() -> UIHostingController<T>? {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presentationDelegate = self
        
        guard let contentView = createContent() else {
            return
        }
        
        hostingConroller = contentView
        
        addChild(contentView)
        view.addSubview(contentView.view)
        
        setupConstraints(contentView)
    }
    
    fileprivate func setupConstraints(_ contentView: UIHostingController<T>) {
        contentView.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.view.constraintToSuperview()
    }
    
}


extension ViewWrapper: DetailViewPresentationDelegate {
    
    /// Dismisses the view controller
    func dismiss() {
        homeDelegate?.dismiss(true)
    }
    
    /// Resets the core data model and dismisses the view controller
    func cancel() {
        TimetableService.shared.rollback()
        dismiss()
    }
    
    /// Saves the core data model and dismisses the view controller
    func done() {
        TimetableService.shared.save()
        homeDelegate?.reload()
        dismiss()
    }
    
    func shouldDismiss() -> Bool {
        return !TimetableService.shared.hasChanges()
    }
    
}
