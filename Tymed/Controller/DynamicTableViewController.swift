//
//  TymedTableViewController.swift
//  Tymed
//
//  Created by Jonah Schueller on 18.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class DynamicTableViewControllerHeader: UITableViewHeaderFooterView {
    
    let iconView = UIImageView()
    let titleLabel = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        iconView.constraintLeadingToSuperview(constant: 15)
        iconView.constraintCenterYToSuperview(constant: 0)
        iconView.constraint(width: 18, height: 18)
        
        titleLabel.constraintLeadingTo(anchor: iconView.trailingAnchor, constant: 8)
        titleLabel.constraintCenterYToSuperview(constant: 0)
        titleLabel.constraint(height: 20)
        titleLabel.constraintTrailingToSuperview(constant: 5)
        
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        titleLabel.textColor = .secondaryLabel
        iconView.tintColor = .secondaryLabel
    }
    
    func setTitle(title: String) {
        titleLabel.text = title
    }
    
    func setIcon(systemName icon: String) {
        let image = UIImage(systemName: icon, withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold))
        
        iconView.image = image
    }
}

class DynamicTableViewController: UITableViewController {

    /// An array of section identifiers
    private var sections: [String] = []
    
    private var cells: [String : [String]] = [:]
    
    internal var tableViewUpdateAnimation: UITableView.RowAnimation = .top
    internal var tableViewPerformBatchUpdates = false
    
    convenience init() {
        self.init(style: .insetGrouped)
    }
    
    override init(style: UITableView.Style) {
        super.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
    }
    
    internal func reconfigure() {
        
    }
    
    internal func reload() {
        reconfigure()
        tableView.reloadData()
    }
    
    /// Setup any additional views (gets called in viewDidLoad)
    internal func setup() {
        tableView.register(DynamicTableViewControllerHeader.self, forHeaderFooterViewReuseIdentifier: "headerView")
                        
        tableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
        
        navigationController?.navigationBar.isTranslucent = true
                
    }
    
    //MARK: register(_ :, identifier)
    /// Registers a UITableViewCell to the tableView of the controller
    /// - Parameters:
    ///   - cellClass: Subclass of UITableViewCell to register
    ///   - identifier: Reuseidentifier for the UITableViewCell class
    internal func register(_ cellClass: AnyClass, identifier: String) {
        tableView.register(cellClass, forCellReuseIdentifier: identifier)
    }
    
    //MARK: register(_ :, identifier)
    /// Registers a UITableViewCell to the tableView of the controller
    /// - Parameters:
    ///   - nib: UINib to register
    ///   - identifier: Reuseidentifier for the UITableViewCell class
    internal func register(_ nib: UINib?, identifier: String) {
        tableView.register(nib, forCellReuseIdentifier: identifier)
    }
    
    /// Returns the index of the given identifier
    /// - Parameter identifier: Identifier of the section
    /// - Returns: Index of the section with the given identifier (in case the identifier exists)
    internal func sectionIndex(for identifier: String) -> Int? {
        return sections.firstIndex(of: identifier)
    }
    
    //MARK: sectionIdentifier(for: )
    /// Returns the identifier of a given section index
    /// - Parameter index: Index of the section
    internal func sectionIdentifier(for index: Int) -> String {
        return sections[index]
    }
    
    //MARK: identifier(for: )
    /// Returns the identifier of a cell for a given IndexPath
    /// - Parameter indexPath: IndexPath of the cell
    internal func identifier(for indexPath: IndexPath) -> String? {
        let identifier = sectionIdentifier(for: indexPath.section)
        return cells[identifier]?[indexPath.row]
    }
    
    /// Returns the index of a cell identfier in a given section
    /// - Parameters:
    ///   - cell: Cell identifier
    ///   - section: Section identifier
    /// - Returns: Potential index of the cell. Attention! It is the first index that will be found.
    internal func identifier(for cell: String, at section: String) -> Int? {
        return cells[section]?.firstIndex(of: cell)
    }
    
