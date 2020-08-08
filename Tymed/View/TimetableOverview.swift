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

//MARK: TimetableOverview
struct TimetableOverview: View {
    
    @State
    var timetables: [Timetable] = TimetableService.shared.fetchTimetables() ?? []
    
    var body: some View {
        List {
            ForEach(timetables, id: \.self) { (timetable: Timetable) in
                NavigationLink(destination: TimetableDetail(timetable: timetable)) {
                    TimetableOverviewCell(timetable: timetable)
                        .frame(height: 45)
                }
            }
        }.listStyle(InsetGroupedListStyle())
        .font(.system(size: 16, weight: .semibold))
    }
}

//MARK: TimetableOverviewCell
struct TimetableOverviewCell: View {
    
    var timetable: Timetable
    
    var body: some View {
        Text(timetable.name ?? "")
            .font(.system(size: 15, weight: .semibold))
    }
    
}



struct TimetableOverview_Previews: PreviewProvider {
    static var previews: some View {
        TimetableOverview()
    }
}
