//
//  AddTableViewController.swift
//  Tymed
//
//  Created by Jonah Schueller on 02.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

let addReuseIdentifier = "addCell"
class AddCollectionViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        let rightItem = UIBarButtonItem(image: UIImage(systemName: "plus",
                                                       withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .bold)), style: .plain, target: self, action: #selector(showActionSheet))

        navigationItem.rightBarButtonItem = rightItem
        navigationController?.navigationBar.prefersLargeTitles = true
        
        title = "Timetable"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: addReuseIdentifier)

    }
    
    @objc func showActionSheet(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "What whould you like to add?", message: "", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Lesson", style: .default , handler:{ (action) in
            let lesson = UINavigationController(rootViewController: LessonAddViewController(style: .insetGrouped))
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
        
        if let popOver = alert.popoverPresentationController {
            popOver.barButtonItem = sender
        }
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
        
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: addReuseIdentifier, for: indexPath)
        
        cell.textLabel?.text = "Timetable"
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
