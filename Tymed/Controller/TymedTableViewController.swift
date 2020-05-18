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
    
    private var cells: [[String]] = [[]]
    
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
    
    

    internal func register(_ cellClass: AnyClass, identifier: String) {
        tableView.register(cellClass, forCellReuseIdentifier: identifier)
    }
    
    private func identifier(for indexPath: IndexPath) -> String {
        return cells[indexPath.section][indexPath.row]
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func configureCell(_ cell: UITableViewCell, for identifier: String, at indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = self.identifier(for: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)

        configureCell(cell, for: identifier, at: indexPath)

        return cell
    }

    
    internal func addSection(with identifier: String) {
        sections.append(identifier)
    }
    
    internal func addSection(with identfier: String, at: Int) {
        
    }

}
