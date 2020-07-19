//
//  HomeDashTaskSelectorCollectionViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 07.07.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

enum HomeDashTaskSelectorCellType : Int {
    
    case today = 0
    case done = 1
    case all = 2
    case expired = 3
    case archived = 4
    case open = 5
    case planned = 6
    
    var title: String {
        switch self {
        case .today:    return "Today"
        case .done:     return "Done"
        case .all:      return "All"
        case .expired:  return "Expired"
        case .open:     return "Open"
        case .archived: return "Archived"
        case .planned:  return "Planned"
        }
    }
    
    var systemIcon: String {
        switch self {
        case .today:    return "calendar"
        case .done:     return "checkmark.circle.fill"
        case .all:      return "tray.fill"
        case .expired:  return "exclamationmark.circle.fill"
        case .open:     return "circle"
        case .archived: return "tray.full.fill"
        case .planned:  return "calendar.badge.clock"
        }
    }
    
    var color: UIColor {
        switch self {
        case .today:    return .systemBlue
        case .done:     return .systemGreen
        case .all:      return .systemGray
        case .expired:  return .systemRed
        case .open:     return .systemBlue
        case .archived: return .systemGray
        case .planned:  return .systemOrange
        }
    }
}

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
        
        contentView.layer.cornerRadius = 10
        
        contentView.backgroundColor = .secondarySystemGroupedBackground
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 10
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.15
        
        layer.masksToBounds = false
        
        label.translatesAutoresizingMaskIntoConstraints = false
        image.translatesAutoresizingMaskIntoConstraints = false
        selectedIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        image.constraintCenterYToSuperview(constant: 0)
        image.constraintLeadingToSuperview(constant: 20)
        image.constraint(width: 30, height: 30)
        image.contentMode = .scaleAspectFit
        
        label.constraintCenterYToSuperview(constant: 0)
        label.constraintLeadingTo(anchor: image.trailingAnchor, constant: 10)
        label.constraintTrailingTo(anchor: selectedIndicator.leadingAnchor, constant: 10)
        label.constraint(height: 40)
        
        selectedIndicator.constraintCenterYToSuperview(constant: 0)
        selectedIndicator.constraintTrailingToSuperview(constant: 20)
        selectedIndicator.constraint(width: 20, height: 20)
    
        label.font = .systemFont(ofSize: 16, weight: .bold)
        selectedIndicator.tintColor = .systemBlue
        
        
    }
    
}
