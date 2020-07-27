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
    
    func next() -> TaskOverviewSectionSize {
        switch self {
        case .collapsed:    return .compact
        case .compact:      return .large
        case .large:        return .collapsed
        }
    }
}

protocol TaskOverviewHeaderDelegate {
    
    func onCollapseToogle(_ header: HomeDashTaskOverviewCollectionViewHeader, identifier: String)
    
    func nextSizeFor(_ header: HomeDashTaskOverviewCollectionViewHeader, current: TaskOverviewSectionSize, with identifier: String) -> TaskOverviewSectionSize
    
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
        sizeButton.constraint(width: 30, height: 30)
//        sizeButton.constraintLeadingTo(anchor: trailingAnchor, constant: -180)
        
        let image = UIImage(systemName: "chevron.compact.down")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold))
        
        sizeButton.setImage(image, for: .normal)
        sizeButton.tintColor = .secondaryLabel
        
        // Edge insets to make the tap area of the button bigger but keeping the image right aligned.
//        sizeButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 150, bottom: 5, right: 0)
        
        sizeButton.addTarget(self, action: #selector(toggleCollapse), for: .touchUpInside)
    }
    
    func reloadSizeButtonImage() {
        let image = size.image?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold))
        self.sizeButton.setImage(image, for: .normal)
    }
    
    func reload() {
        
        UIView.transition(with: sizeButton, duration: 0.25, options: .transitionCrossDissolve) {
            self.reloadSizeButtonImage()
            self.delegate?.onCollapseToogle(self, identifier: self.sectionIdentifier)
        } completion: { (_) in
            
        }
    }
    
    @objc func toggleCollapse() {
        
//        toggleSize { (_) in
//            self.reload()
//        }
        size = self.delegate?.nextSizeFor(self, current: size, with: sectionIdentifier) ?? .compact
        reload()
        
    }
    
    
    private func scaleY(amount: CGFloat, _ completion: ((Bool) -> Void)?) {
        
        UIView.animate(withDuration: 0.25) {
            self.sizeButton.transform = self.sizeButton.transform.scaledBy(x: 1, y: amount)
        } completion: { (res) in
            completion?(res)
        }

        
    }
    
    private func rotate(by degree: CGFloat, _ completion: ((Bool) -> Void)?) {
        
        UIView.animate(withDuration: 0.25) {
            self.sizeButton.transform = self.sizeButton.transform.rotated(by: degree)
        } completion: { (res) in
            completion?(res)
        }
    }
    
    private func unrotate() {
        self.sizeButton.transform = self.sizeButton.transform.rotated(by: 0)
    }
    
    private func unscaleY() {
        self.sizeButton.transform = self.sizeButton.transform.scaledBy(x: 1, y: 1)
    }
}
