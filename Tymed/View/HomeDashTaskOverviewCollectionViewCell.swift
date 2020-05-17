//
//  HomeDashTaskOverviewCollectionViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 16.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

let homeDashTaskOverviewCollectionViewCell = "homeDashTaskOverviewCollectionViewCell"
class HomeDashTaskOverviewCollectionViewCell: HomeBaseCollectionViewCell {
    
    static func register(_ collectionView: UICollectionView) {
        collectionView.register(HomeDashTaskOverviewCollectionViewCell.self, forCellWithReuseIdentifier: homeDashTaskOverviewCollectionViewCell)
    }
    
    var tasks = [Task]()
    
    
    
    
}
