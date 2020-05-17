//
//  ViewController.swift
//  Tymed
//
//  Created by Jonah Schueller on 27.04.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit
import SwiftUI

class ViewController: UITabBarController {

    let homeVC = HomeViewController(collectionViewLayout: UICollectionViewFlowLayout())
    
    let addVC = AddCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
    
    let profileVC = ProfileCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tabBar.isTranslucent = false
        
        
        let home = generateHomeViewController()
        
        let homeTabItem = UITabBarItem(title: nil, image: UIImage(systemName: "house.fill",
                        withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .bold)), tag: 0)
        
        home.tabBarItem = homeTabItem
        
        let add = generateAddViewController()
        
        let addTabItem = UITabBarItem(title: nil, image: UIImage(systemName: "plus.square.fill",
                                                                 withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)), tag: 1)
        
        add.tabBarItem = addTabItem
        
        let profile = generateProfileViewController()
        
        let profileTabItem = UITabBarItem(title: nil, image: UIImage(systemName: "person.fill"), tag: 2)
        
        profile.tabBarItem = profileTabItem
        
        viewControllers = [home, add, profile]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        homeVC.dashCollectionView.reload()
        
    }
    
    private func generateProfileViewController() -> UINavigationController {
        let nav = UINavigationController(rootViewController: profileVC)

        return nav
    }
    
    private func generateAddViewController() -> UINavigationController {
//        let nav = UINavigationController(navigationBarClass: LessonAddNavigationbar.self, toolbarClass: nil)
//        nav.setViewControllers([addVC], animated: false)
        let nav = UINavigationController(rootViewController: addVC)
        
        return nav
    }
    
    private func generateHomeViewController() -> UINavigationController {

        let nav = UINavigationController(navigationBarClass: NavigationBar.self, toolbarClass: nil)
        nav.setViewControllers([homeVC], animated: false)

        return nav
    }
    
    

}
