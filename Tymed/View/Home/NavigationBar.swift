//
//  NavigationBar.swift
//  Tymed
//
//  Created by Jonah Schueller on 27.04.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class NavigationBar: UINavigationBar, UINavigationBarDelegate {

    let topBar = HomeTopBar()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prefersLargeTitles = false
        isTranslucent = false
        
        backgroundColor = .systemBackground
        
        addSubview(topBar)
        
        barTintColor = .systemBackground

        topBar.translatesAutoresizingMaskIntoConstraints = false
        topBar.backgroundColor = .systemBackground
        
        topBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
//        topBar.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12).isActive = true
        topBar.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.95).isActive = true
        topBar.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        topBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        shadowImage = UIImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
