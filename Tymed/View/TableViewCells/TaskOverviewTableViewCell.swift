//
//  TaskOverviewTableViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 28.06.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class TaskOverviewTableViewCell: UITableViewCell {
    
    var task: Task!
    
    var complete = UIButton()
    var titleLabel = UILabel()
    var descriptionLabel = UILabel()
    var dueLabel = UILabel()
    var subjectIndicator = UIView()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureUserInterface()
    }
    
    func reload(_ task: Task) {
        self.task = task
        
        let image = UIImage(systemName: task.completed ? "largecircle.fill.circle" : "circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold))
        complete.setImage(image, for: .normal)
        
//        titleLabel.text = task.title
        
        if task.completed {
            titleLabel.attributedText = NSAttributedString(string: task.title ?? "",
                                                           attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue])
        }else {
            titleLabel.attributedText = NSAttributedString(string: task.title ?? "")
        }
        
        subjectIndicator.backgroundColor = UIColor(named: task.lesson?.subject?.color ?? "") ?? UIColor.blue
        
        descriptionLabel.text = task.text ?? "-"
        
        dueLabel.text = task.due?.stringify(dateStyle: .short, timeStyle: .short)
    }
    
    private func addSubviews(_ views: UIView...) {
        views.forEach { (view) in
            self.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func configureUserInterface() {
        selectionStyle = .none
        
        addSubviews(complete, titleLabel, subjectIndicator, descriptionLabel, dueLabel)
        
        backgroundColor = .secondarySystemGroupedBackground
        contentView.backgroundColor = .secondarySystemGroupedBackground
        
        // Setup complete indicator
        complete.constraintLeadingToSuperview(constant: 0)
        complete.constraint(width: 30, height: 30)
        complete.constraintCenterYToSuperview(constant: 0)
        
        complete.addTarget(self, action: #selector(completeTap), for: .touchUpInside)
        
        // Setup subject indicator
        subjectIndicator.constraint(width: 10, height: 10)
        subjectIndicator.constraintTrailingToSuperview(constant: 5)
        subjectIndicator.constraintCenterYTo(anchor: titleLabel.centerYAnchor, constant: 0)

        subjectIndicator.layer.cornerRadius = 5
        
        // Setup title label
        titleLabel.constraintLeadingTo(anchor: complete.trailingAnchor, constant: 10)
        titleLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.4).isActive = true
        titleLabel.constraintTrailingTo(anchor: subjectIndicator.leadingAnchor, constant: 5)
        titleLabel.constraintTopToSuperview(constant: 5)
        
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        
        // Setup due label
        let constraint = dueLabel.leadingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -100)
        constraint.priority = UILayoutPriority.defaultHigh
        constraint.isActive = true
        dueLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.4).isActive = true
        dueLabel.constraintTrailingToSuperview(constant: 5)
        dueLabel.constraintTopTo(anchor: titleLabel.bottomAnchor, constant: 0)
        
        dueLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        dueLabel.textAlignment = .right
        
        // Setup description label
        descriptionLabel.constraintLeadingTo(anchor: complete.trailingAnchor, constant: 10)
        descriptionLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.4).isActive = true
        descriptionLabel.constraintTrailingTo(anchor: dueLabel.leadingAnchor, constant: 5)
        let c2 = descriptionLabel.trailingAnchor.constraint(equalTo: dueLabel.leadingAnchor, constant: -5)
        c2.priority = UILayoutPriority.defaultLow
        c2.isActive = true
        descriptionLabel.constraintTopTo(anchor: titleLabel.bottomAnchor, constant: 0)
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        descriptionLabel.text = "-"
        
    }
    
    @objc func completeTap() {
        task.completed.toggle()
        
        TimetableService.shared.save()

        let image = UIImage(systemName: task.completed ? "largecircle.fill.circle" : "circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold))
        complete.setImage(image, for: .normal)
        
        
        
        if task.completed {
            UIView.transition(with: titleLabel, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.titleLabel.text = ((self.task.title ?? "") + " 👏")
            }, completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    UIView.transition(with: self.titleLabel, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        self.titleLabel.text = self.task.title
                    }, completion: { _ in
                        UIView.transition(with: self.titleLabel, duration: 0.35, options: .transitionCrossDissolve, animations: {
                            self.reload(self.task)
                        })
                    })
                }
            })
        }else {
            UIView.transition(with: self.titleLabel, duration: 0.35, options: .transitionCrossDissolve, animations: {
                self.reload(self.task)
            })
        }
        
        layoutIfNeeded()
        
        
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

