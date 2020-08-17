//
//  HomeWeekDayCollectionViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 17.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class HomeWeekDayCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "HomeWeekDayCollectionViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .red
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
