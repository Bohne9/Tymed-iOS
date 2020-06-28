//
//  TaskLessonAttachTableViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 25.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class TaskLessonAttachTableViewCell: UITableViewCell {
    
    @IBOutlet weak var attchLesson: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
