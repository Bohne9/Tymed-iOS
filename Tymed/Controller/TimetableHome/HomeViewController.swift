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

    var dashCollectionView: HomeDashCollectionViewController = {
        let flowLayout = UICollectionViewFlowLayout()
        let homeDash = HomeDashCollectionViewController()
        homeDash.cellColor = .yellow
        
//        let nav = UINavigationController(navigationBarClass: NavigationBar.classForCoder(), toolbarClass: nil)
//        nav.setViewControllers([homeDash], animated: false)
        
        return homeDash
    }()
    
    var tasksCollectionView: HomeDashCollectionViewController = {
        let flowLayout = UICollectionViewFlowLayout()
        let homeDash = HomeDashCollectionViewController()
        homeDash.cellColor = .blue
        return homeDash
    }()
    
    var weekCollectionView: HomeWeekCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let homeWeek = HomeWeekCollectionView(frame: .zero
            , collectionViewLayout: flowLayout)
        
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
        // Do any additional setup after loading the view.
        
//        let subject = TimetableService.shared.addSubject("Database", "blue")
//
//        let start = TimetableService.shared.dateFor(hour: 12, minute: 30)
//        let end = TimetableService.shared.dateFor(hour: 14, minute: 0)
//
//        TimetableService.shared.addLesson(subject: subject, day: .monday, start: start, end: end)
//        TimetableService.shared.addLesson(subject: subject, day: .tuesday, start: start, end: end)
//        TimetableService.shared.addLesson(subject: subject, day: .monday, start: start, end: end)
//        TimetableService.shared.addLesson(subject: subject, day: .tuesday, start: start, end: end)
//        TimetableService.shared.addLesson(subject: subject, day: .monday, start: start, end: end)
//        TimetableService.shared.addLesson(subject: subject, day: .tuesday, start: start, end: end)
//        TimetableService.shared.addLesson(subject: subject, day: .monday, start: start, end: end)
//        TimetableService.shared.addLesson(subject: subject, day: .tuesday, start: start, end: end)
        
        //MARK: NavBar setup
        
        if let navBar = (navigationController?.navigationBar as? NavigationBar) {
            navBar.topBar.dash.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
            navBar.topBar.tasks.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
            navBar.topBar.week.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
        }
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        
        setupFlowLayout()
        
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        
        dashCollectionView.delegate = self
        tasksCollectionView.delegate = self
        weekCollectionView.delegate = self
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
        
        collectionView.scrollToItem(at: IndexPath(row: btn.tag, section: 0), at: .left, animated: true)
    }
    
    func reload() {
        dashCollectionView.reload()
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
        
        cell.backgroundColor = [.red, .yellow, .green][indexPath.row]
        
        if indexPath.row == 0 {
            cell.addSubview(dashCollectionView)
            
//            dashCollectionView.collectionView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 50, right: 0)
            dashCollectionView.translatesAutoresizingMaskIntoConstraints = false

            dashCollectionView.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
            dashCollectionView.leadingAnchor.constraint(equalTo: cell.leadingAnchor).isActive = true
            dashCollectionView.trailingAnchor.constraint(equalTo: cell.trailingAnchor).isActive = true
            dashCollectionView.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
            
        }
        
        if indexPath.row == 1 {
            cell.addSubview(tasksCollectionView)
            
            tasksCollectionView.translatesAutoresizingMaskIntoConstraints = false
            
//            tasksCollectionView.collectionView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 50, right: 0)
            tasksCollectionView.translatesAutoresizingMaskIntoConstraints = false
            
            tasksCollectionView.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
            tasksCollectionView.leadingAnchor.constraint(equalTo: cell.leadingAnchor).isActive = true
            tasksCollectionView.trailingAnchor.constraint(equalTo: cell.trailingAnchor).isActive = true
            tasksCollectionView.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
        }
        
        if indexPath.row == 2 {
            cell.addSubview(weekCollectionView)
            
            weekCollectionView.translatesAutoresizingMaskIntoConstraints = false
            
//            weekCollectionView.collectionView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 50, right: 0)
            weekCollectionView.translatesAutoresizingMaskIntoConstraints = false
            
            weekCollectionView.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
            weekCollectionView.leadingAnchor.constraint(equalTo: cell.leadingAnchor).isActive = true
            weekCollectionView.trailingAnchor.constraint(equalTo: cell.trailingAnchor).isActive = true
            weekCollectionView.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
        }
        
        return cell
    }
    
    //MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    
    //MARK: ScrollViewDelegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Calculate current page
        let page = Int((scrollView.contentOffset.x / scrollView.frame.width).rounded())
        if let navBar = navigationController?.navigationBar as? NavigationBar {
            navBar.topBar.highlightPage(page)
        }
    }
}

//MARK: HomeCollectionViewDelegate
extension HomeViewController: HomeCollectionViewDelegate {
    
    func lessonDetail(_ view: UIView, for lesson: Lesson) {
        
        let vc = LessonDetailCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        vc.lesson = lesson
        
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.barTintColor = UIColor(named: lesson.subject?.color ?? "dark") ?? UIColor(named: "dark")
        
        vc.title = lesson.subject?.name ?? "-"
        
        vc.delegate = self
        
        present(nav, animated: true, completion: nil)
        
    }
    
}


extension HomeViewController: LessonDetailCollectionViewControllerDelegate {
    
    func lessonDetailWillDismiss(_ viewController: LessonDetailCollectionViewController) {
        reload()
    }
    
}
