//
//  HomeDashTaskSelectorCollectionViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 07.07.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

enum HomeDashTaskSelectorCellType {
    
    case today
    case all
    case done
    case expired
    
}

class HomeDashTaskSelectorCollectionViewCell: UICollectionViewCell {
    
    let label = UILabel()
    let image = UIImageView()
    
    var type: HomeDashTaskSelectorCellType = .today {
        didSet {
            configurator.configure(self)
        }
    }
    
    var configurator = HomeDashTaskSelectorCellConfigurator()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        contentView.addSubview(label)
        contentView.addSubview(image)
        
        contentView.layer.cornerRadius = 10
        
        contentView.backgroundColor = .secondarySystemGroupedBackground
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 10
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.15
        
        layer.masksToBounds = false
        
        label.translatesAutoresizingMaskIntoConstraints = false
        image.translatesAutoresizingMaskIntoConstraints = false
        
        image.constraintCenterYToSuperview(constant: 0)
        image.constraintLeadingToSuperview(constant: 20)
        image.constraint(width: 30, height: 30)
        image.contentMode = .scaleAspectFit
        
        label.constraintCenterYToSuperview(constant: 0)
        label.constraintLeadingTo(anchor: image.trailingAnchor, constant: 10)
        label.constraintTrailingToSuperview(constant: 5)
        label.constraint(height: 40)
    
        label.font = .systemFont(ofSize: 16, weight: .bold)
    }
    
    
}
