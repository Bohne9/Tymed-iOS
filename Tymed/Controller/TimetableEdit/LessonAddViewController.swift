//
//  LessonAddViewController.swift
//  Tymed
//
//  Created by Jonah Schueller on 04.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

private let lessonNoteCell = "lessonNoteCell"
private let lessonTimePickerCell = "lessonTimePickerCell"
private let lessonTimeTitleCell = "lessonTimeTitleCell"
private let lessonColorPickerCell = "lessonColorPickerCell"
private let lessonDayPickerCell = "lessonDayPickerCell"

protocol SubjectAutoFillDelegate {
    
    func subjectAutoFill(didSelect subject: String)
    
}
//MARK: SubjectAutoFill
class SubjectAutoFill: UIStackView {
    
    var subjects: [Subject]? = nil
    
    var subjectDelegate: SubjectAutoFillDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        distribution = .fillEqually
        spacing = 0
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func selectItem(_ btn: UIButton) {
        guard let title = btn.title(for: .normal) else {
            return
        }
        
        subjectDelegate?.subjectAutoFill(didSelect: title)
    }
    
    func sortSubjects(_ title: String) -> [Subject]?  {
        guard let subjects = subjects else {
            return nil
        }
        
        var values = subjects.map { (sub: Subject) in
            return (sub, sub.name?.levenshteinDistanceScore(to: title) ?? 0.0)
        }
        
        values.sort(by: { (v1, v2) -> Bool in
            return v1.1 > v2.1
        })
        
        return values.map { (value: (Subject, Double)) in
            return value.0
        }
    }
    
    func addSubject(_ subject: Subject) {
        let button = UIButton()
        
        button.setTitle(subject.name ?? "-", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: subject.color ?? "dark") ?? .blue
        
        button.addTarget(self, action: #selector(selectItem(_:)), for: .touchUpInside)
        
        addArrangedSubview(button)
    }
    
    func setupViews(_ title: String) {
        subviews.forEach { view in
            view.removeFromSuperview()
        }
        
        sortSubjects(title)?.prefix(3).forEach({ (subject) in
            self.addSubject(subject)
        })
    }
    
    func reload(_ title: String) {
        setupViews(title)
    }
}

//MARK: LessonAddViewController
class LessonAddViewController: UITableViewController, UITextFieldDelegate, LessonColorPickerTableViewDelegate, UIPickerViewDelegate, LessonDayPickerCellDelegate, SubjectAutoFillDelegate {

    let textField = UITextField()
    
    var subjects: [Subject]?
    
    var autoFill: SubjectAutoFill = SubjectAutoFill()
    
    private var expandStartTime = false
    private var expandEndTime = false
    private var expandDay = false
    private var invalidTimeInterval = false
    
    private var startDate: Date = TimetableService.shared.dateFor(hour: 12, minute: 30)
    private var endDate: Date = TimetableService.shared.dateFor(hour: 14, minute: 0)
    private var day: Day = Day.monday
    
    private weak var startTitleCell: LessonTimeTitleCell?
    private weak var endTitleCell: LessonTimeTitleCell?
    private weak var dayTitleCell: LessonTimeTitleCell?
    
    private weak var startPickerCell: LessonTimePickerCell?
    private weak var endPickerCell: LessonTimePickerCell?
    private weak var dayPickerCell: LessonDayPickerCell?
    
    private var noteCell: LessonAddNoteCell?
    
    // Amount of items in each section
    private var sectionItemCount = [1, 3, 1]
    
    private let sectionHeaderTitles = ["Subject color", "Time", "Notes"]
    
    // Vars for the lesson
    
    private var lessonColor = "blue"
    
    
    // Get-only lesson params
    
    var subjectName: String? {
        textField.text
    }
    
    var lessonNote: String? {
        noteCell?.textView.text
    }

    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        tableView.register(LessonAddNoteCell.self, forCellReuseIdentifier: lessonNoteCell)
        tableView.register(LessonTimeTitleCell.self, forCellReuseIdentifier: lessonTimeTitleCell)
        tableView.register(LessonTimePickerCell.self, forCellReuseIdentifier: lessonTimePickerCell)
        tableView.register(LessonColorPickerCell.self, forCellReuseIdentifier: lessonColorPickerCell)
        tableView.register(LessonDayPickerCell.self, forCellReuseIdentifier: lessonDayPickerCell)
        

