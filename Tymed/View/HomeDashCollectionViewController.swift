//
//  HomeDashCollectionViewController.swift
//  Tymed
//
//  Created by Jonah Schueller on 28.04.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

private let nowReuseIdentifier = "homeNowCell"

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
        
        collectionView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        
        collectionView.register(HomeDashNowCollectionViewCell.self, forCellWithReuseIdentifier: "celll")
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
    }
    
    private func fetchData() {
        
        lessons = TimetableService.shared.fetchLessons()
        
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lessons?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "celll", for: indexPath) as! HomeDashNowCollectionViewCell
    
        // Configure the cell
        
        cell.lesson = lessons?[indexPath.row]
    
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let lesson = lessons?[indexPath.row] {
            
            delegate?.lessonDetail(self, for: lesson)
            
        }
        
    }
    
 

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}


extension HomeDashCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 2 * 16, height: 80)
    }
    
}


class HomeDashNowCollectionViewCell: UICollectionViewCell {
    
    var lesson: Lesson? {
        didSet {
            guard let lesson = lesson else { return }
            
            name.text = lesson.subject?.name
            
            time.text = "\(lesson.dayOfWeek?.dayToStringShort() ?? "") - \(lesson.startTime?.timeToString() ?? "") - \(lesson.endDate?.timeToString() ?? "")"
            
            backgroundColor = UIColor(named: lesson.subject?.color ?? "dark") ?? UIColor(named: "dark")
        }
    }
    
    var name = UILabel()
    
    var time = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        addSubview(name)
        
        name.translatesAutoresizingMaskIntoConstraints = false
        
        name.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        name.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        name.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        name.textColor = UIColor.white
        
        addSubview(time)
        
        time.translatesAutoresizingMaskIntoConstraints = false
        
        time.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        time.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 5).isActive = true
        time.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        time.textColor = UIColor.white
        
        layer.cornerRadius = 10
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
