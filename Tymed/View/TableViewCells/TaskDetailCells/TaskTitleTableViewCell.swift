//
//  TaskTitleTableViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 24.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class TaskTitleTableViewCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var complete: UIButton!
    
    private weak var task: Task?
    
    @IBOutlet weak var textFieldCompleteBtnTrailing: NSLayoutConstraint!
    @IBOutlet weak var textFieldContextViewLeading: NSLayoutConstraint!
    
    var titleText: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
        }
    }
    
    @IBAction func completeToogle(_ sender: UIButton) {
        guard let task = self.task else {
            return
        }
        
        task.completed.toggle()
        
        task.completionDate = task.completed ? Date() : nil
        
        TimetableService.shared.save()
        setComplete(for: task)
    }
    
    func setCompleteBtn(active: Bool) {
        
        complete.isHidden = !active
        
        textFieldContextViewLeading.isActive = !active
        textFieldCompleteBtnTrailing.isActive = active
    }
    
    func setComplete(for task: Task?) {
        guard let task = task else {
            return
        }
        
        self.task = task
        
        if complete.isHidden {
            return
        }
        
        let completed = task.completed
        
        var systemImage: String = completed ? "checkmark.circle.fill" : "circle"
        
        var tint: UIColor = completed ? .appGreen : .appBlue
        
        // If the task has a due date attached
        if let due = task.due {
            if completed {
                if let completion = task.completionDate, due < completion {
                    tint = .appOrange
                    NotificationService.current.removeDeliveredNotifications(of: task)
                }
            } else if due < Date() {
                tint = .appRed
                systemImage = "exclamationmark.circle.fill"
            }
        }
        
        let image = UIImage(systemName: systemImage, withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold))
        
        UIView.transition(with: self.complete, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.complete.tintColor = tint
            self.complete.setImage(image, for: .normal)
        })
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
