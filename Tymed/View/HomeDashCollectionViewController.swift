//
//  HomeDashCollectionViewController.swift
//  Tymed
//
//  Created by Jonah Schueller on 28.04.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

private let nowReuseIdentifier = "homeNowCell"

private let nowSection = "nowSection"
private let nextSection = "nextSection"

class HomeDashCollectionViewController: UIView, UICollectionViewDataSource, UICollectionViewDelegate {

    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: self.frame, collectionViewLayout: UICollectionViewFlowLayout())
        
        view.delegate = self
        view.dataSource = self
        
        return view
    }()
    
    var cellColor: UIColor = .red
    
    var delegate: HomeCollectionViewDelegate?
    
    var subjects: [Subject]?
    var lessons: [Lesson]?
    
    var nowLessons: [Lesson]?
    
    var sectionIdentifiers: [String] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUserInterface()
        
        fetchData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUserInterface() {
        
        addSubview(collectionView)
        
        collectionView.backgroundColor = .systemBackground
        
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        collectionView.register(HomeDashCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "homeHeader")
        collectionView.register(HomeLessonCollectionViewCell.self, forCellWithReuseIdentifier: homeLessonCell)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
    }
    
    func reload() {
        fetchData()
        
        collectionView.reloadData()
    }
    
    private func fetchData() {
        
        lessons = TimetableService.shared.fetchLessons()
        
        nowLessons = TimetableService.shared.getLessons(within: Date()).sorted(by: { (l1, l2) in
            return l1.startTime < l2.startTime
        })
        
        sectionIdentifiers = []
        
        if (nowLessons?.count ?? 0) > 0 {
            sectionIdentifiers.append(nowSection)
        }
        
        if (lessons?.count ?? 0) > 0 {
            sectionIdentifiers.append(nextSection)
        }
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        
        
        
        return ((nowLessons?.count ?? 0) > 0 ? 1 : 0) + ((lessons?.count ?? 0) > 0 ? 1 : 0)
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return nowLessons?.count ?? 0
        }else if section == 1 {
            return lessons?.count ?? 0
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeLessonCell, for: indexPath) as! HomeLessonCollectionViewCell
            
            // Configure the cell
            
            cell.lesson = nowLessons?[indexPath.row]
            
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeLessonCell, for: indexPath) as! HomeLessonCollectionViewCell
            
            // Configure the cell
            
            cell.lesson = lessons?[indexPath.row]
            
            return cell
        }
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let lesson = lessons?[indexPath.row] {
            
            delegate?.lessonDetail(self, for: lesson)
            
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "homeHeader", for: indexPath) as! HomeDashCollectionViewHeader
            
            if indexPath.section == 0 {
                header.label.text = "Now"
            }else {
                header.label.text = "All"
            }
            
            return header
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
}


extension HomeDashCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 2 * 16, height: 80)
    }

}


//MARK: HomeDashCollectionViewHeader
class HomeDashCollectionViewHeader: UICollectionReusableView  {
    
    var label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.topAnchor.constraint(equalTo: topAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}




