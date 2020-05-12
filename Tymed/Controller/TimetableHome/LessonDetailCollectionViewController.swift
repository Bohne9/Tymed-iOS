//
//  LessonDetailCollectionViewController.swift
//  Tymed
//
//  Created by Jonah Schueller on 03.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

private let lessonDeleteCell = "lessonDeleteCell"

protocol LessonDetailCollectionViewControllerDelegate {
    
    func lessonDetailWillDismiss(_ viewController: LessonDetailCollectionViewController)
    
}

class LessonDetailCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var lesson: Lesson?
    
    var delegate: LessonDetailCollectionViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationController?.presentationController?.delegate = self
        
        // Register cell classes
        self.collectionView!.register(LessonDetailDeleteCell.self, forCellWithReuseIdentifier: lessonDeleteCell)

        // Do any additional setup after loading the view.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Configure the cell
        
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: lessonDeleteCell, for: indexPath)
            
            setupDeleteCell(cell)
            
            return cell
        }
        
        return UICollectionViewCell(frame: .zero)
    }
    
    private func setupDeleteCell(_ cell: UICollectionViewCell) {
        
        guard let deleteCell = cell as? LessonDetailDeleteCell else {
            return
        }
        
        deleteCell.deleteButton.addTarget(self, action: #selector(showDeleteConfirm), for: .touchUpInside)
        
    }
    
    @objc func showDeleteConfirm() {
        
        let alert = UIAlertController(title: "", message: "Are you sure?", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive , handler:{ (action) in
            // Delete lesson
            if let lesson = self.lesson {
                TimetableService.shared.deleteLesson(lesson)
                self.lesson = nil
                self.dismiss(animated: true) {
                    self.delegate?.lessonDetailWillDismiss(self)
                }
                print("delete")
            }
        }))

        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (action) in
            print("Dismiss")
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
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
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
    }

}



class LessonDetailDeleteCell: UICollectionViewCell {
    
    let deleteButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    private func setupView() {
        
        addSubview(deleteButton)
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setTitle("Delete", for: .normal)
        
        deleteButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        deleteButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        deleteButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
        deleteButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        deleteButton.setTitleColor(.red, for: .normal)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension LessonDetailCollectionViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        delegate?.lessonDetailWillDismiss(self)
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        delegate?.lessonDetailWillDismiss(self)
    }
    
    
}
