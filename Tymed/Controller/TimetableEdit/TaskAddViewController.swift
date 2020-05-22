//
//  TaskAddViewController.swift
//  Tymed
//
//  Created by Jonah Schueller on 22.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class TaskAddViewController: TymedTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func setup() {
        super.setup()
        
        setupNavigationBar()
    }

    internal func setupNavigationBar() {
        
        title = "Task"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let rightItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addTask))
        
        navigationItem.rightBarButtonItem = rightItem
        
        let leftItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        
        navigationItem.leftBarButtonItem = leftItem
    }

    @objc func addTask() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }

}
