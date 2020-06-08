//
//  HomeDashTaskOverviewCollectionViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 16.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

let homeDashTaskOverviewCollectionViewCell = "homeDashTaskOverviewCollectionViewCell"
class HomeDashTaskOverviewCollectionViewCell: HomeBaseCollectionViewCell {
    
    static func register(_ collectionView: UICollectionView) {
        collectionView.register(HomeDashTaskOverviewCollectionViewCell.self, forCellWithReuseIdentifier: homeDashTaskOverviewCollectionViewCell)
    }
    
    var tasks: [Task]?
        
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBAction func onSeeAll(_ sender: Any) {
    
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func reload() {
        super.reload()
        
        guard stackView != nil else {
            return
        }
        
        guard let tasks = tasks else {
            return
        }
        print("hnfowe")
        clearTasks()
        
        // Add the first three tasks to the stackView
        tasks.prefix(3).forEach { addTaskView($0) }
        
    }
        
    private func clearTasks() {
        
        stackView.arrangedSubviews.forEach { (subview) in
            stackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        
    }
    
    private func addTaskView(_ task: Task) {
        
        let view = HomeDashTaskOverviewCollectionViewCellItem(task)
        stackView.addArrangedSubview(view)
        
    }
    
}


class HomeDashTaskOverviewCollectionViewCellItem: UIView {
    
    var task: Task
    
    var complete = UIButton()
    var label = UILabel()
    
    init(_ task: Task) {
        self.task = task
        super.init(frame: .zero)
        
        configureUserInterface()
    }
    
    private func configureUserInterface() {
        addSubview(complete)
        
        addSubview(label)
        
        complete.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let image = UIImage(systemName: task.completed ? "largecircle.fill.circle" : "circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold))
        complete.setImage(image, for: .normal)
        
        complete.constraintLeadingToSuperview(constant: -6 )
        complete.constraint(width: 44, height: 44)
        complete.constraintCenterYToSuperview(constant: 0)
        
        complete.addTarget(self, action: #selector(completeTap), for: .touchUpInside)
        
        label.constraintLeadingTo(anchor: complete.trailingAnchor, constant: 5)
        label.constraintHeightToSuperview()
        label.constraintTrailingToSuperview(constant: 0)
        label.constraintCenterYToSuperview(constant: 0)
        
        label.text = task.title
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
    }
    
    @objc func completeTap() {
        task.completed.toggle()
        
        let image = UIImage(systemName: task.completed ? "largecircle.fill.circle" : "circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold))
        complete.setImage(image, for: .normal)
        
        if task.completed {
            UIView.transition(with: label, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.label.text = ((self.task.title ?? "") + " 👏")
            }, completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    UIView.transition(with: self.label, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        self.label.text = self.task.title
                    }, completion: nil)
                }
                
            })
        }
        
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
