//
//  TymedTableViewController.swift
//  Tymed
//
//  Created by Jonah Schueller on 18.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class TymedTableViewController: UITableViewController {

    /// An array of section identifiers
    private var sections: [String] = []
    
    private var cells: [String : [String]] = [:]
    
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
    
    
    /// Setup any additional views (gets called in viewDidLoad)
    internal func setup() {
        
    }
    
    //MARK: register(_ :, identifier)
    /// Registers a UITableViewCell to the tableView of the controller
    /// - Parameters:
    ///   - cellClass: Subclass of UITableViewCell to register
    ///   - identifier: Reuseidentifier for the UITableViewCell class
    internal func register(_ cellClass: AnyClass, identifier: String) {
        tableView.register(cellClass, forCellReuseIdentifier: identifier)
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
    
    internal func numerOfCells(for section: String) -> Int {
        return cells[section]?.count ?? 0
    }
    
    internal func headerForSection(with identifier: String, at index: Int) -> String? {
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerForSection(with: sectionIdentifier(for: section), at: section)
    }
    
    //MARK: didSelectRow(at: , with: )
    internal func didSelectRow(at indexPath: IndexPath, with identifier: String) {
        
    }

    //MARK: addSection(...)
    
    /// Appends a section to the end the tableView
    /// - Parameter identifier: Unique identifier for the section
    internal func addSection(with identifier: String) {
        sections.append(identifier)
        cells[identifier] = []
    }
    
    /// Inserts a section into the tableView
    /// - Parameters:
    ///   - identfier: Unique identifier for the section
    ///   - index: Index where the section will be inserted (index is automatically )
    internal func addSection(with identifier: String, at index: Int) {
        sections.insert(identifier, at: max(0, min(index, sections.endIndex)))
        cells[identifier] = []
    }
    
    //MARK: removeSection(...)
    
    /// Removes the section at the specified position
    /// - Parameter index: The position of the section to remove
    internal func removeSection(at index: Int) {
        sections.remove(at: max(0, min(index, sections.endIndex)))
        cells[sectionIdentifier(for: index)] = nil
    }
    
    /// Removes the first section of the specified identifier (in case the identifier exists)
    /// - Parameter identifier: Identifier of the section to remove
    internal func removeSection(with identifier: String) {
        if let index = sections.firstIndex(of: identifier) {
            removeSection(at: index)
        }
    }
    
    //MARK: addCell(...)
    
    /// Appends a cell to the section of the specified section identifier
    /// - Parameters:
    ///   - identifier: Identifier for the cell
    ///   - section: Identifier for the section where the cell will be added. The identifier has to be valid otherwise the cell won't be added.
    internal func addCell(with identifier: String, at section: String) {
        cells[section]?.append(identifier)
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
    
    //MARK: removeCell(...)
    
    /// Removes the cell of the specified section - row
    /// - Parameters:
    ///   - section: Section index of the cell
    ///   - row: Row index of the cell
    internal func removeCell(at section: Int, row: Int) {
        let identifier = sectionIdentifier(for: section)
        cells[identifier]?.remove(at: row)
        
        if let cells = cells[identifier], cells.isEmpty {
            self.cells[identifier] = nil
            self.sections.remove(at: section)
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
        cells[section]?.remove(at: row)
    }
    
    
    

}
