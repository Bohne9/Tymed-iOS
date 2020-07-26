//
//  HomeDashTaskOverviewCollectionViewHeader.swift
//  Tymed
//
//  Created by Jonah Schueller on 25.07.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

enum TaskOverviewSectionSize {
    case collapsed
    case compact
    case large
    
    var image: UIImage? {
        return UIImage(systemName: imageName)
    }
    
    var imageName: String {
        switch self {
        case .collapsed: return "chevron.right"
        case .compact:   return "chevron.compact.down"
        case .large:     return "chevron.down"
        }
    }
    
    var maxItems: Int {
        switch self {
        case .collapsed:    return 0
        case .compact:      return 3
        case .large:        return Int.max
        }
    }
}

protocol TaskOverviewHeaderDelegate {
    
    func didToggle(_ header: HomeDashTaskOverviewCollectionViewHeader, identifier: String)
    
}

class HomeDashTaskOverviewCollectionViewHeader: HomeCollectionViewHeader {

    var sizeButton = UIButton()
    
    var size: TaskOverviewSectionSize = .compact
    
    var sectionIdentifier: String = ""
    
    var delegate: TaskOverviewHeaderDelegate?
    
    override func setup() {
        super.setup()
        
        addSubview(sizeButton)
        sizeButton.translatesAutoresizingMaskIntoConstraints = false
        
        sizeButton.constraintCenterYToSuperview(constant: 0)
        sizeButton.constraintTrailingToSuperview(constant: 5)
        sizeButton.constraint(width: 25, height: 25)
        
        let image = UIImage(systemName: "chevron.compact.down")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 21, weight: .semibold))
        
        sizeButton.setImage(image, for: .normal)
        sizeButton.tintColor = .secondaryLabel
        
        sizeButton.addTarget(self, action: #selector(toggleCollapse), for: .touchUpInside)
    }
    
    func toggleSize() {
        if size == .collapsed {
            size = .compact
        }else if size == .compact {
            size = .large
        }else {
            size = .collapsed
        }
    }
    
    func reload() {
        let image = size.image?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 21, weight: .semibold))

        print("Reload \(size.imageName)")
        UIView.transition(with: sizeButton, duration: 0.25, options: .transitionCrossDissolve) {
            self.sizeButton.setImage(image, for: .normal)
            self.delegate?.didToggle(self, identifier: self.sectionIdentifier)
        } completion: { (_) in
            
        }
    }
    
    @objc func toggleCollapse() {
        
        toggleSize()
        reload()
    }
}