        setupView()
        
        subjects = TimetableService.shared.fetchSubjects()
        
        autoFill.subjects = subjects
        autoFill.reload("")
        
        // Select default color
        selectColor(lessonColor)
    }
    
    private func setupView() {
        
        setupNavigationBar()
        
    }
    
    private func setupNavigationBar() {
        
        navigationItem.titleView = textField
        
        textField.delegate = self
        
        textField.autocorrectionType = .no
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(titleChanged(_:)), for: .editingChanged)
        
        let toolBar = UIToolbar()
        
        toolBar.addSubview(autoFill)
        
        autoFill.subjectDelegate = self
        autoFill.backgroundColor = .red
        
        toolBar.sizeToFit()
        
        autoFill.translatesAutoresizingMaskIntoConstraints = false
        
        autoFill.leadingAnchor.constraint(equalTo: toolBar.leadingAnchor).isActive = true
        autoFill.topAnchor.constraint(equalTo: toolBar.topAnchor).isActive = true
        autoFill.widthAnchor.constraint(equalTo: toolBar.widthAnchor).isActive = true
        autoFill.heightAnchor.constraint(equalTo: toolBar.heightAnchor).isActive = true
        
        
        textField.inputAccessoryView = toolBar
        
        if let navbar = navigationController?.navigationBar {
            textField.widthAnchor.constraint(equalTo: navbar.widthAnchor, multiplier: 0.4).isActive = true
            textField.layoutIfNeeded()
        }
        
