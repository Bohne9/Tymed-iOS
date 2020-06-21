//
//  HomeTaskCollectionView.swift
//  Tymed
//
//  Created by Jonah Schueller on 27.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

private let nowReuseIdentifier = "homeNowCell"

private let nowSection = "nowSection"
private let nextSection = "nextSection"
private let weekSection = "weekSection"

class HomeTaskCollectionView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {

    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: self.frame, collectionViewLayout: UICollectionViewFlowLayout())
        
        view.delegate = self
        view.dataSource = self
        
        view.alwaysBounceVertical = true
        
        return view
    }()
    
    var cellColor: UIColor = .red
    
    var delegate: HomeCollectionViewDelegate?
    
    var tasks: [Task]?
    
    var sectionIdentifiers: [String] = []
    
    //MARK: init(frame: )
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUserInterface()
        
        fetchData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: UI setup
    private func setupUserInterface() {
        
        addSubview(collectionView)
        
        collectionView.backgroundColor = .systemGroupedBackground
        
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        collectionView.register(HomeCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "homeHeader")
        collectionView.register(HomeTaskCollectionViewCell.self, forCellWithReuseIdentifier: homeTaskCell)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
    }
    
    //MARK: - Section helper
    private func section(for section: Int) -> String {
        return sectionIdentifiers[section]
    }
    
    private func section(for indexPath: IndexPath) -> String {
        return section(for: indexPath.section)
    }
    
    private func section(for identifier: String) -> Int? {
        return sectionIdentifiers.firstIndex(of: identifier)
    }
    
    private func section(at section: Int, is identifier: String) -> Bool {
        return self.section(for: section) == identifier
    }
    
    private func section(at indexPath: IndexPath, is identifier: String) -> Bool {
        return section(at: indexPath.section, is: identifier)
    }
    
    private func addSection(id: String) {
        sectionIdentifiers.append(id)
    }
    
    //MARK: reload()
    func reload() {
        fetchData()
        collectionView.reloadData()
    }
    
    //MARK: fetchData()
    private func fetchData() {
        
        tasks = TimetableService.shared.getTasks()
        
//        nowLessons = TimetableService.shared.getLessons(within: Date()).sorted(by: { (l1, l2) in
//            return l1.startTime < l2.startTime
//        })
        
        sectionIdentifiers = []
        
        addSection(id: nowSection)
        
        /*
        // If there are lessons right now show the "now" section, else show the next
        if (nowLessons?.count ?? 0) > 0 {
            addSection(id: nowSection)
        }
        else {
            let today = Day.current
        
            nextLessons = lessons?.sorted(by: { (l1, l2) in // Sort the lessons so that the next lessons are in front
                // If the lesson is on an previous day, rotate the day to next week
                let d1 = l1.day.rawValue + (l1.day < today ? 7 : 0)
                let d2 = l2.day.rawValue + (l2.day < today ? 7 : 0)
                
                if d1 != d2 { // Check if the lessons are on different days
                    return d1 < d2
                }
                // From here the lessons are on the same day
                if l1.startTime != l2.startTime { // Check if the lessons start on different times
                    return l1.startTime < l2.startTime
                }
                return l1.endTime < l2.endTime // The lesson that ends first is the prefered
            })
            
            
            if (nextLessons?.count ?? 0) > 0 {
                addSection(id: nextSection)
            }
        }
        
        if (lessons?.count ?? 0) > 0 {
            addSection(id: weekSection)
        }
 */
        
    }
    
    // MARK: - UICollectionViewDataSource
    
    
    
    //MARK: numberOfSections
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionIdentifiers.count
    }

    //MARK: numberOfItemsInSection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let sectionId = self.section(for: section)
        
        switch sectionId {
            
        case nowSection:
            return tasks?.count ?? 0
//        case nextSection:
//            return nextLessons?.count ?? 0
//        case weekSection:
//            return lessons?.count ?? 0
        default:
            return 0
            
        }
    }
    
    
    private func dequeueCell(_ identifier: String, _ indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }
    
    //MARK: cellForItemAt
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let sectionId = self.section(for: indexPath)
        
        switch sectionId {
        case nowSection:
            let cell = dequeueCell(homeTaskCell, indexPath) as! HomeTaskCollectionViewCell
            
            cell.task = tasks?[indexPath.row]
            
            return cell
//        case nextSection:
//            let cell = dequeueCell(homeLessonCell, indexPath) as! HomeLessonCollectionViewCell
//
//            cell.lesson = nextLessons?[indexPath.row]
//
//            return cell
//        case weekSection:
//            let cell = dequeueCell(homeLessonCell, indexPath) as! HomeLessonCollectionViewCell
//
//            cell.lesson = lessons?[indexPath.row]
//
//            return cell
        default:
            return UICollectionViewCell()
        }
        
    }
    
    private func presentDetail(_ tasks: [Task]?, _ indexPath: IndexPath) {
        if let task = tasks?[indexPath.row] {
            delegate?.taskDetail(self, for: task)
        }
    }
    
    //MARK: didSelectItemAt
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let sectionId = self.section(for: indexPath)
        
        presentDetail(tasks, indexPath)
//        switch sectionId {
//        case nowSection:
//            presentDetail(nowLessons, indexPath)
//            break
//        case nextSection:
//            presentDetail(nextLessons, indexPath)
//            break
//        case weekSection:
//            presentDetail(lessons, indexPath)
//            break
//        default:
//            break
//        }
        
    }

    //MARK: supplementaryView
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "homeHeader", for: indexPath) as! HomeCollectionViewHeader
            
            let sectionId = section(for: indexPath)
            
            switch sectionId{
            case nowSection:
                header.label.text =  "Now"
            case nextSection:
                header.label.text =  "Next"
            case weekSection:
                header.label.text = "All"
            default:
                header.label.text = "-"
            }
            return header
        }
        
        return UICollectionReusableView()
    }
    
    //MARK: sizeForHeaderInSection
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
}

extension HomeTaskCollectionView: UICollectionViewDelegateFlowLayout {
    
    //MARK: sizeForItemAt
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 2 * 16, height: 80)
    }

}
