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

class HomeTaskCollectionView: HomeBaseCollectionView {
    
    var cellColor: UIColor = .red
    
    var tasks: [Task]?
    
    //MARK: UI setup
    internal override func setupUserInterface() {
        
        super.setupUserInterface()
        
        register(HomeCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "homeHeader")
        register(HomeTaskCollectionViewCell.self, forCellWithReuseIdentifier: homeTaskCell)
        
    }
    
    
    //MARK: fetchData()
    internal override func fetchData() {
        
        tasks = TimetableService.shared.getTasks()
        
        sectionIdentifiers = []
        
        addSection(id: nowSection)
        
    }
    
    // MARK: - UICollectionViewDataSource

    //MARK: numberOfItemsInSection
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let sectionId = self.section(for: section)
        
        switch sectionId {
            
        case nowSection:
            return tasks?.count ?? 0
        default:
            return 0
            
        }
    }
    
    //MARK: cellForItemAt
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let sectionId = self.section(for: indexPath)
        
        switch sectionId {
        case nowSection:
            let cell = dequeueCell(homeTaskCell, indexPath) as! HomeTaskCollectionViewCell
            
            cell.task = tasks?[indexPath.row]
            
            return cell
        default:
            return UICollectionViewCell()
        }
        
    }
    
    private func presentDetail(_ tasks: [Task]?, _ indexPath: IndexPath) {
        if let task = tasks?[indexPath.row] {
            homeDelegate?.taskDetail(self, for: task)
        }
    }
    
    //MARK: didSelectItemAt
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        presentDetail(tasks, indexPath)
        
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        homeDelegate?.didScroll(scrollView)
    }
    
}

