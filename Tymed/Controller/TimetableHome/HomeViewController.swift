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
        let flowLayout = UICollectionViewFlowLayout()
        let homeDash = HomeDashCollectionView()
        
        return homeDash
    }()
    
    var tasksCollectionView: HomeTaskCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
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
        // Do any additional setup after loading the view.
        
//        let subject = TimetableService.shared.addSubject("Programming", "orange")
////
//        let start = TimetableService.shared.dateFor(hour: 12, minute: 30)
//        let end = TimetableService.shared.dateFor(hour: 14, minute: 0)
//
//        TimetableService.shared.addLesson(subject: subject, day: .monday, start: start, end: end)
//        TimetableService.shared.addLesson(subject: subject, day: .tuesday, start: start, end: end)
//        TimetableService.shared.addLesson(subject: subject, day: .wednesday, start: start, end: end)
//        TimetableService.shared.addLesson(subject: subject, day: .thursday, start: start, end: end)
//        TimetableService.shared.addLesson(subject: subject, day: .friday, start: start, end: end)
//        TimetableService.shared.addLesson(subject: subject, day: .saturday, start: start, end: end)
//        TimetableService.shared.addLesson(subject: subject, day: .sunday, start: start, end: end)
//        TimetableService.shared.addLesson(subject: subject, day: .wednesday, start: start, end: end)
//        
        //MARK: NavBar setup
        
        if let navBar = (navigationController?.navigationBar as? NavigationBar) {
            navBar.topBar.dash.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
            navBar.topBar.tasks.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
            navBar.topBar.week.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
            navBar.barTintColor = .systemGroupedBackground
        }
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        
        setupFlowLayout()
        
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .systemGroupedBackground
        
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
        
        let vc = LessonDetailCollectionViewController(style: .insetGrouped)
        vc.lesson = lesson
        
        let nav = UINavigationController(rootViewController: vc)
        
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