        textField.textAlignment = .center
        textField.placeholder = "Subject name"
        textField.textColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .done, target: self
            , action: #selector(add))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self
        , action: #selector(cancel))
    }
    
    func subjectAutoFill(didSelect subject: String) {
        guard let val = subjects?.filter({ sub -> Bool in return sub.name == subject }).first else {
            return
        }
        
        textField.text = subject
        selectSubject(val)
        textField.resignFirstResponder()
    }
    
    @objc func titleChanged(_ textField: UITextField) {
        guard let subjects = self.subjects else {
            return
        }
        
        autoFill.reload(textField.text ?? "")
        
        guard let subject = subjects.filter({ subject -> Bool in return subject.name == textField.text }).first else {
            deselectSubject()
            return
        }
        
        
        selectSubject(subject)
        
    }
    
    func selectColor(_ colorName: String?) {
        if let color = UIColor(named: colorName?.lowercased() ?? "") {
            lessonColor = colorName ?? "blue"
            navigationController?.navigationBar.barTintColor = color
            navigationController?.navigationBar.tintColor = .white
            textField.textColor = .white
            tableView.reloadData()
        }
    }
    
    func selectSubject(_ subject: Subject) {
        selectColor(subject.color)
    }
    
    func deselectSubject() {
        
        
//        selectColor("blue")
    }
    
    func createLesson() -> Lesson? {
        
        print("Lesson:")
        
        print("\t\(subjectName ?? "nil")")
        print("\tColor:\(lessonColor)")
        print("\tStart: \(startDate.timeToString())")
        print("\tEnd: \(endDate.timeToString())")
        print("\tDay: \(day.date()?.dayToString() ?? "nil")")
        print("\tNote: \(lessonNote ?? "nil")")
        
        if invalidTimeInterval {
            print("Invalid lesson times")
            return nil
        }
        
        if subjectName == nil || subjectName?.isEmpty == true {
            print("Invalid subject name")
            return nil
        }
        
        var subject: Subject? = subjects?.filter({ subject -> Bool in return subject.name == subjectName }).first
        
        if subject == nil, let name = subjectName {
            
            subject = TimetableService.shared.addSubject(name, lessonColor)
            
        }
        
        let lesson = TimetableService.shared.addLesson(subject: subject!, day: day, start: startDate, end: endDate, note: lessonNote)
        
        return lesson
    }
    
    @objc func add() {
        let lesson = createLesson()
        
        if lesson != nil {
            dismiss(animated: true, completion: nil)
        }
        
        
    }
    
    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionItemCount[section]
    }

    //MARK: cellForRowAt
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // MARK: Color picker
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: lessonColorPickerCell, for: indexPath) as! LessonColorPickerCell
            
            cell.selectColor(named: lessonColor)
            
            return cell
        }else if indexPath.section == 1 {
            // MARK: Time Picker
            switch indexPath.row {
            case 0:
                // First cell in time section is always the title
                let first = tableView.dequeueReusableCell(withIdentifier: lessonTimeTitleCell, for: indexPath) as! LessonTimeTitleCell
                startTitleCell = first
                first.title.text = "Start"
                first.value.text = startDate.timeToString()
                
                return first
            case 1:
                // Second cell in the time section depends whether the startTime cell is expanded
                if expandStartTime {
                    let cell = tableView.dequeueReusableCell(withIdentifier: lessonTimePickerCell, for: indexPath) as! LessonTimePickerCell
                    startPickerCell = cell
                    cell.datePicker.setDate(startDate, animated: false)
                    
                    cell.datePicker.removeTarget(self, action: #selector(setEndTime(_:)), for: .valueChanged)
                    
                    cell.datePicker.addTarget(self, action: #selector(setStartTime(_:)), for: .valueChanged)
                    
                    return cell
                }else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: lessonTimeTitleCell, for: indexPath) as! LessonTimeTitleCell
                    endTitleCell = cell
                    cell.title.text = "End"
                    let attr: [NSAttributedString.Key: Any]  = invalidTimeInterval ? [NSAttributedString.Key
                        .strikethroughStyle: NSUnderlineStyle.single.rawValue] : [:]
                    
                    cell.value.attributedText = NSAttributedString(string: endDate.timeToString(), attributes: attr)
                    
                    return cell
                }
                
            case 2:
                // Third cell in the time section depends whether the startTime cell is expanded
                if expandStartTime {
                    let cell = tableView.dequeueReusableCell(withIdentifier: lessonTimeTitleCell, for: indexPath) as! LessonTimeTitleCell
                    endTitleCell = cell
                    cell.title.text = "End"
                    let attr: [NSAttributedString.Key: Any]  = invalidTimeInterval ? [NSAttributedString.Key
                        .strikethroughStyle: NSUnderlineStyle.single.rawValue] : [:]
                    
                    cell.value.attributedText = NSAttributedString(string: endDate.timeToString(), attributes: attr)
                    
                    return cell
                }else if expandEndTime{
                    let cell = tableView.dequeueReusableCell(withIdentifier: lessonTimePickerCell, for: indexPath) as! LessonTimePickerCell
                    endPickerCell = cell
                    
                    cell.datePicker.setDate(endDate, animated: false)

                    cell.datePicker.removeTarget(self, action: #selector(setStartTime(_:)), for: .valueChanged)
                    
                    cell.datePicker.addTarget(self, action: #selector(setEndTime(_:)), for: .valueChanged)
                    
                    return cell
                }else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: lessonTimeTitleCell, for: indexPath) as! LessonTimeTitleCell
                    dayTitleCell = cell
                    cell.title.text = "Day"
                    cell.value.text = day.date()?.dayToString() ?? "-"
//                    cell.picker.addTarget(self, action: #selector(setEndTime(_:)), for: .valueChanged)
                    
                    return cell
                }
                
            case 3:
                if expandStartTime || expandEndTime {
                    let cell = tableView.dequeueReusableCell(withIdentifier: lessonTimeTitleCell, for: indexPath) as! LessonTimeTitleCell
                    dayTitleCell = cell
                    cell.title.text = "Day"
                    cell.value.text = day.date()?.dayToString() ?? "-"
                    
                    return cell
                }else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: lessonDayPickerCell, for: indexPath) as! LessonDayPickerCell
                    dayPickerCell = cell
                    cell.picker.selectRow(day == Day.sunday ? 6 : day.rawValue - 2, inComponent: 0, animated: false)
                    cell.lessonDelgate = self
                    return cell
                }
            default:
                // Should never be executed
                return UITableViewCell(style: .default, reuseIdentifier: nil)
            }
            
        }else {
            // MARK: Note
            let cell = tableView.dequeueReusableCell(withIdentifier: lessonNoteCell, for: indexPath) as! LessonAddNoteCell
            noteCell = cell
            
            return cell
        }
    }
    
    @objc func setStartTime(_ datePicker: UIDatePicker) {
        startDate = datePicker.date
        
        invalidTimeInterval = endDate <= startDate
        
        tableView.reloadData()
    }
    
    @objc func setEndTime(_ datePicker: UIDatePicker) {
        endDate = datePicker.date
        
        invalidTimeInterval = endDate <= startDate
        
        tableView.reloadData()
    }
    
    func didSelectDay(_ cell: LessonDayPickerCell, day: Day) {
        self.day = day
        
        tableView.reloadData()
    }
    
    
    //MARK: heightForRowAt
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 50
        }else if indexPath.section == 1 {
            // Time Picker
            switch indexPath.row {
            case 0:
                return 50
            case 1:
                return expandStartTime ?
                    150
                  : 50
            case 2:
                return expandStartTime ? 50
                : expandEndTime ? 150 : 50
            case 3:
                return expandStartTime || expandEndTime ?
                    50
                  : 150
            default:
                return 50
            }
            
        }else {
            // Note
            return 120
        }
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionHeaderTitles[section]
    }
    //MARK: didSelectRowAt
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            
            let detail = LessonColorPickerTableView(style: .insetGrouped)
            detail.lessonDelegate = self
            detail.selectedColor = lessonColor
            navigationController?.pushViewController(detail, animated: true)
            
        } else if indexPath.section == 1 {
            let cell = tableView.cellForRow(at: indexPath)
            
            if cell == startTitleCell {
                expandStartTime.toggle()
                
                if expandEndTime {
                    expandEndTime.toggle()
                    
                    sectionItemCount[1] = sectionItemCount[1] + -1
                }
                
                if expandDay {
                    expandDay.toggle()
                    
                    sectionItemCount[1] = sectionItemCount[1] + -1
                }
                
                sectionItemCount[1] = sectionItemCount[1] + (expandStartTime ? 1 : -1)
            }else if cell == endTitleCell {
                expandEndTime.toggle()
                
                if expandStartTime {
                    expandStartTime.toggle()
                    
                    sectionItemCount[1] = sectionItemCount[1] + -1
                }
                
                if expandDay {
                    expandDay.toggle()
                    
                    sectionItemCount[1] = sectionItemCount[1] + -1
                }
                
                sectionItemCount[1] = sectionItemCount[1] + (expandEndTime ? 1 : -1)
                
            }else if cell == dayTitleCell {
                expandDay.toggle()
                
                if expandStartTime {
                    expandStartTime.toggle()
                    
                    sectionItemCount[1] = sectionItemCount[1] + -1
                }
                
                if expandEndTime {
                    expandEndTime.toggle()
                    
                    sectionItemCount[1] = sectionItemCount[1] + -1
                }
                
                sectionItemCount[1] = sectionItemCount[1] + (expandDay ? 1 : -1)
                
            }
            tableView.reloadSections(IndexSet(arrayLiteral: 1), with: .fade)
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func colorPicker(didSelect color: String) {
        selectColor(color)
        tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }
    
}

