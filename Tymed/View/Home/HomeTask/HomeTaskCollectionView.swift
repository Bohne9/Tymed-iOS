//
//  HomeTaskCollectionView.swift
//  Tymed
//
//  Created by Jonah Schueller on 27.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

private let nowReuseIdentifier = "homeNowCell"
private let taskTypeSelectorIdentifier = "taskTypeSelectorIdentifier"

private let typeSection = "typeSection"
private let addBtnSection = "addBtnSection"
private let todaySection = "todaySection"
private let allSection = "allSection"
private let doneSection = "doneSection"
private let expiredSection = "expiredSection"

class HomeTaskCollectionView: HomeBaseCollectionView {
    
    var cellColor: UIColor = .red
    
    var tasks: [Task]?
    
    //MARK: UI setup
    internal override func setupUserInterface() {
        super.setupUserInterface()
        
        register(HomeCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "homeHeader")
        register(HomeTaskCollectionViewCell.self, forCellWithReuseIdentifier: homeTaskCell)
        
        register(HomeDashTaskSelectorCollectionViewCell.self, forCellWithReuseIdentifier: taskTypeSelectorIdentifier)
        register(UINib(nibName: "HomeDashTaskOverviewCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: homeDashTaskOverviewCollectionViewCell)
        
        register(HomeDashTaskOverviewNoTasksCollectionViewCell.self, forCellWithReuseIdentifier: "noCell")
        
        
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            
            flowLayout.minimumInteritemSpacing = 16
            
        }
    }
    
    private func identifier(for indexPath: IndexPath) -> String {
        let identifier = self.section(for: indexPath.section)
        
        switch identifier {
        case typeSection:
            return taskTypeSelectorIdentifier
        case addBtnSection:
            return "noCell"
        case todaySection, allSection, doneSection, expiredSection:
            return homeDashTaskOverviewCollectionViewCell
        default:
            return ""
        }
        
    }
    
    //MARK: fetchData()
    internal override func fetchData() {
        
        tasks = TimetableService.shared.getTasks()
        
        sectionIdentifiers = []
        
        addSection(id: typeSection)
        addSection(id: addBtnSection)
        addSection(id: todaySection)
        addSection(id: allSection)
        addSection(id: doneSection)
        addSection(id: expiredSection)
        
    }
    
    // MARK: - UICollectionViewDataSource

    //MARK: numberOfItemsInSection
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let identifier = self.section(for: section)
        
        if identifier == typeSection {
            return 4
        }
        return 1
    }
    
    private func configureCell(_ cell: UICollectionViewCell, identifier: String, indexPath: IndexPath) {
        
        if identifier == taskTypeSelectorIdentifier {
            (cell as! HomeDashTaskSelectorCollectionViewCell).type = HomeDashTaskSelectorCellType(rawValue: indexPath.row)!
        }
        
    }
    
    //MARK: cellForItemAt
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let sectionId = self.section(for: indexPath)

        let identifier = self.identifier(for: indexPath)

        let cell = dequeueCell(identifier, indexPath)

        configureCell(cell, identifier: identifier, indexPath: indexPath)
        
        return cell

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
            case todaySection:
                header.label.text =  "Today"
            case allSection:
                header.label.text =  "All"
            case doneSection:
                header.label.text = "Done"
            case expiredSection:
                header.label.text = "Expired"
            default:
                header.label.text = ""
            }
            return header
        }
        
        return UICollectionReusableView()
    }
    
    //MARK: sizeForHeaderInSection
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        var height: CGFloat = 50
        let identifier = self.section(for: section)
        
        if identifier == typeSection || identifier == addBtnSection {
            height = 20
        }
        
        return CGSize(width: collectionView.frame.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let identifier = self.identifier(for: indexPath)
        
        print("hfopsda \(collectionView.contentSize)")
        
        var width: CGFloat = (collectionView.frame.width - 2 * 16)
        var height: CGFloat = 50
        
        if identifier == taskTypeSelectorIdentifier {
            width = (collectionView.frame.width - 56) / 2
        }
        
        if identifier == homeDashTaskOverviewCollectionViewCell {
            height = 60
        }
        
        return CGSize(width: width, height: height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        homeDelegate?.didScroll(scrollView)
    }
    
}

