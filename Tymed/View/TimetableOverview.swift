//
//  TimetableOverview.swift
//  Tymed
//
//  Created by Jonah Schueller on 08.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

//MARK: TimetableOverview
struct TimetableOverview: View {
    
//    @State
//    var timetables: [Timetable] = TimetableService.shared.fetchTimetables() ?? []
    
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(
        entity: Timetable.entity(),
        sortDescriptors: [])
    var timetables: FetchedResults<Timetable>
    
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
    
    @Environment(\.managedObjectContext) var moc
    
    @State
    var timetable: Timetable
    
    var body: some View {
        HStack {
            Text(timetable.name ?? "")
                .font(.system(size: 15, weight: .semibold))
            
            Spacer()
            
            if timetable.isDefault {
                Text("Default")
                    .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                    .background(Color(.tertiarySystemGroupedBackground))
                    .font(.system(size: 13, weight: .semibold))
                    .cornerRadius(10)
            }
        }
    }
    
}



struct TimetableOverview_Previews: PreviewProvider {
    static var previews: some View {
        TimetableOverview()
    }
}
