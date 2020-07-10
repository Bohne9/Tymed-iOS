//
//  HomeDashTaskOverviewNoTasksCollectionViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 09.07.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class HomeDashTaskOverviewNoTasksCollectionViewCell: UICollectionViewCell {
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        contentView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.constraintToSuperview(top: 0, bottom: 0, leading: 0, trailing: 0)
        
        label.text = "No tasks"
        label.textAlignment = .center
        
        label.font = .boldSystemFont(ofSize: 16)
        
        contentView.backgroundColor = .secondarySystemGroupedBackground
        contentView.layer.cornerRadius = 10
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 10
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.15
        
        layer.masksToBounds = false
    }
    
    
}
