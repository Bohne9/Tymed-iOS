//
//  ViewWrapper.swift
//  Tymed
//
//  Created by Jonah Schueller on 26.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit
import SwiftUI

class ViewWrapper<T: View>: UIViewController {
    
    var homeDelegate: HomeViewSceneDelegate?
    
    var hostingConroller: UIHostingController<T>?
    
    internal func createContent() -> UIHostingController<T>? {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
