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

class HomeViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NavigationBarDelegate {

    var dashCollectionView: HomeDashCollectionView = {
        let homeDash = HomeDashCollectionView()
        
        return homeDash
    }()
    
    var tasksCollectionView: HomeTaskCollectionView = {
        let homeTask = HomeTaskCollectionView()
        
        return homeTask
    }()
    
    var weekCollectionView: HomeWeekCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let homeWeek = HomeWeekCollectionView()
        
        return homeWeek
    }()
    
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
        
        tasksCollectionView.taskOverviewDelegate = self
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
        dashCollectionView.reload()
        tasksCollectionView.reload()
        weekCollectionView.reload()
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

    private func baseCellFor(index: Int) -> HomeBaseCollectionView {
        return [dashCollectionView, tasksCollectionView, weekCollectionView][index]
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
    
    private func sceneBaseCollectionView(for index: Int) -> HomeBaseCollectionView {
        if index == 0 {
            return dashCollectionView
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
