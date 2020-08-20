//
//  HomeDashTaskOverviewNoTasksCollectionViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 09.07.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class HomeDashTaskOverviewNoTasksCollectionViewCell: UICollectionViewCell {
    
    
    let label = UILabel()
    
    let addButton = UIButton()
    
    var taskDelegate: HomeTaskAddDelegate?
    
    var type: HomeDashTaskSelectorCellType?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func addTask() {
        taskDelegate?.onAddTask(nil, completion: { (viewController) in
            guard let type = self.type else { return }
            
        })
    }
    
    private func setup() {
        contentView.addSubview(label)
        contentView.addSubview(addButton)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        label.constraintLeadingToSuperview(constant: 20)
        label.constraintHeightToSuperview()
        label.constraintCenterYToSuperview()
        
        addButton.constraintTopTo(anchor: contentView.topAnchor, constant: 0)
        addButton.constraintTrailingToSuperview(constant: 20)
        addButton.constraintBottomToSuperview(constant: 0)
        
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.text = "No tasks left 👍"
        
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
