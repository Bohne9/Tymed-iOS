//
//  NavigationBar.swift
//  Tymed
//
//  Created by Jonah Schueller on 27.04.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit
import SwiftUI

class NavigationBar: UINavigationBar, UINavigationBarDelegate {

    let topBar = HomeTopBar()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prefersLargeTitles = false
        isTranslucent = false
        
        addSubview(topBar)
        
        topBar.translatesAutoresizingMaskIntoConstraints = false
        topBar.backgroundColor = .systemGroupedBackground
        
        topBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        topBar.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12).isActive = true
        topBar.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        topBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        shadowImage = UIImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
