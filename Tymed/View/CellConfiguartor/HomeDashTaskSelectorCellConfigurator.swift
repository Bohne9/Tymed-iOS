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
        
        let title = cell.type.title
        let imageName = cell.type.systemIcon
        let tint = cell.type.color
        
        cell.label.text = title
        cell.image.image = UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold))?.withTintColor(tint)
        cell.image.tintColor = tint
        
        if cell.isSelected {
            cell.selectedIndicator.image = UIImage(systemName: "checkmark")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))
        }else {
            cell.selectedIndicator.image = nil
        }
        
        
    }
    
    override func height(for cell: HomeDashTaskSelectorCollectionViewCell) -> CGFloat {
        return 55
    }
    
}
