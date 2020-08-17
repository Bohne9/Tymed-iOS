//
//  NavigationBar.swift
//  Tymed
//
//  Created by Jonah Schueller on 27.04.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class NavigationBar: UINavigationBar, UINavigationBarDelegate {

    let topBar = HomeTopBar()
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prefersLargeTitles = false
        isTranslucent = false
        
        backgroundColor = .systemBackground
        
        addSubview(topBar)
        
        addSubview(titleLabel)
        
        barTintColor = .systemBackground

        topBar.translatesAutoresizingMaskIntoConstraints = false
        topBar.backgroundColor = .systemBackground
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        topBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
//        topBar.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12).isActive = true
        topBar.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.95).isActive = true
        topBar.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        topBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        titleLabel.constraintCenterXToSuperview()
        titleLabel.constraintCenterYToSuperview()
        titleLabel.constraintWidthToSuperview()
        titleLabel.constraintHeightToSuperview()
        
        titleLabel.text = "Test"
        titleLabel.alpha = 0
        
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        
        shadowImage = UIImage()
    }
    
    func updateNavigationBar(_ page: Int) {
        topBar.highlightPage(page)
        
        UIView.animate(withDuration: 0.25) {
            self.topBar.alpha = page == 2 ? 0 : 1
            self.titleLabel.alpha = page == 2 ? 1 : 0
            self.layoutIfNeeded()
        } completion: { (res) in
//            self.topBar.isHidden = page == 2
        }

    }
    
    func setWeekTitle(_ title: String) {
        titleLabel.text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
