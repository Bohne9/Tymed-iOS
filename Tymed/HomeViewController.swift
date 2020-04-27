//
//  HomeViewController.swift
//  Tymed
//
//  Created by Jonah Schueller on 27.04.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit
import SwiftUI

class HomeViewController: UIViewController {

    var scrollView = UIScrollView()
        
    var dash = UIView()
    var tasks = UIView()
    var week = UIView()
    
    var currentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //MARK: NavBar setup
        
        if let navBar = (navigationController?.navigationBar as? NavigationBar) {
            navBar.topBar.dash.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
            navBar.topBar.tasks.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
            navBar.topBar.week.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
        }
        
        //MARK: ScrollView setup
        view.addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.topAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        
        scrollView.delegate = self
        
        scrollView.contentSize = CGSize(width: view.frame.width * 3, height: view.frame.height)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isDirectionalLockEnabled = true
        scrollView.scrollsToTop = false
        
        
        //MARK: Content setup
        
        let hosting = UIHostingController(rootView: HomeView())
        hosting.view.frame = view.frame
        hosting.didMove(toParent: self)

        configureView(tasks, .blue)
        configureView(week, .green)
        
        scrollView.addSubview(hosting.view)
        
        dash.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: dash.frame.size)
        
        scrollView.addSubview(tasks)
        tasks.frame = CGRect(origin: CGPoint(x: view.frame.width, y: 0), size: tasks.frame.size)
        
        scrollView.addSubview(week)
        week.frame = CGRect(origin: CGPoint(x: 2 * view.frame.width, y: 0), size: week.frame.size)
    }
    
    
    func configureView(_ view: UIView, _ background: UIColor) {
        
        view.frame = self.view.frame
        view.backgroundColor = background
        
    }
    
    
    @objc func tap(_ btn: UIButton) {
        print("Tap: \(btn.currentTitle!)")
        
        var frame: CGRect = self.scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(btn.tag)
        frame.origin.y = 0
        self.scrollView.scrollRectToVisible(frame, animated: true)
    }

}


//MARK: ScrollViewDelegate
extension HomeViewController: UIScrollViewDelegate {
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            
            let x = scrollView.contentOffset.x
            let width = scrollView.frame.size.width
            
            if width != 0 && Int(Double(x / width).rounded()) != currentPage {
                currentPage = Int(Double(x / width).rounded())
                if let navBar = (navigationController?.navigationBar as? NavigationBar) {
                    navBar.topBar.highlightPage(currentPage)
                }
            }
            
        }
        
    }