//MARK: - LessonAddNoteCell
class LessonAddNoteCell: UITableViewCell {
    
    let textView = UITextView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(textView)
        
        textView.backgroundColor = .clear
        
        textView.font = UIFont.systemFont(ofSize: 16)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        textView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

//MARK: - LessonTimeTitleCell
class LessonTimeTitleCell: UITableViewCell {
    
    let title = UILabel()

    let value = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(title)
        addSubview(value)
        
        title.text = "Start"
        value.text = "12:30"
        
        title.translatesAutoresizingMaskIntoConstraints = false
        
        title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        title.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        title.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.4).isActive = true
        title.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.9).isActive = true
        
        value.translatesAutoresizingMaskIntoConstraints = false
        
        value.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        value.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        value.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
        value.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.9).isActive = true
        
        value.textAlignment = .right
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

//MARK: - LessonTimePickerCell
class LessonTimePickerCell: UITableViewCell {
    
    let datePicker = UIDatePicker()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(datePicker)
        
        datePicker.datePickerMode = .time
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        datePicker.topAnchor.constraint(equalTo: topAnchor).isActive = true
        datePicker.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        datePicker.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

protocol LessonDayPickerCellDelegate {
    func didSelectDay(_ cell: LessonDayPickerCell, day: Day)
}

//MARK: - LessonDayPickerCell
class LessonDayPickerCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let days: [Day] = [
        Day.monday,
        Day.tuesday,
        Day.wednesday,
        Day.thursday,
        Day.friday,
        Day.saturday,
        Day.sunday
    ]
    
