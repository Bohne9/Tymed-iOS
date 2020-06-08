//
//  HomeDashTaskOverviewCollectionViewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 16.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

let homeDashTaskOverviewCollectionViewCell = "homeDashTaskOverviewCollectionViewCell"
class HomeDashTaskOverviewCollectionViewCell: HomeBaseCollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    
    static func register(_ collectionView: UICollectionView) {
        collectionView.register(HomeDashTaskOverviewCollectionViewCell.self, forCellWithReuseIdentifier: homeDashTaskOverviewCollectionViewCell)
    }
    
    var tasks: [Task]?
        
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func onSeeAll(_ sender: Any) {
    
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.backgroundColor = .secondarySystemGroupedBackground
        
        tableView.register(HomeDashTaskOverviewCollectionViewCellItem.self, forCellReuseIdentifier: "homeTaskItem")
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func reload() {
        super.reload()
        
//        guard stackView != nil else {
//            return
//        }
        tableView.reloadData()
        // Add the first three tasks to the stackView
//        tasks.prefix(3).forEach { addTaskView($0) }
        
    }
        
    private func clearTasks() {
        
//        stackView.arrangedSubviews.forEach { (subview) in
//            stackView.removeArrangedSubview(subview)
//            subview.removeFromSuperview()
//        }
        
    }
    
//    private func addTaskView(_ task: Task) {
//        if stackView?.arrangedSubviews.count != 0 {
//            let lineView = UIView()
//            stackView.addArrangedSubview(lineView)
//            lineView.translatesAutoresizingMaskIntoConstraints = false
//            lineView
//            lineView.constraintTrailingToSuperview(constant: 0)
//            lineView.constraint(height: 1)
//            lineView.backgroundColor = .red
//            lineView.layer.borderWidth = 1.0
//            lineView.layer.borderColor = UIColor.systemGray3.cgColor
//
//
//        }
//
//        let view = HomeDashTaskOverviewCollectionViewCellItem(task)
//        stackView.addArrangedSubview(view)
//
//    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(tasks?.count ?? 0, 3)
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeTaskItem", for: indexPath) as! HomeDashTaskOverviewCollectionViewCellItem
    
        cell.reload(tasks![indexPath.row])
        
        return cell
    }
   
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}


class HomeDashTaskOverviewCollectionViewCellItem: UITableViewCell {
    
    var task: Task!
    
    var complete = UIButton()
    var label = UILabel()
    var subjectIndicator = UIView()
    
    
    
//    init(_ task: Task) {
//        self.task = task
//        super.init(style: .default, reuseIdentifier: "homeTaskItem")
//
//        configureUserInterface()
//    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureUserInterface()
    }
    
    func reload(_ task: Task) {
        self.task = task
        
        let image = UIImage(systemName: task.completed ? "largecircle.fill.circle" : "circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold))
        complete.setImage(image, for: .normal)
        
        label.text = task.title
        
        subjectIndicator.backgroundColor = UIColor(named: task.lesson?.subject?.color ?? "") ?? UIColor.blue
    }
    
    private func configureUserInterface() {
        addSubview(complete)
        
        addSubview(label)
        
        addSubview(subjectIndicator)
        
        backgroundColor = .secondarySystemGroupedBackground
        contentView.backgroundColor = .secondarySystemGroupedBackground
        
        complete.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        subjectIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        
        complete.constraintLeadingToSuperview(constant: -6 )
        complete.constraint(width: 44, height: 44)
        complete.constraintCenterYToSuperview(constant: 0)
        
        complete.addTarget(self, action: #selector(completeTap), for: .touchUpInside)
        
        subjectIndicator.constraint(width: 10, height: 10)
        subjectIndicator.constraintTrailingToSuperview(constant: 12)
        subjectIndicator.constraintCenterYToSuperview(constant: 0)
        
        label.constraintLeadingTo(anchor: complete.trailingAnchor, constant: 5)
        label.constraintHeightToSuperview()
        label.constraintTrailingTo(anchor: subjectIndicator.leadingAnchor, constant: 5)
        label.constraintCenterYToSuperview(constant: 0)
        
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        subjectIndicator.layer.cornerRadius = 5
        
    }
    
    @objc func completeTap() {
        task.completed.toggle()
        
        let image = UIImage(systemName: task.completed ? "largecircle.fill.circle" : "circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold))
        complete.setImage(image, for: .normal)
        
        if task.completed {
            UIView.transition(with: label, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.label.text = ((self.task.title ?? "") + " 👏")
            }, completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    UIView.transition(with: self.label, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        self.label.text = self.task.title
                    }, completion: nil)
                }
                
            })
        }
        
        layoutIfNeeded()
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
