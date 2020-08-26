//
//  HomeTaskAddTaskCollectionViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 26.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class HomeTaskAddTaskCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "homeTaskAddTaskCollectionViewCell"
    
    let addButton = UIButton()
    
    var homeDelegate: HomeViewSceneDelegate?
    
    var type: HomeDashTaskSelectorCellType?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func addTask() {
        
        homeDelegate?.presentTaskAddView()
        
    }
    
    private func setup() {
        contentView.addSubview(addButton)
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        addButton.constraintTopTo(anchor: contentView.topAnchor, constant: 0)
        addButton.constraintLeadingToSuperview(constant: 20)
//        addButton.constraintTrailingToSuperview(constant: 20)
        addButton.constraintBottomToSuperview(constant: 0)
        
        addButton.setTitle("Add Task", for: .normal)
        addButton.setImage(
            UIImage(systemName: "plus")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))
            , for: .normal)
        
        addButton.setTitleColor(.systemBlue, for: .normal)
        
        addButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        
        addButton.addTarget(self, action: #selector(addTask), for: .touchUpInside)
        
        contentView.backgroundColor = .secondarySystemGroupedBackground
        contentView.layer.cornerRadius = 10
        
        layer.masksToBounds = false
    }
    
    
}
