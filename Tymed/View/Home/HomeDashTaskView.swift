//
//  HomeTaskTimetableOverviewView.swift
//  Tymed
//
//  Created by Jonah Schueller on 30.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI


struct HomeDashTaskView: View {
    
    @EnvironmentObject
    var homeViewModel: HomeViewModel
    
    @StateObject
    var taskViewModel: TaskViewModel
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
            ForEach(homeViewModel.timetables, id: \.self) { timetable in
                HomeDashTaskTimetableView(timetable: timetable)
            }
        }.environmentObject(taskViewModel)
    }
}

struct HomeDashTaskTimetableView: View {
    
    @ObservedObject
    var timetable: Timetable
    
    @EnvironmentObject
    var taskViewModel: TaskViewModel
    
    var body: some View {
        
        VStack(alignment: .leading) {
            TimetableBadgeView(timetable: timetable, size: .normal)
            
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
        return taskViewModel.remainingTasks(for: timetable).count
    }
    
    private func doneTasksCount() -> Int {
        return taskViewModel.completedTasks(for: timetable).count
    }
}

