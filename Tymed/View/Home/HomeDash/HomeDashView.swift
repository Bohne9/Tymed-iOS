//
//  HomeDashView.swift
//  Tymed
//
//  Created by Jonah Schueller on 17.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

fileprivate var heightForHour: CGFloat = 80

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
        List {
            
            Section {
                VStack(alignment: .leading) {
                    Text(Date().stringify(with: .full, relativeFormatting: false).uppercased())
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(.systemBlue))
                    
                    Text("Good morning Jonah 🙋‍♂️,\nyou got a busy day before.\nYour day starts at 8 am with Math. You'll be done at 7 pm. \n\nHave a great day! 👍")
                        .font(.system(size: 14, weight: .regular))
                        .padding(.top, 5)
                }
                .padding(.vertical, 10)
            }
            
            if homeViewModel.tasks.count > 0 {
                Section(header:
                            Text("Tasks")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(.label))) {
                    ForEach(homeViewModel.tasks, id: \.self) { task in
                        Section {
                            HomeDashTaskCell(task: task)
                                .frame(height: 45)
                        }
                    }
                }
            }
            
            Section(header:
                        Text("\(homeViewModel.upcomingCalendarDay.date.stringify(with: .medium))")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(.label))) {
                HomeDashCalendarView(event: homeViewModel.upcomingCalendarDay)
                    .environmentObject(homeViewModel)
            }
            
            if let nextCalendarDay = homeViewModel.nextCalendarDay {
                Section(header:
                            Text("\(nextCalendarDay.date.stringify(with: .medium))")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(.label))) {
                    HomeDashCalendarView(event: nextCalendarDay)
                        .environmentObject(homeViewModel)
                }
            }
            
            
        }.listStyle(InsetGroupedListStyle())
    }
}


//MARK: HomeDashTaskCell
struct HomeDashTaskCell: View {
    
    @EnvironmentObject
    var homeViewModel: HomeViewModel
    
    @ObservedObject
    var task: Task
    
    @State
    var showTaskDetail = false
    
    var body: some View {
        HStack(spacing: 15) {
            Rectangle()
                .foregroundColor(Color(UIColor(task.timetable)!))
                .frame(width: 10, height: 55)
            
            Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 22.5, weight: .semibold))
                .foregroundColor(Color(task.completed ? .systemGreen : .systemBlue))
                .frame(width: 25, height: 25)
                .onTapGesture {
                    withAnimation {
                        task.completed.toggle()
                    }
                }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(task.title)
                    .font(.system(size: 15, weight: .semibold))
                
                if let date = task.due {
                    Text(textFor(date: date))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(.secondaryLabel))
                }
            }
            
            Spacer()
        }.contentShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            showTaskDetail.toggle()
        }.sheet(isPresented: $showTaskDetail, content: {
            TaskEditView(task: task, dismiss: { })
        })
        .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 20))
    }
    
    private func textFor(date: Date) -> String {
        return "\(date.stringify(dateStyle: .short, timeStyle: .short))"
    }
    
}


struct HomeDashCalendarView: View {
    
    @ObservedObject
    var event: CalendarDayEntry
    
    @EnvironmentObject
    var homeViewModel: HomeViewModel
    
    var body: some View {
        ZStack {
            HomeDashCalendarGrid(date: event.date,startHour: startHour(), endHour: startHour() + numberOfHours())
                .frame(height: CGFloat(numberOfHours()) * heightForHour + 20)
                .padding(.vertical, 10)
            
            HomeDashCalendarContent(events: event)
                .frame(height: CGFloat(numberOfHours()) * heightForHour + 20)
                .padding(.vertical, 10)
        }
    }
    
    private func numberOfHours() -> Int {
        guard let start = event.startOfDay,
              let end = event.endOfDay else {
            return 0
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
