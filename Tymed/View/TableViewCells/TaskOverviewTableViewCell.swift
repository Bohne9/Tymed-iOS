//
//  TaskOverviewTableViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 28.06.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

protocol TaskOverviewTableviewCellDelegate {
    
    func onChange(_ cell: TaskOverviewTableViewCell)
    
}

class TaskOverviewTableViewCell: UITableViewCell {
    
    var task: Task!
    
    var complete = UIButton()
    var titleLabel = UILabel()
    var descriptionLabel = UILabel()
    var dueLabel = UILabel()
    var subjectIndicator = UIView()
    
    var taskOverviewDelegate: TaskOverviewTableviewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureUserInterface()
    }
    
    private func reloadCompleteIndicator() {
        
        let completed = task.completed
        
        var systemImage: String = completed ? "checkmark.circle.fill" : "circle"
        
        var tint: UIColor = completed ? .systemGreen : .systemBlue
        
        // If the task has a due date attached
        if let due = task.due {
            if completed {
                if let completion = task.completionDate, due < completion {
                    tint = .systemOrange
                    NotificationService.current.removeDeliveredNotifications(of: task)
                }
            } else if due < Date() {
                tint = .systemRed
                systemImage = "exclamationmark.circle.fill"
            }
        }
        
        let image = UIImage(systemName: systemImage, withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold))
        
        UIView.transition(with: self.complete, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.complete.tintColor = tint
            self.complete.setImage(image, for: .normal)
        })
        
    }
    
    func reload(_ task: Task) {
        self.task = task
        
        reloadCompleteIndicator()
        
        if task.completed {
            titleLabel.attributedText = NSAttributedString(string: task.title ,
                                                           attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.thick.rawValue])
        }else {
            titleLabel.attributedText = NSAttributedString(string: task.title )
        }
        
        subjectIndicator.backgroundColor = UIColor(named: task.lesson?.subject?.color ?? "") ?? UIColor.clear
        
        descriptionLabel.text = task.text ?? "-"
        
        
//        if let due = task.due {
//            dueLabel.text = due.stringify(dateStyle: .short, timeStyle: .short)
//            dueLabel.textColor = due < Date() ? .systemRed : .systemBlue
//        }
    }
    
    private func addSubviews(_ views: UIView...) {
        views.forEach { (view) in
            contentView.addSubview(view)
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
        complete.constraint(width: 27, height: 27)
        complete.constraintCenterYToSuperview(constant: 0)
        
        complete.addTarget(self, action: #selector(completeToogle), for: .touchUpInside)
        
        // Setup subject indicator
        subjectIndicator.constraint(width: 10, height: 10)
        subjectIndicator.constraintTrailingToSuperview(constant: 5)
        subjectIndicator.constraintCenterYTo(anchor: titleLabel.centerYAnchor, constant: 0)

        subjectIndicator.layer.cornerRadius = 5
        
        // Setup title label
        titleLabel.constraintLeadingTo(anchor: complete.trailingAnchor, constant: 10)
        titleLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.4).isActive = true
        titleLabel.constraintTrailingTo(anchor: subjectIndicator.leadingAnchor, constant: 5)
        titleLabel.constraintTopToSuperview(constant: 5)
        
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        
        // Setup due label
        let constraint = dueLabel.leadingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -100)
        constraint.priority = UILayoutPriority.defaultHigh
        constraint.isActive = true
        dueLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.4).isActive = true
        dueLabel.constraintTrailingToSuperview(constant: 5)
        dueLabel.constraintTopTo(anchor: titleLabel.bottomAnchor, constant: 0)
        
        dueLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        dueLabel.textAlignment = .right
        dueLabel.textColor = .systemBlue
        
        dueLabel.text = "-"
        
        // Setup description label
        descriptionLabel.constraintLeadingTo(anchor: complete.trailingAnchor, constant: 10)
        descriptionLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.4).isActive = true
        descriptionLabel.constraintTrailingTo(anchor: dueLabel.leadingAnchor, constant: 5)
        let c2 = descriptionLabel.trailingAnchor.constraint(equalTo: dueLabel.leadingAnchor, constant: -5)
        c2.priority = UILayoutPriority.defaultLow
        c2.isActive = true
        descriptionLabel.constraintTopTo(anchor: titleLabel.bottomAnchor, constant: 0)
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        descriptionLabel.textColor = .secondaryLabel
        
        descriptionLabel.text = "-"
        
    }
    
    @objc func completeToogle() {
        task.completed.toggle()
        
        task.completionDate = task.completed ? Date() : nil
        
        TimetableService.shared.save()

        reloadCompleteIndicator()
        
        if task.completed {
            UIView.transition(with: titleLabel, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.titleLabel.text = ((self.task.title) + " 👏")
            }, completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    UIView.transition(with: self.titleLabel, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        self.titleLabel.text = self.task.title
                    }, completion: { _ in
                        UIView.transition(with: self.titleLabel, duration: 0.35, options: .transitionCrossDissolve, animations: {
                            self.reload(self.task)
                            self.taskOverviewDelegate?.onChange(self)
                        })
                    })
                }
            })
        }else {
            UIView.transition(with: self.titleLabel, duration: 0.35, options: .transitionCrossDissolve, animations: {
                self.reload(self.task)
                self.taskOverviewDelegate?.onChange(self)
            })
        }
        
        layoutIfNeeded()
        
        
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

