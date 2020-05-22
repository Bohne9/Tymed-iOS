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

class LessonDetailCollectionViewController: LessonAddViewController {

    var lesson: Lesson?
    
    private var isEditable: Bool = false
    
    var delegate: LessonDetailCollectionViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationController?.presentationController?.delegate = self
        
        let item = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toogleEditing(_:)))
        
        navigationItem.rightBarButtonItem = item
        
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissDetailView))
        
        navigationItem.rightBarButtonItem = item
        navigationItem.leftBarButtonItem = cancel
        
        colorSectionIndex = 1
        timeSectionIndex = 2
        noteSectionIndex = 3
        
        addSection(with: "sec", at: 0)
        addCell(with: lessonTimeTitleCell, at: "sec")
        
        if let lesson = lesson {
//            selectColor(lesson.subject?.color)
            title = lesson.subject?.name
        }
        
        navigationController?.navigationBar.tintColor = .systemBlue
        
        // Do any additional setup after loading the view.
    }
    
    override func selectColor(_ colorName: String?) {
        
    }
    
    @objc func dismissDetailView() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func toogleEditing(_ btn: UIBarButtonItem) {
        
        isEditable.toggle()
        
        btn.title = isEditable ? "Save" : "Edit"
        btn.style = isEditable ? .done : .plain
        
        if !isEditable {
            expandStartTime = false
            expandEndTime = false
        }
        
        tableView.reloadData()
    }
    
    // Override necessary to not add the navigation bar title + text field toolbar of the superclass
    override func setupNavigationBar() {
        
    }
    
    override func headerForSection(with identifier: String, at index: Int) -> String? {
        if index == 0 {
            return "Tasks"
        }else {
            return super.headerForSection(with: identifier, at: index)
        }
    }

    override func configureCell(_ cell: UITableViewCell, for identifier: String, at indexPath: IndexPath) {
        super.configureCell(cell, for: identifier, at: indexPath)
        
        cell.selectionStyle = .none
        
        if indexPath.section == colorSectionIndex {
            cell.accessoryType = isEditable ? .disclosureIndicator : .none
        }
        
    }
    
    override func didSelectRow(at indexPath: IndexPath, with identifier: String) {
        
        guard isEditable else {
            return
        }
        
        if indexPath.section == 0 {
            
        }else {
            
            super.didSelectRow(at: indexPath, with: identifier)
            
        }
        
        
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let color = cell as? LessonColorPickerCell {
            color.accessoryType = .none
            color.selectColor(named: lesson?.subject?.color ?? "blue")
        }else if let time = cell as? LessonTimeTitleCell {
            if indexPath.row == 0 {
                time.title.text = "Start"
                time.value.text = lesson?.startTime.string()
            }else if indexPath.row == 1 {
                time.title.text = "End"
                time.value.text = lesson?.endTime.string()
            } else {
                time.title.text = "Day"
                time.value.text = lesson?.day.string()
            }
        }else if let note = cell as? LessonAddNoteCell {
            note.textView.text = lesson?.note ?? ""
            note.textView.isEditable = isEditable
        }
        
        cell.selectionStyle = .none
        
        return cell
    } */
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditable {
            super.tableView(tableView, didSelectRowAt: indexPath)
        }
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
