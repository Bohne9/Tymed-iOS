//
//  NavigationBar.swift
//  Tymed
//
//  Created by Jonah Schueller on 27.04.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

protocol NavigationBarDelegate {
    
    func scrollToPage(bar: NavigationBar, page: Int)
    
}

class NavigationBar: UINavigationBar, UINavigationBarDelegate {

    var navigationBarDelegate: NavigationBarDelegate?
    
    // View for Start & Tasks scene
    let topBar = HomeTopBar()
    
    // Views for Week scene
    let titleLabel = UILabel()
    let backBtn = UIButton()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prefersLargeTitles = false
        isTranslucent = false
        isUserInteractionEnabled = true
        
        backgroundColor = .systemBackground
        
        addSubview(topBar)
        
        barTintColor = .systemBackground
        
        topBar.translatesAutoresizingMaskIntoConstraints = false
        topBar.backgroundColor = .systemBackground
        
        topBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        topBar.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.95).isActive = true
        topBar.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        topBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        setupWeekScene()
        
        shadowImage = UIImage()
    }
    
    private func setupWeekScene() {
        
        // Setup custom title label
        addSubview(titleLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.constraintCenterXToSuperview()
        titleLabel.constraintCenterYToSuperview()
        titleLabel.constraintWidthToSuperview()
        titleLabel.constraintHeightToSuperview()
        
        titleLabel.text = "Test"
        titleLabel.alpha = 0
        
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        
        // Setup back button
        addSubview(backBtn)
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        
        backBtn.constraintLeadingToSuperview(constant: 20)
        backBtn.constraintCenterYToSuperview()
        backBtn.constraint(width: 30, height: 30)
        
        let image = UIImage(systemName: "chevron.left")?
            .withConfiguration(UIImage.SymbolConfiguration(font: .systemFont(ofSize: 18, weight: .semibold)))
        
        backBtn.setImage(image, for: .normal)
        
        backBtn.addTarget(self, action: #selector(onTapBackButton), for: .touchUpInside)
        
        backBtn.alpha = 0
    }
    
    func updateNavigationBar(_ page: Int) {
        topBar.highlightPage(page)
        
        UIView.animate(withDuration: 0.25) {
            self.topBar.alpha = page == 2 ? 0 : 1
            self.titleLabel.alpha = page == 2 ? 1 : 0
            self.backBtn.alpha = page == 2 ? 1 : 0
            self.layoutIfNeeded()
        } completion: { (res) in
//            self.topBar.isHidden = page == 2
        }

    }
    
    func setWeekTitle(_ title: String) {
        titleLabel.text = title
    }
    
    @objc func onTapBackButton() {
        // Scroll to the task scene (the scroll delegate will handle the update of the navBar)
        navigationBarDelegate?.scrollToPage(bar: self, page: 1)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
