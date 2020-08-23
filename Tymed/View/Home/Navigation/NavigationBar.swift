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
    
    func scrollToToday(bar: NavigationBar)
}

class NavigationBar: UINavigationBar, UINavigationBarDelegate, UIContextMenuInteractionDelegate {

    var navigationBarDelegate: NavigationBarDelegate?
    
    // View for Start & Tasks scene
    let topBar = HomeTopBar()
    
    // Views for Week scene
    let dateLabel = UILabel()
    let titleLabel = UILabel()
    let backBtn = UIButton()
    var todaybtn = UIButton()
    let chevronIndicator = UIImageView(image: UIImage(systemName: "chevron.down")?.withConfiguration(UIImage.SymbolConfiguration(font: .systemFont(ofSize: 12, weight: .semibold))))
    
    private(set) var currentPage: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prefersLargeTitles = false
        isTranslucent = false
        isUserInteractionEnabled = true
        
        backgroundColor = .systemGroupedBackground
        
        addSubview(topBar)
        
        barTintColor = .systemGroupedBackground
        
        topBar.translatesAutoresizingMaskIntoConstraints = false
        topBar.backgroundColor = .systemGroupedBackground
        
        topBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        topBar.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.95).isActive = true
        topBar.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        topBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        setupWeekScene()
        
        shadowImage = UIImage()
    }
    
    private func setupWeekScene() {
        
        let stack = UIStackView(arrangedSubviews: [dateLabel, titleLabel, chevronIndicator])
        
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        
        // Setup custom title label
//        addSubview(titleLabel)
//        addSubview(dateLabel)
        addSubview(todaybtn)
        
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        
        stack.constraintCenterXToSuperview()
        stack.constraintCenterYToSuperview()
        stack.constraintHeightToSuperview()
        stack.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
        
        chevronIndicator.constraint(width: 30, height: 13)
        chevronIndicator.translatesAutoresizingMaskIntoConstraints = false
        chevronIndicator.contentMode = .scaleAspectFit
        chevronIndicator.tintColor = .secondaryLabel
        
        chevronIndicator.alpha = 0
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        todaybtn.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.text = "Test"
        titleLabel.alpha = 0
        
        dateLabel.text = "Date"
        dateLabel.alpha = 0
        
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        
        dateLabel.textAlignment = .center
        dateLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        
        dateLabel.textColor = .secondaryLabel
        
        // Setup back button
        addSubview(backBtn)
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        
        backBtn.constraintLeadingToSuperview(constant: 10)
        backBtn.constraintCenterYToSuperview()
        backBtn.constraint(width: 40, height: 40)
        
        todaybtn.constraintTrailingToSuperview(constant: 10)
        todaybtn.constraintCenterYToSuperview()
        todaybtn.constraint(width: 40, height: 40)
        
        let image = UIImage(systemName: "chevron.left")?
            .withConfiguration(UIImage.SymbolConfiguration(font: .systemFont(ofSize: 18, weight: .semibold)))
        
        backBtn.setImage(image, for: .normal)
        
        backBtn.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        
        backBtn.addTarget(self, action: #selector(onTapBackButton), for: .touchUpInside)
        
        backBtn.alpha = 0
        
        let img2 = UIImage(systemName: "calendar.circle.fill")?
            .withConfiguration(UIImage.SymbolConfiguration(font: .systemFont(ofSize: 24, weight: .semibold)))
        
        todaybtn.setImage(img2, for: .normal)
        
//        todaybtn.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        
        todaybtn.addTarget(self, action: #selector(onTapTodayButton), for: .touchUpInside)
        
        todaybtn.alpha = 0
        
        let interaction = UIContextMenuInteraction(delegate: self)
        
        stack.addInteraction(interaction)
        stack.isUserInteractionEnabled = true
    }
    
    private func setupWeekNavigationBar(_ visible: Bool) {
        let alpha: CGFloat = visible ? 1 : 0
        
        self.titleLabel.alpha = alpha
        self.dateLabel.alpha = alpha
        self.backBtn.alpha = alpha
        self.todaybtn.alpha = alpha
        self.chevronIndicator.alpha = alpha
    }
    
    func updateNavigationBar(_ page: Int) {
        topBar.highlightPage(page)
        
        if page != currentPage {
            print("update")
            UIView.animate(withDuration: 0.25) {
                self.topBar.alpha = page == 2 ? 0 : 1
                self.setupWeekNavigationBar(page == 2)
                self.layoutIfNeeded()
            } completion: { (res) in
            }
        }
        
        currentPage = page

    }
    
    func setWeekTitle(_ date: Date) {
        titleLabel.text = Day.from(date: date)?.string()
        dateLabel.text = date.stringify(with: .medium, relativeFormatting: true)
        layoutIfNeeded()
    }
    
    @objc func onTapBackButton() {
        // Scroll to the task scene (the scroll delegate will handle the update of the navBar)
        navigationBarDelegate?.scrollToPage(bar: self, page: 1)
    }
    
    @objc func onTapTodayButton() {
        navigationBarDelegate?.scrollToToday(bar: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        let menu = UIContextMenuConfiguration(identifier: "titleLabel" as NSString) {
            return nil
        } actionProvider: { (element) -> UIMenu? in
            
            let week = UIAction(title: "Week") { (action) in
                print("Week")
            }
            
            let month = UIAction(title: "Month") { (action) in
                print("Month")
            }
            
            let year = UIAction(title: "Year") { (action) in
                print("Year")
            }
            
            return UIMenu(title: "Calendar", image: nil, identifier: nil, children: [week, month, year])
        }

        return menu
    }
    
    
    @objc func onTapContextWeek() {
        print("Context Menu week")
    }
    
}
