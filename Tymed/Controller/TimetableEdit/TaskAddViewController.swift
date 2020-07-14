//
//  TaskAddViewController.swift
//  Tymed
//
//  Created by Jonah Schueller on 22.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

internal let taskTitleCell = "taskTitleCell"
internal let taskDescriptionCell = "taskDescriptionCell"
internal let taskDueDateTitleCell = "taskDueDateTitleCell"
internal let taskDueDateCell = "taskDueDateCell"
internal let taskAttachLessonCell = "taskAttchLessonCell"
internal let taskAttachedLessonCell = "taskAttachedLessonCell"
internal let taskNotifiactionCell = "taskNotifiactionCell"
internal let taskNotificationTitleCell = "taskNotificationTitleCell"
internal let taskNotificationDatePickerCell = "taskNotificationDatePickerCell"

internal let titleSection = "titleSection"
internal let descriptionSection = "descriptionSection"
internal let lessonSection = "lessonSection"
internal let dueSection = "dueSection"
internal let deleteSection = "deleteSection"

//MARK: TaskAddViewController
class TaskAddViewController: DynamicTableViewController, TaskLessonPickerDelegate, UITextViewDelegate {

    private var expandDueDateCell = false
    
    internal var taskTitle: String?
    internal var taskDescription: String?
    
    internal var lesson: Lesson?
    
    internal var dueDate: Date?
    
    internal var taskTitleSection = 0
    internal var taskDescriptionSection = 1
    internal var taskLessonSection = 2
    internal var taskDueSection = 3
    
