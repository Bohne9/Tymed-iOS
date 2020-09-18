//
//  HomeViewController.swift
//  Tymed
//
//  Created by Jonah Schueller on 27.04.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit
import SwiftUI

let reuseIdentifier = "cell"

protocol HomeViewControllerDelegate {
    
    func reloadHomeView()
    
}

class HomeViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NavigationBarDelegate {

//    var dashCollectionView: HomeDashCollectionView = HomeDashCollectionView()
    var homeView = HomeDashViewWrapper()
    
    var tasksCollectionView: HomeTaskCollectionView = HomeTaskCollectionView()
    
    var weekCollectionView: HomeWeekCollectionView = HomeWeekCollectionView()
    
    var currentPage = 0 {
        didSet {
            if let navBar = (navigationController?.navigationBar as? NavigationBar) {
                navBar.updateNavigationBar(currentPage)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: NavBar setup
        
        if let navBar = (navigationController?.navigationBar as? NavigationBar) {
            navBar.navigationBarDelegate = self
            navBar.topBar.dash.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
            navBar.topBar.tasks.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
            navBar.topBar.week.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
//            navBar.barTintColor = .systemGroupedBackground
        }
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
            
        setupFlowLayout()
        
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .systemGroupedBackground
        view.backgroundColor = .systemGroupedBackground
        
//        dashCollectionView.taskOverviewDelegate = self
        tasksCollectionView.taskOverviewDelegate = self
        
//        dashCollectionView.homeViewControllerDelegate = self
        tasksCollectionView.homeViewControllerDelegate = self
        weekCollectionView.homeViewControllerDelegate = self
    }
    
    func setupFlowLayout() {
        
        guard let flowLayout = self.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        flowLayout.scrollDirection = .horizontal
           
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
    }
    
    func scrollToPage(bar: NavigationBar, page: Int) {
        scrollToPage(page: page)
    }
    
    func scrollToToday(bar: NavigationBar) {
        weekCollectionView.scrollTo(date: Date(), true)
    }
    
    func scrollToPage(page: Int) {
        collectionView.setContentOffset(CGPoint(x: CGFloat(page) * collectionView.frame.width, y: collectionView.contentInset.top), animated: true)
        print(collectionView.contentOffset)
    }
    
    @objc func tap(_ btn: UIButton) {
        scrollToPage(page: btn.tag)
    }
    
    func reload() {
//        dashCollectionView.reloadData()
        print("Reloading home scene")
        homeView.homeViewModel.reload()
        tasksCollectionView.reloadData()
        weekCollectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reload()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    private func baseCellFor(index: Int) -> UIViewController {
        return [homeView, tasksCollectionView, weekCollectionView][index]
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
        let baseCell = baseCellFor(index: indexPath.row)
        
        addChild(baseCell)
        
        cell.contentView.addSubview(baseCell.view)
                    
        baseCell.didMove(toParent: self)
        
        baseCell.view.translatesAutoresizingMaskIntoConstraints = false
        
        baseCell.view.constraintToSuperview()
        
        return cell
    }
    
    //MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    
    //MARK: ScrollViewDelegate
    
    private func sceneBaseCollectionView(for index: Int) -> UIViewController {
        if index == 0 {
            return homeView
        }else if index == 1 {
            return tasksCollectionView
        }else {
            return weekCollectionView
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Calculate current page
        let pagePercent = scrollView.contentOffset.x / scrollView.frame.width
        
        let page = Int(pagePercent.rounded())
        if let navBar = navigationController?.navigationBar as? NavigationBar {
            navBar.updateNavigationBar(page)
        }
    }
    
    func scrollToSection(_ section: Int) {
        
        collectionView.scrollToItem(at: IndexPath(row: section, section: 0), at: .left, animated: true)
        
    }
    
    func presentTaskAdd() -> TaskAddViewWrapper {
        let taskAdd = TaskAddViewWrapper()
        
        self.present(taskAdd, animated: true, completion: nil)
        
        return taskAdd
    }
    
    func presentTaskDetail(_ task: Task, animated: Bool = true) {
        let taskView = TaskEditViewWrapper()
        taskView.task = task
        
        self.present(taskView, animated: animated, completion: nil)
        
    }
    
    
}

extension HomeViewController: TaskOverviewTableviewCellDelegate {

    func onChange(_ cell: TaskOverviewTableViewCell) {
        reload()
    }
    
}


extension HomeViewController: HomeViewControllerDelegate {
    
    func reloadHomeView() {
        reload()
    }
    
}
