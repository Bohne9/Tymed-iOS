//
//  HomeCollectionViewHeader.swift
//  Tymed
//
//  Created by Jonah Schueller on 15.07.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

//MARK: HomeCollectionViewHeader
class HomeCollectionViewHeader: UICollectionReusableView  {
    
    var label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    internal func setup() {
        addSubview(label)
                
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.constraint(height: 20)
        label.constraintLeadingToSuperview(constant: 10)
        label.constraintTrailingTo(anchor: centerXAnchor)
        label.constraintBottomToSuperview(constant: 7.5)
        
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