    var detailDelegate: HomeDetailTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.presentationController?.delegate = self
    }

    override func setup() {
        super.setup()
        
        setupNavigationBar()
        
        
    }

    //MARK: setupNavigationBar()
    internal func setupNavigationBar() {
        
        title = "Task"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let rightItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addTask))
        
        navigationItem.rightBarButtonItem = rightItem
        
        let leftItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        
        navigationItem.leftBarButtonItem = leftItem
        
        register(UINib(nibName: "TaskTitleTableViewCell", bundle: nil), identifier: taskTitleCell)
        register(UINib(nibName: "TaskDescriptionTableViewCell", bundle: nil), identifier: taskDescriptionCell)
        register(UINib(nibName: "TaskDueDateTableViewCell", bundle: nil), identifier: taskDueDateCell)
        register(UINib(nibName: "TaskDueDateTitleTableViewCell", bundle: nil), identifier: taskDueDateTitleCell)
        register(UINib(nibName: "TaskLessonAttachTableViewCell", bundle: nil), identifier: taskAttachLessonCell)
        register(TaskAttachedLessonTableViewCell.self, identifier: taskAttachedLessonCell)
        register(UINib(nibName: "TaskNotificationTitleTableViewCell", bundle: nil), identifier: taskNotifiactionCell)
        register(UINib(nibName: "TaskDueDateTitleTableViewCell", bundle: nil), identifier: taskNotificationTitleCell)
        
        addSection(with: titleSection)
        addCell(with: taskTitleCell, at: titleSection)
        
        addSection(with: descriptionSection)
        addCell(with: taskDescriptionCell, at: descriptionSection)
        
        addSection(with: lessonSection)
        addCell(with: taskAttachLessonCell, at: lessonSection)
        
        addSection(with: dueSection)
        addCell(with: taskDueDateTitleCell, at: dueSection)
        addCell(with: taskNotifiactionCell, at: dueSection)
    }

    @objc func changeTaskTitle(_ textField: UITextField) {
        taskTitle = textField.text
    }
    
    func textViewDidChange(_ textView: UITextView) {
        taskDescription = textView.text
    }
    
    private func getTaskTitleCell() -> TaskTitleTableViewCell? {
        tableView.cellForRow(at: IndexPath(row: 0, section: taskTitleSection)) as? TaskTitleTableViewCell
    }
    
    private func validateValues() -> Bool {
        
        // There is no subject name
        if taskTitle == nil || taskTitle?.isEmpty == true, let cell = getTaskTitleCell() {
            
            // Give feedback via taptic engine
            tapticErrorFeedback()
            
            // Highlight the textfield red for a second to show the user where the error occured
            viewTextColorErrorAnimation(for: cell.textField, UIColor.red.withAlphaComponent(0.6)) { (color) -> UIColor? in
                
                cell.textField.attributedPlaceholder = NSAttributedString(string: "Task title...", attributes: [NSAttributedString.Key.foregroundColor: color ?? .placeholderText ])
                
                return UIColor.placeholderText
            }
            
            return false
        }
        
        return true
    }
    
    //MARK: addTask()
    @objc func addTask() {
        guard validateValues() else {
            print("Task validation failed")
            return
        }
        
        let task = TimetableService.shared.task()
        
        task.completed = false
        task.due = dueDate
        task.lesson = lesson
        task.priority = 0
        task.title = taskTitle ?? ""
        task.text = taskDescription
        
        TimetableService.shared.save()
        
        NotificationService.current.scheduleDueDateNotification(for: task)
        
        detailDelegate?.detailWillDismiss(self)
        
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: cancel()
    @objc func cancel() {
        detailDelegate?.detailWillDismiss(self)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func updateDueDate(_ picker: UIDatePicker) {
        dueDate = picker.date
        reload()
    }
    
    //MARK: headerForSection(with: , at:)
    override func headerForSection(with identifier: String, at index: Int) -> String? {
        switch identifier {
        case titleSection:
            return ""
        case descriptionSection:
            return "Description"
        case lessonSection:
            return "Lesson"
        case dueSection:
            return "Due date"
        default:
            return ""
        }
    }
    
    override func iconForSection(with identifier: String, at index: Int) -> String? {
        switch identifier {
        case titleSection:
            return ""
        case descriptionSection:
            return "text.alignleft"
        case lessonSection:
            return "doc.text"
        case dueSection:
            return "timer"
        default:
            return ""
        }
    }
    
    //MARK: removeLesson()
    @objc func removeLesson() {
        
        lesson = nil
        removeCell(at: taskLessonSection, row: 0)
        addSection(with: lessonSection, at: taskLessonSection)
        tableView.deleteRows(at: [IndexPath(row: 0, section: taskLessonSection)], with: .fade)
        addCell(with: taskAttachLessonCell, at: lessonSection)
        tableView.insertRows(at: [IndexPath(row: 0, section: taskLessonSection)], with: .fade)
         
    }
    
    //MARK: configureCell(cell: ,...)
    override func configureCell(_ cell: UITableViewCell, for identifier: String, at indexPath: IndexPath) {
        
        if identifier == taskTitleCell {
            let cell = cell as! TaskTitleTableViewCell
            cell.setCompleteBtn(active: false)
            cell.textField.addTarget(self, action: #selector(changeTaskTitle(_:)), for: .editingChanged)
        } else if identifier == taskDescriptionCell {
            let cell = cell as! TaskDescriptionTableViewCell
            
            cell.textView.delegate = self
        } else if identifier == taskAttachLessonCell {
            let cell = cell as! TaskLessonAttachTableViewCell
            cell.attchLesson.addTarget(self, action: #selector(showLessonPicker), for: .touchUpInside)
        } else if identifier == taskAttachedLessonCell {
            let cell = cell as! TaskAttachedLessonTableViewCell
            
            cell.removeBtn.addTarget(self, action: #selector(removeLesson), for: .touchUpInside)
            
            cell.setLesson(lesson)
        } else if identifier == taskDueDateTitleCell {
            let cell = cell as! TaskDueDateTitleTableViewCell
            
            cell.titleLabel.text = "Due"
            cell.valueLabel.text = dueDate?.stringify(dateStyle: .short, timeStyle: .short) ?? "-"
        } else if identifier == taskDueDateCell {
            let cell = cell as! TaskDueDateTableViewCell
            
            cell.dueDate.addTarget(self, action: #selector(updateDueDate(_:)), for: .valueChanged)
            cell.dueDate.date = dueDate ?? Date()
        }
        
    }
    
    //MARK: heightForRow(at: , with: )
    override func heightForRow(at indexPath: IndexPath, with identifier: String) -> CGFloat {
        switch identifier {
        case taskTitleCell:
            return 40
        case taskDueDateTitleCell, taskAttachedLessonCell, taskAttachLessonCell, taskNotifiactionCell:
            return 50
        case taskDescriptionCell:
            return 120
        case taskDueDateCell:
            return 160
        default:
            return 0
        }
    }
      
    //MARK: didSelectRow(at: , with: )
    override func didSelectRow(at indexPath: IndexPath, with identifier: String) {
        super.didSelectRow(at: indexPath, with: identifier)
        
        let section = indexPath.section
        let row = indexPath.row
        let sectionIdentifer = sectionIdentifier(for: section)
        
        switch sectionIdentifer {
        case dueSection:
            if row == 0 {
                
                tableView.beginUpdates()
                
                if expandDueDateCell {
                    
                    removeCell(at: section, row: 1)
                    tableView.reloadRows(at: [IndexPath(row: 2, section: section)], with: .fade)
                    tableView.deleteRows(at: [IndexPath(row: 1, section: section)], with: .fade)
                    
                }else {
                    insertCell(with: taskDueDateCell, in: dueSection, at: 1)

                    tableView.insertRows(at: [IndexPath(row: 1, section: section)], with: .fade)
                    tableView.reloadRows(at: [IndexPath(row: 1, section: section)], with: .fade)

                }
                
                tableView.endUpdates()
                expandDueDateCell.toggle()

            }
            break
        case lessonSection:
            showLessonPicker()
        default:
            break
        }
    }
    
    //MARK: showLessonPicker()
    @objc func showLessonPicker() {
        let lessonPicker = TaskLessonPickerTableViewController(style: .insetGrouped)
        lessonPicker.lessonDelegate = self
        
        navigationController?.pushViewController(lessonPicker, animated: true)
        
//        present(UINavigationController(rootViewController: lessonPicker), animated: true, completion: nil)
    }
    
    func taskLessonPicker(_ picker: TaskLessonPickerTableViewController, didSelect lesson: Lesson) {
        selectLesson(lesson)
        
        tableView.reloadData()
    }
    
    func taskLessonPickerDidCancel(_ picker: TaskLessonPickerTableViewController) {
        
    }
    
    /// Calculates the next date of the attached lesson
    /// - Returns: Date when the next attached lesson starts
    internal func dueDateForTask() -> Date? {
        guard let lesson = self.lesson else {
            return nil
        }
        
        return TimetableService.shared.dateOfNext(lesson: lesson)
    }
    
    //MARK: selectLesson(_ lesson: )
    func selectLesson(_ lesson: Lesson?) {
        guard let lesson = lesson else {
            return
        }
        
        // In case the view (add task) is reloaded for the first time
        // In that case the is a "attach lesson" cell in the section
        // -> Remove that and add a "attached lesson" cell to the section
        if self.lesson == nil {
            self.lesson = lesson
            // Prepare the tableView for changes
            tableView.beginUpdates()
            
            // Remove the "attach lesson" cell
            removeCell(at: taskLessonSection, row: 0)
            
            // Readd the section (the section will be removed as soon
            // as there aren't any cells in the section
            addSection(with: lessonSection, at: taskLessonSection)
            
            // Add "attached lesson" cell
            addCell(with: taskAttachedLessonCell, at: lessonSection)
            
            // FIXME
            if let date = dueDateForTask() {
                dueDate = date
            }
            
            tableView.endUpdates()
        }
        
        self.lesson = lesson
    }
}

protocol TaskLessonPickerDelegate {
    
    func taskLessonPicker(_ picker: TaskLessonPickerTableViewController, didSelect lesson: Lesson)
    
    func taskLessonPickerDidCancel(_ picker: TaskLessonPickerTableViewController)
    
}

//MARK: TaskLessonPickerTableViewController
class TaskLessonPickerTableViewController: UITableViewController, UINavigationControllerDelegate {
        
    private var lessons: [Lesson]?
    private var displayedLessons: [Lesson]?
    
    private var weekDays: [Day]?
    private var week: [Day: [Lesson]]?
    
    var lessonDelegate: TaskLessonPickerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lessons = TimetableService.shared.fetchLessons()
        displayedLessons = lessons
        
        tableView.register(TaskLessonPickerTableViewCell.self, forCellReuseIdentifier: "lessonCell")
        
//        let cancelItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
//        navigationItem.leftBarButtonItem = cancelItem
//
        title = "Lesson"
        
        reload()
    }
    
    @objc func cancel() {
        lessonDelegate?.taskLessonPickerDidCancel(self)
//        dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
    
    func reload() {
        guard let lessons = displayedLessons else {
            return
        }
        
        week = TimetableService.shared.sortLessonsByWeekDay(lessons)
        
        guard let week = self.week else {
            return
        }
        
        weekDays = Array(week.keys).sorted(by: { $0 < $1})
        
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return weekDays?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let day = weekDays?[section] else {
            return 0
        }
        return week?[day]?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lessonCell", for: indexPath) as! TaskLessonPickerTableViewCell
        
        guard let day = weekDays?[indexPath.section] else {
            return cell
        }
        
        cell.setLesson(week?[day]?[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return weekDays?[section].string() ?? ""
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! TaskLessonPickerTableViewCell
        
        guard let lesson = cell.lesson else {
            return
        }
        
        lessonDelegate?.taskLessonPicker(self, didSelect: lesson)
        navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}

//MARK: TaskLessonPickerTableViewCell
class TaskLessonPickerTableViewCell: UITableViewCell {
    
    var colorIndicator = UIView()
    
    var name = PaddingLabel()
    
    var time = UILabel()
    
    var lesson: Lesson?
    
    internal var tasksImage: UIImageView!
    var tasksLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUserInterface()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func setupUserInterface() {
        
        //MARK: colorIndicator
        addSubview(colorIndicator)
        
        colorIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        colorIndicator.backgroundColor = .label
        
        colorIndicator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        colorIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        colorIndicator.heightAnchor.constraint(equalToConstant: 10).isActive = true
        colorIndicator.widthAnchor.constraint(equalToConstant: 10).isActive = true
        
        colorIndicator.layer.cornerRadius = 5
        
        //MARK: name
        addSubview(name)
        
        name.translatesAutoresizingMaskIntoConstraints = false
        
        name.leadingAnchor.constraint(equalTo: colorIndicator.trailingAnchor, constant: 15).isActive = true
        name.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        name.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        name.widthAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        
        name.textColor = UIColor.label
        name.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        //MARK: time
        addSubview(time)
        
        time.translatesAutoresizingMaskIntoConstraints = false
        
        time.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).isActive = true
        time.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        time.leadingAnchor.constraint(equalTo: centerXAnchor).isActive = true
        time.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        time.textAlignment = .right
        
        time.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        time.textColor = .label
    }
    
    func setLesson(_ lesson: Lesson?) {
        guard let lesson = lesson else {
            return
        }
        
        self.lesson = lesson
        
        name.text = lesson.subject?.name
        
        name.sizeToFit()
        
        time.text = "\(lesson.startTime.string() ?? "") \u{2022} \(lesson.endTime.string() ?? "")"
        
        let color: UIColor? = UIColor(named: lesson.subject?.color ?? "dark") ?? UIColor(named: "dark")

        colorIndicator.backgroundColor = color
    }
    
}


extension TaskAddViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        detailDelegate?.detailWillDismiss(self)
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        detailDelegate?.detailWillDismiss(self)
    }
    
}

