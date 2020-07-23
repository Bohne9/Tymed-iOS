//
//  TimetableAddViewController.swift
//  Tymed
//
//  Created by Jonah Schueller on 20.07.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

internal let titleCell = "titleCell"

class TimetableAddViewController: DynamicTableViewController {

    internal var timetable: Timetable?{
        didSet {
            reload()
        }
    }
    
    internal var timetableTitle: String?
    
    var timetableBaseDelegate: TimetableOverviewBaseDelegate?
    
    override func setup() {
        super.setup()
        
        setupNavigationBar()
        
        tableView.contentInset = UIEdgeInsets.zero
        
        register(TimetableDetailTitleTableViewCell.self, identifier: titleCell)
        
        addSection(with: "titleSection")
        addCell(with: titleCell, at: "titleSection")
    }
    
    //MARK: setupNavigationBar()
    internal func setupNavigationBar() {
        
        title = "Timetable"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let rightItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addTimetable))
        
        navigationItem.rightBarButtonItem = rightItem
        
        let leftItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        
        navigationItem.leftBarButtonItem = leftItem
        
    }
    
    internal func createTimetable() -> Timetable? {
        let timetable = TimetableService.shared.timetable()
        
        timetable.name = timetableTitle
        
        return timetable
    }
    
    override func configureCell(_ cell: UITableViewCell, for identifier: String, at indexPath: IndexPath) {
        
        if identifier == titleCell {
            let cell = (cell as! TimetableDetailTitleTableViewCell)
            
            cell.textField.text = timetable?.name
            
            cell.textField.addTarget(self, action: #selector(onTitleTextChanges(_:)), for: .editingChanged)
        }
        
    }
    
    override func heightForRow(at indexPath: IndexPath, with identifier: String) -> CGFloat {
        if identifier == titleCell {
            return 50
        }
        
        return 60
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    @objc func addTimetable() {
        guard createTimetable() != nil else {
            return
        }
        print("Adding timetable     ")
        TimetableService.shared.save()
        timetableBaseDelegate?.dismiss()
    }
    
    @objc func cancel() {
        timetableBaseDelegate?.dismiss()
    }

    @objc func onTitleTextChanges(_ textField: UITextField) {
        self.timetableTitle = textField.text
    }
}


