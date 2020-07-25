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
}

class HomeDashTaskOverviewCollectionViewHeader: HomeCollectionViewHeader {

    var sizeButton = UIButton()
    
    var size: TaskOverviewSectionSize = .compact
    
    override func setup() {
        super.setup()
        
        addSubview(sizeButton)
        sizeButton.translatesAutoresizingMaskIntoConstraints = false
        
        sizeButton.constraintCenterYToSuperview(constant: 0)
        sizeButton.constraintTrailingToSuperview(constant: 5)
        sizeButton.constraint(width: 25, height: 25)
        
        let image = UIImage(systemName: "chevron.compact.down")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 23, weight: .bold))
        
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
        let image = size.image?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 23, weight: .bold))

        UIView.transition(with: sizeButton, duration: 0.4, options: .transitionCrossDissolve) {
            self.sizeButton.setImage(image, for: .normal)
        } completion: { (_) in
            
        }

    }
    
    @objc func toggleCollapse() {
        
        toggleSize()
        reload()
    }
}
