//
//  HomeDashTaskSelectorCollectionViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 07.07.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class HomeDashTaskSelectorCollectionViewCell: UICollectionViewCell {
    
    let button = UIButton(type: .roundedRect)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        contentView.addSubview(button)
        contentView.layer.cornerRadius = 10
        
        contentView.backgroundColor = .secondarySystemGroupedBackground
        layer.masksToBounds = false
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.constraintToSuperview(top: 10, bottom: 10, leading: 10, trailing: 10)
        
        button.setTitle("Today", for: .normal)
        button.setImage(UIImage(systemName: "calender"), for: .normal)
        
        
        button.backgroundColor = .tertiarySystemGroupedBackground
        
    }
    
    
}
