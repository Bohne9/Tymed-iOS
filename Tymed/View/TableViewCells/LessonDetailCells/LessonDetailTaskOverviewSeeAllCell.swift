//
//  LessonDetailTaskOverviewSeeAllCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 03.07.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class LessonDetailTaskOverviewSeeAllCell: UITableViewCell {

    let label = UILabel()
    
    let chevronImage = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        contentView.addSubview(label)
        
        backgroundColor = .secondarySystemBackground
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.constraintLeadingToSuperview(constant: 0)
        label.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5).isActive = true
        label.constraintCenterYToSuperview(constant: 0)
        label.constraint(height: 20)
        
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .systemBlue
        
        label.text = "See all"

        addSubview(chevronImage)
        
        chevronImage.translatesAutoresizingMaskIntoConstraints = false
        
        chevronImage.constraintTrailingToSuperview(constant: 0)
        chevronImage.constraint(width: 20, height: 20)
        chevronImage.constraintCenterYToSuperview(constant: 0)
        
        chevronImage.image = UIImage(systemName: "chevron.right")?.withTintColor(.blue).withConfiguration(UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold))
        chevronImage.contentMode = .scaleAspectFit
        
        tintColor = .systemBlue
        
        selectionStyle = .none
        
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        alpha = selected ? 0.6 : 1
    }
}
