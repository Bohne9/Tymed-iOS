//
//  HomeBaseCollectionViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 16.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class HomeBaseCollectionViewCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUserInterface()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    internal func setupUserInterface() {
        
        layer.cornerRadius = 8
        backgroundColor = .secondarySystemGroupedBackground
    }
 
    internal func reload() {
        
    }
}
