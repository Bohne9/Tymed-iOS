//
//  LessonDetailCollectionViewController.swift
//  Tymed
//
//  Created by Jonah Schueller on 03.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

private let lessonDeleteSection = "lessonDeleteSection"
private let lessonDeleteCell = "lessonDeleteCell"
private let lessonTaskOverviewCell = "lessonTaskOverviewCell"

protocol LessonDetailTableViewControllerDelegate {
    
    func lessonDetailWillDismiss(_ viewController: LessonDetailTableViewController)
    
}

class LessonDetailTableViewController: LessonAddViewController {

    var lesson: Lesson?
    
    private var isEditable: Bool = false
    
    private var lessonTaskOverviewIndex = 0
    private var lessonDeleteSecionIndex = 4
    
    var taskDelegate: HomeTaskDetailDelegate?
    var delegate: LessonDetailTableViewControllerDelegate?
    
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
        
        register(LessonDetailDeleteCell.self, identifier: lessonDeleteCell)
        register(LessonDetailTaskOverviewCell.self, identifier: lessonTaskOverviewCell)
        
        
        
        
        addSection(with: lessonDeleteSection)
        addCell(with: lessonDeleteCell, at: lessonDeleteSection)
        
        if let lesson = lesson {
//            selectColor(lesson.subject?.color)
            title = lesson.subject?.name
            
            if lesson.tasks?.count ?? 0 > 0 {
                addSection(with: "taskOverview", at: 0)
                addCell(with: lessonTaskOverviewCell, at: "taskOverview")
                
                colorSectionIndex = 1
                timeSectionIndex = 2
                noteSectionIndex = 3
            }
        }
        
        navigationController?.navigationBar.tintColor = .white
        
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
    
    // Do not call super class implementation to not add the navigation bar title + text field toolbar of the superclass
    override func setupNavigationBar() {
        navigationController?.navigationBar.backgroundColor = UIColor(lesson)
        navigationController?.navigationBar.barTintColor = UIColor(lesson)
        
        navigationController?.navigationBar.isTranslucent = false
        
    }
    
    override func headerForSection(with identifier: String, at index: Int) -> String? {
        if index == lessonTaskOverviewIndex {
            return "Tasks"
        } else if index == lessonDeleteSecionIndex {
            return nil
        } else {
            return super.headerForSection(with: identifier, at: index)
        }
    }

    //MARK: configureCell(_: ...)
    override func configureCell(_ cell: UITableViewCell, for identifier: String, at indexPath: IndexPath) {
        super.configureCell(cell, for: identifier, at: indexPath)
        
        cell.selectionStyle = .none
        
        
        if identifier == lessonDeleteCell {
            setupDeleteCell(cell)
        }
        // Configure isEditable
        if indexPath.section == colorSectionIndex {
            cell.accessoryType = isEditable ? .disclosureIndicator : .none // chrevron icon if isEditable
        }
        
        if indexPath.section == noteSectionIndex {
            (cell as! LessonAddNoteCell).textView.isEditable = isEditable // Make textView editable if isEditable
        }
        
        //MARK: lesson value setup
        // Break if there is no cell configured
        guard let lesson = self.lesson else {
            return
        }
        
        // Set the values of the cells to the value of the lesson
        switch identifier {
        case lessonTaskOverviewCell:
            guard indexPath.section == lessonTaskOverviewIndex else {
                break
            }
            let cell = cell as! LessonDetailTaskOverviewCell
            
            cell.lesson = lesson
            cell.taskDelegate = taskDelegate
            
            break
        case lessonColorPickerCell:
            guard indexPath.section == colorSectionIndex else {
                break
            }
            // Configure subject color
            (cell as! LessonColorPickerCell).selectColor(named: lesson.subject?.color ?? "dark")
            break
        case lessonTimeTitleCell:
            guard indexPath.section == timeSectionIndex else {
                break
            }
            // Set the values of the time/ day title cells
            let cell = cell as! LessonTimeTitleCell
            let row = indexPath.row
            
            if row == 0 {
                cell.value.text = lesson.startTime.string()
            }else if (row == 1 && !expandStartTime) || (row == 2 && expandStartTime) {
                cell.value.text = lesson.endTime.string()
            }else {
                cell.value.text = lesson.day.string()
            }
            break
        case lessonTimePickerCell:
            guard indexPath.section == timeSectionIndex else {
                break
            }
            // Set the values of the time pickers
            let cell = cell as! LessonTimePickerCell
            
            if indexPath.row == 1 {
                cell.datePicker.date = lesson.startTime.date ?? Date()
            }else {
                cell.datePicker.date = lesson.endTime.date ?? Date()
            }
            break
        case lessonDayPickerCell:
            guard indexPath.section == timeSectionIndex else {
                break
            }
            // Set the values of the day picker
            let cell = cell as! LessonDayPickerCell
            cell.picker.selectRow(lesson.day == .sunday ? 6 : lesson.day.rawValue - 2, inComponent: 0, animated: false)
        case lessonNoteCell:
            guard indexPath.section == noteSectionIndex else {
                break
            }
            // Set the value of the note cell
            (cell as! LessonAddNoteCell).textView.text = lesson.note ?? ""
            break
        default:
            break
        }
        
    }
    //MARK: didSelectRow(at: , with:)
    override func didSelectRow(at indexPath: IndexPath, with identifier: String) {
        
        guard isEditable else {
            return
        }
        
        if indexPath.section == 0 {
            
        }else {
            if identifier == lessonColorPickerCell {
                lessonColor = lesson?.subject?.color ?? "blue"
            }
            
            super.didSelectRow(at: indexPath, with: identifier)
            
        }
        
    }
    
    private func setupDeleteCell(_ cell: UITableViewCell) {
        
        guard let deleteCell = cell as? LessonDetailDeleteCell else {
            return
        }
        
        deleteCell.deleteButton.addTarget(self, action: #selector(showDeleteConfirm), for: .touchUpInside)
        
    }
    
    @objc func showDeleteConfirm(_ sender: UIButton) {
        
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
        
        if let popOver = alert.popoverPresentationController {
            popOver.sourceView = sender
        }
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    override func heightForRow(at indexPath: IndexPath, with identifier: String) -> CGFloat {
        if identifier != lessonTaskOverviewCell {
            return super.heightForRow(at: indexPath, with: identifier)
        }
        // From here the row must be a lessonTaskOverviewCell
        
        let count = min(3, lesson?.tasks?.count ?? 0)
        
        return CGFloat(20 + count * 60)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditable {
            super.tableView(tableView, didSelectRowAt: indexPath)
        }
    }

  
}



class LessonDetailDeleteCell: UITableViewCell {
    
    let deleteButton = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        
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


extension LessonDetailTableViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        delegate?.lessonDetailWillDismiss(self)
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        delegate?.lessonDetailWillDismiss(self)
    }
    
    
}
