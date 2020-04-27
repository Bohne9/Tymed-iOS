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

    let homeVC = HomeViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let home = generateHomeViewController()
        
        let homeTabItem = UITabBarItem(title: nil, image: UIImage(systemName: "house.fill"), tag: 0)
        
        home.tabBarItem = homeTabItem
        
        viewControllers = [home]
    }
    
    private func generateHomeViewController() -> UINavigationController {
        
        let nav = UINavigationController(navigationBarClass: NavigationBar.classForCoder(), toolbarClass: nil)
        nav.setViewControllers([homeVC], animated: false)
        
        return nav
    }
    
    

}
