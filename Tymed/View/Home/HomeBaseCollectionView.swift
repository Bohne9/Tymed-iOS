//
//  HomeBaseCollectionView.swift
//  Tymed
//
//  Created by Jonah Schueller on 24.06.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class HomeBaseCollectionView: UICollectionViewController, HomeViewSceneDelegate {

//    var homeDelegate: HomeCollectionViewDelegate?
//    var taskDelegate: HomeTaskDetailDelegate?
    
    var homeViewControllerDelegate: HomeViewControllerDelegate?
    
    var homeDelegate: HomeViewSceneDelegate?

    var sectionIdentifiers: [String] = []
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        
        homeDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
             
        setupUserInterface()
        fetchData()
        
    }
    
    internal func setupUserInterface() {
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 20
            
        }
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 50, right: 20)
        
        collectionView.layoutIfNeeded()
        
        collectionView.contentSize = collectionView.frame.size

        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.backgroundColor = .systemGroupedBackground
        
        collectionView.alwaysBounceVertical = true
        
    }
    
    //MARK: - Section helper
    
    /// Returns the section identifier for a given index
    /// - Parameter section: Index for the section
    /// - Returns: Section identifier for the section index
    internal func section(for section: Int) -> String {
        return sectionIdentifiers[section]
    }
    
    /// Returns the section identifier for a given index path section
    /// - Parameter indexPath: IndexPath of the section
    /// - Returns: Section identifier for the section of the index path
    internal func section(for indexPath: IndexPath) -> String {
        return section(for: indexPath.section)
    }
    
    /// Returns the index for a given identifier
    /// - Parameter identifier: Identifier of a section
    /// - Returns: Index of the section, Nil if the section doesn't exist
    internal func section(for identifier: String) -> Int? {
        return sectionIdentifiers.firstIndex(of: identifier)
    }
    
    /// Returns if the section at the given index matches a given identifier
    /// - Parameters:
    ///   - section: Index to match
    ///   - identifier: Identifier to match
    /// - Returns: Returns if the identifier at a given index matches a given identifier
    internal func section(at section: Int, is identifier: String) -> Bool {
        return self.section(for: section) == identifier
    }
    
    /// Returns if the section at the given index path matches a given identifier
    /// - Parameters:
    ///   - indexPath: Index path section to match
    ///   - identifier: Identifier to match
    /// - Returns: Returns if the identifier at a given index path section matches a given identifier
    internal func section(at indexPath: IndexPath, is identifier: String) -> Bool {
        return section(at: indexPath.section, is: identifier)
    }
    
    /// Adds a section to the collectionView
    /// - Parameter id: Identifier for the section
    internal func addSection(id: String) {
        sectionIdentifiers.append(id)
    }
    
    /// Fetches the data and reloads the collection view
    func reloadData() {
        fetchData()
        collectionView.reloadData()
    }
    
    func reload() {
        homeViewControllerDelegate?.reloadHomeView()
    }
    
    internal func fetchData() {
        
    }
    
    
    /// Dequeues a reuseable cell
    /// - Parameters:
    ///   - identifier: Cell identifier of the Cell
    ///   - indexPath: indexPath for the cell
    /// - Returns: Returns the dequeued cell
    internal func dequeueCell(_ identifier: String, _ indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection identifier: String) -> Int {
        fatalError("collectionView(..., numberOfItemsInSection) not implemented.")
    }

}

extension HomeBaseCollectionView {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionIdentifiers.count
    }
    
    
 
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let identifier = self.section(for: section)
        
        return self.collectionView(collectionView, numberOfItemsInSection: identifier)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    func present(_ viewController: UIViewController, animated: Bool) {
        viewController.presentationController?.delegate = self
        
        self.present(viewController, animated: animated, completion: nil)
    }
    
    func dismiss(_ animated: Bool) {
        dismiss(animated: animated, completion: nil)
    }
    
}

extension HomeBaseCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         return CGSize(width: collectionView.frame.width - 2 * 20, height: 80)
    }
    
}

extension HomeBaseCollectionView: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        reload()
    }
    
    
}