    let picker = UIPickerView()
    
    var lessonDelgate: LessonDayPickerCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(picker)
        
        picker.delegate = self
        picker.dataSource = self
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        picker.topAnchor.constraint(equalTo: topAnchor).isActive = true
        picker.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        picker.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        picker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return days.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return days[row].date()?.dayToString()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        lessonDelgate?.didSelectDay(self, day: days[row])
    }
    
}

//MARK: - LessonColorPickerCell
class LessonColorPickerCell: UITableViewCell {
    
    let label = UILabel()
    
    let colorIndicator = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        accessoryType = .disclosureIndicator
        
        addSubview(colorIndicator)
        
        colorIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        colorIndicator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        colorIndicator.widthAnchor.constraint(equalToConstant: 10).isActive = true
        
        colorIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        colorIndicator.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: colorIndicator.trailingAnchor, constant: 10).isActive = true
        
        label.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7).isActive = true
        label.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.9).isActive = true
        
        colorIndicator.layer.cornerRadius = 5
        
        selectColor(named: "orange")
    }
    
    func selectColor(named: String) {
        
        guard let color = UIColor(named: named.lowercased()) else {
            return
        }
        
        label.text = named.capitalized
        colorIndicator.backgroundColor = color
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

protocol LessonColorPickerTableViewDelegate {
    
    func colorPicker(didSelect color: String)
    
}

private let lessonColorIndicationCell = "lessonColorIndicationCell"
//MARK: - LessonColorPickerTableView
class LessonColorPickerTableView: UITableViewController {
    
    private var colors = ["blue", "orange", "red", "green", "dark"]
    
    var selectedColor: String = "orange"
    
    var lessonDelegate: LessonColorPickerTableViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Subject color"
        
        tableView.register(LessonColorIndicationCell.self, forCellReuseIdentifier: lessonColorIndicationCell)
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colors.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: lessonColorIndicationCell, for: indexPath) as! LessonColorIndicationCell
        
        cell.isSelected = selectedColor.lowercased() == colors[indexPath.row]
        
        cell.setColor(named: colors[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? LessonColorIndicationCell else {
            return
        }
        
        selectedColor = cell.label.text ?? "blue"
        lessonDelegate?.colorPicker(didSelect: cell.label.text?.lowercased() ?? "blue")
        
        tableView.reloadData()
    }
}

//MARK: - LessonColorIndicationCell
class LessonColorIndicationCell: UITableViewCell {
    
    let label = UILabel()
    
    let colorIndicator = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    
    override var isSelected: Bool {
        didSet {
            accessoryType = isSelected ? .checkmark : .none
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        addSubview(colorIndicator)
        
        colorIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        colorIndicator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        colorIndicator.widthAnchor.constraint(equalToConstant: 10).isActive = true
        
        colorIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        colorIndicator.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: colorIndicator.trailingAnchor, constant: 10).isActive = true
        
        label.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7).isActive = true
        label.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.9).isActive = true
        
        colorIndicator.layer.cornerRadius = 5
        
        setColor(named: "orange")
    }
    
    func setColor(named: String) {
        
        guard let color = UIColor(named: named.lowercased()) else {
            return
        }
        
        label.text = named.capitalized
        colorIndicator.backgroundColor = color
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
