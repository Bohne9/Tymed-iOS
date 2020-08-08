//
//  TimetableOverview.swift
//  Tymed
//
//  Created by Jonah Schueller on 08.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

class TimetableOverviewWrapper: UIViewController {
    
    var timetableOverview: TimetableOverview!
    
    var contentView: UIHostingController<TimetableOverview>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timetableOverview = TimetableOverview()
        contentView = UIHostingController(rootView: timetableOverview)
        addChild(contentView)
        view.addSubview(contentView.view)
        
        title = "Timetable"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        setupConstraints()
    }
    
    fileprivate func setupConstraints() {
        contentView.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        contentView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
}

struct TimetableOverview: View {
    var body: some View {
        List {
            ForEach(0..<50) { i in
                NavigationLink(destination: Text("Dest")) {
                    Text("fjowds")
                }
            }
        }.navigationTitle("Time")
    }
}

struct TimetableOverview_Previews: PreviewProvider {
    static var previews: some View {
        TimetableOverview()
    }
}
