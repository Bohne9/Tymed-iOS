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
    
    let addVC = TimetableOverviewViewController()
    
    let profileVC = ProfileCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tabBar.isTranslucent = false
        
        view.backgroundColor = .systemGroupedBackground
        
        let home = generateHomeViewController()
        
        let homeTabItem = UITabBarItem(title: "Start", image: UIImage(systemName: "house.fill",
                                                            withConfiguration: UIImage.SymbolConfiguration(weight: .bold)), tag: 0)
        
        home.tabBarItem = homeTabItem
        
        let add = generateAddViewController()
        
        let addTabItem = UITabBarItem(title: "Timetable", image: UIImage(systemName: "plus",
                                                            withConfiguration: UIImage.SymbolConfiguration(weight: .bold)), tag: 1)
        
        add.tabBarItem = addTabItem
        
        let profile = generateProfileViewController()
        
        let profileTabItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.fill",
                                                            withConfiguration: UIImage.SymbolConfiguration(weight: .bold)), tag: 2)
        
        profile.tabBarItem = profileTabItem
        
        viewControllers = [home, add, profile]
    }
    
    func reload() {
        homeVC.reload()
        addVC.reload()
        profileVC.reload()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        homeVC.dashCollectionView.reload()
        
    }
    
    private func generateProfileViewController() -> UINavigationController {
        let nav = UINavigationController(rootViewController: profileVC)

        return nav
    }
    
    private func generateAddViewController() -> UIViewController {
        
        
        let nav = UINavigationController(rootViewController: UIHostingController(rootView:
                                                                                    TimetableOverview()
                                                                                    .environment(\.managedObjectContext, AppDelegate.persistentContainer)))
        
//        let split = UISplitViewController()
//
//        split.preferredDisplayMode = UISplitViewController.DisplayMode.oneBesideSecondary
//        split.viewControllers = [nav]
//
//        split.extendedLayoutIncludesOpaqueBars = true
//
//
        
        return nav
        
    }
    
    private func generateHomeViewController() -> UINavigationController {

        let nav = UINavigationController(navigationBarClass: NavigationBar.self, toolbarClass: nil)
        nav.setViewControllers([homeVC], animated: false)
        
        return nav
    }
    
    

}
