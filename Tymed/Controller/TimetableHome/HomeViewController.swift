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

class HomeViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

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
                navBar.topBar.highlightPage(currentPage)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: NavBar setup
        
        if let navBar = (navigationController?.navigationBar as? NavigationBar) {
            navBar.topBar.dash.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
            navBar.topBar.tasks.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
            navBar.topBar.week.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
//            navBar.barTintColor = .systemGroupedBackground
        }
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
//        additionalSafeAreaInsets = UIEdgeInsets(top: 60, left: 0, bottom: 60, right: 0)
        
        setupFlowLayout()
        
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .systemGroupedBackground
        
        dashCollectionView.homeDelegate = self
        tasksCollectionView.homeDelegate = self
        weekCollectionView.homeDelegate = self
        
        dashCollectionView.taskDelegate = self
        tasksCollectionView.taskDelegate = self
        
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
    
    
    @objc func tap(_ btn: UIButton) {
        print("Tap: \(btn.currentTitle!) \(btn.tag)")
        
//        collectionView.scrollToItem(at: IndexPath(row: btn.tag, section: 0), at: .left, animated: true)
        collectionView.setContentOffset(CGPoint(x: CGFloat(btn.tag) * collectionView.frame.width, y: collectionView.contentInset.top), animated: true)
        print(collectionView.contentOffset)
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

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
        let baseCell = [dashCollectionView, tasksCollectionView, weekCollectionView][indexPath.row]
        
        cell.addSubview(baseCell)
                    
        baseCell.translatesAutoresizingMaskIntoConstraints = false

        baseCell.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
        baseCell.leadingAnchor.constraint(equalTo: cell.leadingAnchor).isActive = true
        baseCell.trailingAnchor.constraint(equalTo: cell.trailingAnchor).isActive = true
        baseCell.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
        
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
    
    private func navigationBarAlphaTransition(page: CGFloat) {
        
        let first = Int(page)
        let sec = min(Int(page + 1), 2)
        
        let firstOff = sceneBaseCollectionView(for: first).contentOffset.y
        let secOff = sceneBaseCollectionView(for: sec).contentOffset.y
        
        let percent = page - CGFloat(Int(page))
        
        let firstAlpha = calcuateNavBarBackgroundAlpha(firstOff)
        let secAlpha = calcuateNavBarBackgroundAlpha(secOff)
        
        let m = (secAlpha - firstAlpha)
        
        let val = m * percent + firstAlpha
        
//        print("First: \(first), Sec: \(sec) F-Alpha: \(firstAlpha), S-Alpha: \(secAlpha), Alpha: \(val), Percent: \(percent)")
        
        // Just to avoid force unwrapping
        guard let nav = navigationController?.navigationBar else {
            return
        }
        
        // Update the alpha of the navigation bar background view
        nav.subviews.first?.alpha = val
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Calculate current page
        let pagePercent = scrollView.contentOffset.x / scrollView.frame.width
        
        let page = Int(pagePercent.rounded())
        if let navBar = navigationController?.navigationBar as? NavigationBar {
            navigationBarAlphaTransition(page: pagePercent)
            navBar.topBar.highlightPage(page)
        }
    }
    
    func scrollToSection(_ section: Int) {
        
        collectionView.scrollToItem(at: IndexPath(row: section, section: 0), at: .left, animated: true)
        
    }
    
    func presentTaskAdd() -> TaskAddViewController {
        let taskAdd = TaskAddViewController(style: .insetGrouped)
        
        taskAdd.detailDelegate = self

        let nav = UINavigationController(rootViewController: taskAdd)
        self.present(nav, animated: true, completion: nil)
        
        return taskAdd
    }
    
    func presentTaskDetail(_ task: Task, animated: Bool = true) {
        
        
//        DispatchQueue.main.async {
            let vc = TaskDetailTableViewController(style: .insetGrouped)
            vc.task = task
            vc.taskDelegate = self
            let nav = UINavigationController(rootViewController: vc)
            
            vc.title = "Task"
            
            vc.detailDelegate = self
            
            self.present(nav, animated: animated, completion: nil)
        
//        }
        
    }
}

//MARK: HomeCollectionViewDelegate
extension HomeViewController: HomeCollectionViewDelegate {
    
    func lessonDetail(_ view: UIView, for lesson: Lesson) {
        
        let vc = LessonDetailTableViewController(style: .insetGrouped)
        vc.lesson = lesson
        vc.taskDelegate = self
        
        let nav = UINavigationController(rootViewController: vc)
        
        vc.title = lesson.subject?.name ?? "-"
        
        vc.delegate = self
        
        self.present(nav, animated: true, completion: nil)
        
    }
    
    func taskDetail(_ view: UIView, for task: Task) {
        presentTaskDetail(task)
    }
    
}

extension HomeViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("home did dismiss")
    }
    
}

extension HomeViewController: HomeDetailTableViewControllerDelegate {
    
    func detailWillDismiss(_ viewController: UIViewController) {
        reload()
    }
    
    func lessonDidDelete(_ view: UIView, lesson: Lesson) {
        reload()
    }
}


extension HomeViewController: HomeTaskDetailDelegate {
    
    func showTaskDetail(_ task: Task) {
        let vc = TaskDetailTableViewController(style: .insetGrouped)
        vc.task = task
        vc.taskDelegate = self
        let nav = UINavigationController(rootViewController: vc)
        
        vc.title = "Task"
        
        vc.detailDelegate = self
        
        self.present(nav, animated: true, completion: nil)
    }
    
    func didSelectTask(_ cell: HomeDashTaskOverviewCollectionViewCell, _ task: Task, _ at: IndexPath, animated: Bool) {
//        presentTaskDetail(task, animated: animated)
        
        let vc = TaskDetailTableViewController(style: .insetGrouped)
        vc.task = task
        vc.taskDelegate = self
        let nav = UINavigationController(rootViewController: vc)
        
        vc.title = "Task"
        
        vc.detailDelegate = self
        
        self.present(nav, animated: animated, completion: nil)
        
    }
    
    func didDeleteTask(_ task: Task) {
        reload()
    }
    
    func onSeeAllTasks(_ cell: HomeDashTaskOverviewCollectionViewCell) {
        // Scroll to task section (with animation)
        scrollToSection(1)
    }

    func onAddTask(_ cell: UICollectionViewCell?, completion: ((TaskAddViewController) -> Void)? = nil) {
        let task = presentTaskAdd()
        completion?(task)
    }
    
    /// Calculates the alpha value depending on a scroll offset
    /// - Parameter y: Scroll offset y
    /// - Returns: Returns the value of f(x) = 0.1 * x + 1 (clipped to [0, 1])
    private func calcuateNavBarBackgroundAlpha(_ y: CGFloat) -> CGFloat {
        let value = 0.013 * y + 1.067
        // Clip the value to [0, 1]
        return min(max(0, value), 1)
    }
    
    func didScroll(_ view: UIScrollView) {
        let offset = view.contentOffset.y
        
        // Just to avoid force unwrapping
        guard let nav = navigationController?.navigationBar else {
            return
        }
        // Improve performance/ efficiency by only updating in the necessary ranges
//        guard offset >= -100 && offset <= 150 else {
//            return
//        }
        // Calculate the alpha value for the current scrollview offset
        let alpha = calcuateNavBarBackgroundAlpha(offset)
        
        // Update the alpha of the navigation bar background view
        nav.subviews.first?.alpha = alpha
    }
}

extension HomeViewController: TaskOverviewTableviewCellDelegate {

    func onChange(_ cell: TaskOverviewTableViewCell) {
        reload()
    }
    
}
