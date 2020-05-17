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
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func setupUserInterface() {
        
        layer.cornerRadius = 10
        backgroundColor = .systemGroupedBackground
    }
 
    internal func reload() {
        
    }
}
