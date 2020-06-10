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
    
    var titleText: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
        }
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
