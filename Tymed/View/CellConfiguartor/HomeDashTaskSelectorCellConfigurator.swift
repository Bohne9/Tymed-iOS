//
//  HomeDashTaskSelectorCellConfigurator.swift
//  Tymed
//
//  Created by Jonah Schueller on 08.07.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class HomeDashTaskSelectorCellConfigurator: BaseCollectionViewCellConfigurator<HomeDashTaskSelectorCollectionViewCell> {
    
    
    
    override func configure(_ cell: HomeDashTaskSelectorCollectionViewCell) {
        
        var title = ""
        var imageName = ""
        var tint = UIColor.systemBlue
        
        switch cell.type {
        case .today:
            title = "Today"
            imageName = "calendar"
            tint = .appBlue
            break
        case .done:
            title = "Done"
            imageName = "checkmark.circle.fill"
            tint = .appGreen
        case .all:
            title = "All"
            imageName = "tray.full.fill"
            tint = .systemGray
        case .expired:
            title = "Expired"
            imageName = "exclamationmark.circle.fill"
            tint = .appRed
        }
        
        cell.label.text = title
        cell.image.image = UIImage(systemName: imageName)?.withTintColor(tint)
        cell.image.tintColor = tint
        
    }
    
    override func height(for cell: HomeDashTaskSelectorCollectionViewCell) -> CGFloat {
        return 55
    }
    
}
