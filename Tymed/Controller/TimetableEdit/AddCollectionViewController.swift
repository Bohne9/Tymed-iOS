//
//  AddTableViewController.swift
//  Tymed
//
//  Created by Jonah Schueller on 02.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class LessonAddNavigationbar: UINavigationBar {
    
    let textField = UITextField()
    
    override var prefersLargeTitles: Bool  {
        
        didSet {
            print("navvar big title - \(prefersLargeTitles)")
        }
    }
    
    override var frame: CGRect {
        
        didSet {
            print(frame.height)
            
            if frame.height < 50 {
                
                textField.font = UIFont.preferredFont(forTextStyle: .headline)
                bottomOffsetConstraint?.constant = 0
            }else if frame.height > 85 {
                textField.layer.contentsScale = max(1, frame.height / 100)
            }else {
                textField.font = UIFont.preferredFont(forTextStyle: .largeTitle)
                bottomOffsetConstraint?.constant = -10
            }
            
            
        }
    }
    
    
    private var bottomOffsetConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prefersLargeTitles = true
        
        isTranslucent = false
        
        addSubview(textField)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = backgroundColor
        
        textField.placeholder = "subject name"
        
        sendSubviewToBack(textField)
        
        textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        textField.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        bottomOffsetConstraint = textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        bottomOffsetConstraint?.isActive = true
        
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        textField.font = UIFont.preferredFont(forTextStyle: .largeTitle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

let addReuseIdentifier = "addCell"
class AddCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        let rightItem = UIBarButtonItem(image: UIImage(systemName: "plus",
                                                       withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .bold)), style: .plain, target: self, action: #selector(showActionSheet))

        navigationItem.rightBarButtonItem = rightItem
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: addReuseIdentifier)

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func showActionSheet() {
        
        let alert = UIAlertController(title: "", message: "What whould you like to add?", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Lesson", style: .default , handler:{ (action) in
            let lesson = UINavigationController(rootViewController: LessonAddViewController(style: .grouped))
            self.present(lesson, animated: true, completion: nil)
        }))

        alert.addAction(UIAlertAction(title: "Task", style: .default , handler:{ (action) in
            print("Add task")
        }))

        alert.addAction(UIAlertAction(title: "Timetable", style: .default , handler:{ (action) in
            print("Timetable btn")
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (action) in
            print("Dismiss")
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
        
        
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 20
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: addReuseIdentifier, for: indexPath)
    
        // Configure the cell
        cell.backgroundColor = .red
    
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
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
