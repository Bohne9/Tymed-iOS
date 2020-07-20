//
//  TimetableDetailTitleTableViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 20.07.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class TimetableDetailTitleTableViewCell: UITableViewCell {
    
    var textField = UITextField()
    
    var titleText: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        contentView.addSubview(textField)
        
        contentView.backgroundColor = .systemGroupedBackground
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        textField.constraintToSuperview(top: 10, bottom: 10, leading: 10, trailing: 10)
        
        textField.font = .boldSystemFont(ofSize: 24)
        textField.placeholder = "Timetable name"
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