    internal func numerOfCells(for section: String) -> Int {
        return cells[section]?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    internal func headerForSection(with identifier: String, at index: Int) -> String? {
        return ""
    }
    
    internal func iconForSection(with identifier: String, at index: Int) -> String? {
        return ""
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func configureCell(_ cell: UITableViewCell, for identifier: String, at indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let cells = cells[sectionIdentifier(for: section)] {
            return cells.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let identifier = self.identifier(for: indexPath) else {
            // Should never happen
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)

        configureCell(cell, for: identifier, at: indexPath)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let identifier = identifier(for: indexPath) else {
            return
        }
        didSelectRow(at: indexPath, with: identifier)
    }
    
    
    internal func heightForRow(at indexPath: IndexPath, with identifier: String) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerView") as! DynamicTableViewControllerHeader
        
        let identifier = sectionIdentifier(for: section)
        
        header.setTitle(title: headerForSection(with: identifier, at: section) ?? "")
        header.setIcon(systemName: iconForSection(with: identifier, at: section) ?? "")
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let identifier = identifier(for: indexPath) else {
            return 0
        }
        return heightForRow(at: indexPath, with: identifier)
    }
    
    //MARK: didSelectRow(at: , with: )
    internal func didSelectRow(at indexPath: IndexPath, with identifier: String) {
        
    }
    
    internal func beginBatchUpdates() {
        tableView.beginUpdates()
        tableViewPerformBatchUpdates = true
    }
    
    internal func beginUpdates() {
        if !tableViewPerformBatchUpdates {
            tableView.beginUpdates()
        }
    }

    internal func endBatchUpdates() {
        tableView.endUpdates()
        tableViewPerformBatchUpdates = false
    }
    
    internal func endUpdates() {
        if !tableViewPerformBatchUpdates {
            tableView.endUpdates()
        }
    }
    
    //MARK: addSection(...)
    
    /// Appends a section to the end the tableView
    /// - Parameter identifier: Unique identifier for the section
    internal func addSection(with identifier: String) {
//        beginUpdates()
        sections.append(identifier)
        cells[identifier] = []
        tableView.insertSections(IndexSet(arrayLiteral: sections.count - 1), with: tableViewUpdateAnimation)
//        endUpdates()
    }
    
    /// Inserts a section into the tableView
    /// - Parameters:
    ///   - identfier: Unique identifier for the section
    ///   - index: Index where the section will be inserted (index is automatically )
    internal func addSection(with identifier: String, at index: Int) {
//        beginUpdates()
        let secIndex = max(0, min(index, sections.endIndex))
        sections.insert(identifier, at: secIndex)
        cells[identifier] = []
        tableView.insertSections(IndexSet(arrayLiteral: secIndex), with: tableViewUpdateAnimation)
//        endUpdates()
    }
    
    //MARK: removeSection(...)
    
    /// Removes the section at the specified position
    /// - Parameter index: The position of the section to remove
    internal func removeSection(at index: Int) {
        let identifier = self.sectionIdentifier(for: index)
        removeSection(with: identifier)
    }
    
    /// Removes the first section of the specified identifier (in case the identifier exists)
    /// - Parameter identifier: Identifier of the section to remove
    internal func removeSection(with identifier: String) {
        guard let index = sections.firstIndex(of: identifier) else {
            print("dksl")
            return
        }
//        beginUpdates()
        
        self.cells[identifier]?.forEach { cell in
            self.removeCell(at: identifier, row: cell)
        }
        
        tableView.deleteSections(IndexSet(arrayLiteral: index), with: tableViewUpdateAnimation)
        
        cells[identifier] = nil
        sections.remove(at: index)
        
//        endUpdates()
    }
    
    //MARK: addCell(...)
    
    /// Appends a cell to the section of the specified section identifier
    /// - Parameters:
    ///   - identifier: Identifier for the cell
    ///   - section: Identifier for the section where the cell will be added. The identifier has to be valid otherwise the cell won't be added.
    internal func addCell(with identifier: String, at section: String) {
        guard cells[section] != nil else {
            return
        }
        beginUpdates()
        cells[section]?.append(identifier)
        if let index = cells[section]?.count, let sectionIndex = self.sectionIndex(for: section) {
            tableView.insertRows(at: [IndexPath(row: index - 1, section: sectionIndex)], with: tableViewUpdateAnimation)
        }
        
        endUpdates()
    }
    
    /// Appends a cell to the section of the specified section index
    /// - Parameters:
    ///   - identifier: Identifier for the cell
    ///   - section: Index for the section where the cell will be added
    internal func addCell(with identifier: String, at section: Int) {
        addCell(with: identifier, at: sections[section])
    }
    
    internal func setCells(for section: String, _ cells: String...) {
        if self.cells[section] != nil {
            self.cells[section] = cells
        }
    }
    
    internal func setCells(for section: String, _ cells: [String]) {
        if self.cells[section] != nil {
            self.cells[section] = cells
        }
    }
    
    internal func insertCell(with identifier: String, in section: String, at index: Int) {
        beginUpdates()
        if let sectionIndex = self.sectionIndex(for: section) {
            cells[section]?.insert(identifier, at: index)
            tableView.insertRows(at: [IndexPath(row: index, section: sectionIndex)], with: tableViewUpdateAnimation)
        }
        endUpdates()
    }
    
    //MARK: removeCell(...)
    
    /// Removes the cell of the specified section - row
    /// - Parameters:
    ///   - section: Section index of the cell
    ///   - row: Row index of the cell
    internal func removeCell(at section: Int, row: Int) {
        let identifier = sectionIdentifier(for: section)
        
        guard cells[identifier] != nil else {
            return
        }
        
        beginUpdates()
        cells[identifier]?.remove(at: row)
        tableView.deleteRows(at: [IndexPath(row: row, section: section)], with: tableViewUpdateAnimation)
        
        endUpdates()
        if let c = self.cells[identifier] {
            if c.isEmpty {
                self.cells[identifier] = nil
                self.sections.remove(at: section)
            }
        }
    }
    
    /// Removes the cell of the specified section - row
    /// - Parameters:
    ///   - section: Section identifier of the cell
    ///   - row: Row identifier of the cell
    internal func removeCell(at section: String, row: String) {
        guard let secID = sections.firstIndex(of: section) else {
            return
        }
        
        cells[section]?.filter({ $0 == row }).forEach({ row in
            if let cells = cells[section], let index = cells.firstIndex(of: row) {
                removeCell(at: secID, row: index)
            }
        })
    }
    
    /// Removes all cell of the specified section - row
    /// - Parameters:
    ///   - section: Section index of the cell
    ///   - row: Row identifier of the cell
    internal func removeCell(at section: Int, row: String) {
        removeCell(at: sectionIdentifier(for: section), row: row)
    }
    
    /// Removes the cell of the specified section - row
    /// - Parameters:
    ///   - section: Section identifier of the cell
    ///   - row: Row index of the cell
    internal func removeCell(at section: String, row: Int) {
        guard let section = sectionIndex(for: section) else {
            return
        }
        
        removeCell(at: section, row: row)
    }
    
    internal func tapticFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    internal func tapticErrorFeedback() {
        tapticFeedback(.error)
    }
    
    internal func tapticWarningFeedback() {
        tapticFeedback(.warning)
    }
    
    internal func tapticSuccessFeedback() {
        tapticFeedback(.success)
    }
    
    internal func viewTextColorErrorAnimation(for view: UIView, _ errorColor: UIColor, _ switchColor: @escaping (UIColor?) -> UIColor?) {
        
        var color: UIColor?
        
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            color = switchColor(errorColor)
        }, completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    _ = switchColor(color)
                }, completion: nil)
            }
            
        })
    }
    
    internal func labelErrorAnimation(_ label: UILabel, _ errorColor: UIColor = .red) {
        
        viewTextColorErrorAnimation(for: label, errorColor) { (color) -> UIColor? in
            let prevColor = label.textColor
            
            label.textColor = color ?? .label
            
            return prevColor
        }
    }
    
    internal func textFieldErrorAnimation(_ textField: UITextField, _ errorColor: UIColor = .red) {
        
        viewTextColorErrorAnimation(for: textField, errorColor) { (color) -> UIColor? in
            let prevColor = textField.textColor
            
            
            textField.textColor = color ?? .label
            
            return prevColor
        }
    }
    
    internal func textViewErrorAnimation(_ textView: UITextView, _ errorColor: UIColor = .red) {
        
        viewTextColorErrorAnimation(for: textView, errorColor) { (color) -> UIColor? in
            let prevColor = textView.textColor
            
            textView.textColor = color ?? .label
            
            return prevColor
        }
    }
    
}
