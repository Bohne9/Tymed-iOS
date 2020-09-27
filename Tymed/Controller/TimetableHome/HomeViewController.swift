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

    let homeViewModel = HomeViewModel()
    
    var homeView = HomeDashViewWrapper()
    
    var taskView = HomeTaskViewWrapper()
    
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
        
        homeView.homeViewModel = homeViewModel
        taskView.homeViewModel = homeViewModel
        weekCollectionView.homeViewModel = homeViewModel
        
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
        
        collectionView.delegate = self
        
        weekCollectionView.homeViewControllerDelegate = self
        
        showAppSetupView()
    }
    
    func showAppSetupView() {
        
        if !SettingsService.shared.didRunAppSetup {
            let appStart = AppStartSetupWrapper()
            appStart.presentationDelegate = self
            
            present(appStart, animated: true, completion: nil)
        }
        
    }
    
    func setupFlowLayout() {
        
        guard let flowLayout = self.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        flowLayout.scrollDirection = .horizontal
        
        flowLayout.minimumLineSpacing = 20
        flowLayout.minimumInteritemSpacing = 20
    }
    
    func scrollToPage(bar: NavigationBar, page: Int) {
        scrollToPage(page: page)
    }
    
    func scrollToToday(bar: NavigationBar) {
        weekCollectionView.scrollTo(date: Date(), true)
    }
    
    func calendarScrollTo(date: Date) {
        weekCollectionView.scrollTo(date: date, true)
    }
    
    func currentDay() -> Date? {
        return weekCollectionView.currentDay()
    }
    
    func scrollToPage(page: Int) {
        collectionView.setContentOffset(CGPoint(x: CGFloat(page) * collectionView.frame.width, y: collectionView.contentInset.top), animated: true)
        print(collectionView.contentOffset)
    }
    
    @objc func tap(_ btn: UIButton) {
        scrollToPage(page: btn.tag)
    }
    
    func reload() {
        homeViewModel.reload()
        weekCollectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reload()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    private func baseCellFor(index: Int) -> UIViewController {
        return [homeView, taskView, weekCollectionView][index]
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
        let baseCell = baseCellFor(index: indexPath.section)
        
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
            return taskView
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
        collectionView.scrollToItem(at: IndexPath(row: 0, section: section), at: .left, animated: true)
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

extension HomeViewController: HomeViewControllerDelegate {
    
    func reloadHomeView() {
        reload()
    }
    
}

extension HomeViewController: DetailViewPresentationDelegate {
    func dismiss() {
        print("dismiss")
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancel() {
        TimetableService.shared.rollback()
        homeViewModel.reload()
        dismiss()
    }
    
    func done() {
        TimetableService.shared.save()
        homeViewModel.reload()
        dismiss()
    }
    
    func shouldDismiss() -> Bool {
        return true
    }
    
    
}
