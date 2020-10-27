//
//  HomeTaskTimetableOverviewView.swift
//  Tymed
//
//  Created by Jonah Schueller on 30.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI
import EventKit

struct HomeDashTaskView: View {
    
    @EnvironmentObject
    var homeViewModel: HomeViewModel
    
    @StateObject
    var taskViewModel: TaskViewModel
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
            ForEach(taskViewModel.calendarsWithReminders(), id: \.self) { calendar in
                HomeDashTaskTimetableView(calendar: calendar)
            }
        }.environmentObject(taskViewModel)
    }
}

struct HomeDashTaskTimetableView: View {
    
    var calendar: EKCalendar
    
    @EnvironmentObject
    var taskViewModel: TaskViewModel
    
    var body: some View {
        
        VStack(alignment: .leading) {
            CalendarBadgeView(calendar: calendar, size: .normal)
            
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
        return taskViewModel.remainingTasks(for: calendar).count
    }
    
    private func doneTasksCount() -> Int {
        return taskViewModel.completedTasks(for: calendar).count
    }
}

