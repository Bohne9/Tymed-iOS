//
//  HomeDashTaskOverviewNoTasksCollectionViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 09.07.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class HomeDashTaskOverviewNoTasksCollectionViewCell: UICollectionViewCell {
    
    let addButton = UIButton()
    
    var taskDelegate: HomeTaskDetailDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func addTask() {
        taskDelegate?.onAddTask(nil)
    }
    
    private func setup() {
        contentView.addSubview(addButton)
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        addButton.constraintTopTo(anchor: contentView.topAnchor, constant: 0)
        addButton.constraintHorizontalToSuperview(leading: 0, trailing: 0)
        addButton.constraintBottomToSuperview(constant: 0)
        
        addButton.setTitle("Add Task", for: .normal)
        addButton.setImage(
            UIImage(systemName: "plus")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold))
            , for: .normal)
        
        addButton.setTitleColor(.systemBlue, for: .normal)
        
        addButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        
        addButton.addTarget(self, action: #selector(addTask), for: .touchUpInside)
        
        contentView.backgroundColor = .secondarySystemGroupedBackground
        contentView.layer.cornerRadius = 10
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 10
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.15
        
        layer.masksToBounds = false
    }
    
    
}
