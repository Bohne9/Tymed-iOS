//
//  LessonDetailTaskOverviewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 28.06.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

private let taskOverviewItem = "taskOverviewItem"
class LessonDetailTaskOverviewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    

    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        
        return tableView
    }()
    
    var lesson: Lesson? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        contentView.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.constraintToSuperview(top: 10, bottom: 10, leading: 20, trailing: 20)
        
        tableView.register(TaskOverviewTableViewCell.self, forCellReuseIdentifier: taskOverviewItem)
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let lesson = lesson else {
            return 0
        }
        let count = lesson.tasks?.count ?? 0
        return min(count, 3)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: taskOverviewItem, for: indexPath) as! TaskOverviewTableViewCell
        
        guard let lesson = self.lesson else {
            return cell
        }
        
        guard let tasks = lesson.tasks else {
            return cell
        }
        
        let task = tasks.allObjects as! [Task]
        cell.reload(task[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
