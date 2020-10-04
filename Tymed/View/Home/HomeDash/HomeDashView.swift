//
//  HomeDashView.swift
//  Tymed
//
//  Created by Jonah Schueller on 17.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

fileprivate var heightForHour: CGFloat = 60

class HomeDashViewWrapper: ViewWrapper<HomeDashView> {
    
    var homeViewModel: HomeViewModel?
    
    override func createContent() -> UIHostingController<HomeDashView>? {
        guard let homeViewModel = self.homeViewModel else {
            return nil
        }
        
        return UIHostingController(rootView: HomeDashView(homeViewModel: homeViewModel))
    }
    
}

//MARK: HomeDashView
struct HomeDashView: View {
    
    @ObservedObject
    var homeViewModel: HomeViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                
                HomeDashHeaderView()
                
                HomeDashOverviewView()
                
                VStack(alignment: .leading) {
                    Text("Tasks")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(.label))
                    
                    HomeDashTaskView(taskViewModel: TaskViewModel())
                }
                
                ForEach(homeViewModel.calendarWeek.entries, id: \.date) { day in
                    VStack(alignment: .leading) {
                        Text("\(day.date.stringify(with: .medium))")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(.label))
                            .padding(.leading, 5)
                        HomeDashCalendarView(event: day)
                    }
                }
                
            }
            .padding()
            .environmentObject(homeViewModel)
            .onAppear {
                homeViewModel.reload()
            }
        }
    }
}

//MARK: HomeDashCalendarView
struct HomeDashCalendarView: View {
    
    @EnvironmentObject
    var timetableService: TimetableService
    
    @ObservedObject
    var event: CalendarDayEntry
    
    @EnvironmentObject
    var homeViewModel: HomeViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            HomeDashCalendarGrid(date: event.date, startHour: startHour(), endHour: startHour() + numberOfHours())
                .frame(height: CGFloat(numberOfHours()) * heightForHour)
                .padding(.top, CGFloat(event.allDayEntries.count * 20) + 10)
                .padding(.bottom, 10)
            
            HomeDashCalendarContent(events: event)
                .frame(height: CGFloat(numberOfHours()) * heightForHour)
                .padding(.top, CGFloat(event.allDayEntries.count * 20) + 10)
                .padding(.bottom, 10)
            
            HomeAllDayEvents(events: event)
                .padding(.vertical, 10)
                .frame(height: CGFloat(event.allDayEntries.count * 20))
        }.frame(height: CGFloat(numberOfHours()) * heightForHour + 40  + CGFloat(event.allDayEntries.count * 20))
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func numberOfHours() -> Int {
        guard let start = event.startOfDay,
              let end = event.endOfDay else {
            return 1
        }
        
        let startHour = Calendar.current.dateComponents([.hour], from: start).hour ?? 0
        let endHour = Calendar.current.dateComponents([.hour], from: end).hour ?? 0
        
        return (endHour - startHour + 1)
    }
    
    private func startHour() -> Int {
        guard let start = event.startOfDay else {
            return 0
        }
        
        return Calendar.current.dateComponents([.hour], from: start).hour ?? 0
    }
    
}

struct HomeDashView_Previews: PreviewProvider {
    static var previews: some View {
        HomeDashView(homeViewModel: HomeViewModel()).colorScheme(.dark)
    }
}
