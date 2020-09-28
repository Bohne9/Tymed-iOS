//
//  HomeDashTaskVie.swift
//  Tymed
//
//  Created by Jonah Schueller on 28.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

struct HomeDashTaskView: View {
    
    @EnvironmentObject
    var homeViewModel: HomeViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Tasks".uppercased())
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(.label))
            
//            GeometryReader { geometry in
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                    ForEach(homeViewModel.timetables, id: \.self) { timetable in
                        HomeDashTaskTimetableView(timetable: timetable)
                    }
                }
//                .frame(width: geometry.size.width)
//            }
        }.padding()
    }
}

struct HomeDashTaskTimetableView: View {
    
    @ObservedObject
    var timetable: Timetable
    
    var body: some View {
        
        VStack(alignment: .leading) {
            TimetableBadgeView(timetable: timetable, size: .normal, color: .appColorLight)
            
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("\(remainingTasksCount())")
                        .font(.system(size: 25, weight: .bold))
                    
                    Text("Remaining".uppercased())
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(.secondaryLabel))
                }
                
                VStack(alignment: .leading) {
                    Text("\(doneTasksCount())")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(Color(.secondaryLabel))
                    
                    Text("Done".uppercased())
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(.tertiaryLabel))
                }
                Spacer()
            }
            
        }.padding(10)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
        
    }
    
    private func remainingTasksCount() -> Int {
        return (timetable.tasks?.allObjects as? [Task])?.filter { !$0.completed }.count ?? 0
    }
    
    private func doneTasksCount() -> Int {
        return (timetable.tasks?.allObjects as? [Task])?.filter { $0.completed }.count ?? 0
    }
}

struct HomeDashTaskView_Previews: PreviewProvider {
    static var previews: some View {
        HomeDashTaskView()
    }
}
