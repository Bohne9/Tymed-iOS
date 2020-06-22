//
//  BaseCollectionViewCellConfigurator.swift
//  Tymed
//
//  Created by Jonah Schueller on 21.06.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class BaseCollectionViewCellConfigurator<Cell: UICollectionViewCell> {
    
    func reset() {
        
    }
    
    func configure(_ cell: Cell) {
        
    }
    
    func height(for cell: Cell) -> CGFloat {
        fatalError("Invalid implemention of BaseCollectionViewCellConfigurator.height(for: )")
    }
}
