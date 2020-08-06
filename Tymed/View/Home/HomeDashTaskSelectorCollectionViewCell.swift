//
//  HomeDashTaskSelectorCollectionViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 07.07.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class HomeDashTaskSelectorCollectionViewCell: UICollectionViewCell {
    
    let label = UILabel()
    let image = UIImageView()
    let selectedIndicator = UIImageView()
    
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
        contentView.addSubview(selectedIndicator)
        
        contentView.layer.cornerRadius = 8
        
        contentView.backgroundColor = .secondarySystemGroupedBackground
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 10
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.1
        
        layer.masksToBounds = false
        
        label.translatesAutoresizingMaskIntoConstraints = false
        image.translatesAutoresizingMaskIntoConstraints = false
        selectedIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        image.constraintCenterYToSuperview(constant: 0)
        image.constraintLeadingToSuperview(constant: 20)
        image.constraint(width: 25, height: 25)
        image.contentMode = .scaleAspectFit
        
        label.constraintCenterYToSuperview(constant: 0)
        label.constraintLeadingTo(anchor: image.trailingAnchor, constant: 10)
        label.constraintTrailingTo(anchor: selectedIndicator.leadingAnchor, constant: 10)
        label.constraint(height: 40)
        
        selectedIndicator.constraintCenterYToSuperview(constant: 0)
        selectedIndicator.constraintTrailingToSuperview(constant: 20)
        selectedIndicator.constraint(width: 20, height: 20)
    
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.adjustsFontSizeToFitWidth = true
        selectedIndicator.tintColor = .systemBlue
        
        
    }
    
}
