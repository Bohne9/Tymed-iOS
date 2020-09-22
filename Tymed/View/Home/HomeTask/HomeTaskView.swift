//
//  HomeTaskView.swift
//  Tymed
//
//  Created by Jonah Schueller on 19.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

class HomeTaskViewWrapper: ViewWrapper<HomeTaskView> {
    
    var homeViewModel: HomeViewModel?
    
    override func createContent() -> UIHostingController<HomeTaskView>? {
        guard let homeViewModel = self.homeViewModel else {
            return nil
        }
        
        return UIHostingController(rootView: HomeTaskView(homeViewModel: homeViewModel))
    }
    
}

//MARK: HomeTaskView
struct HomeTaskView: View {
    
    @ObservedObject
    var homeViewModel: HomeViewModel
    
    @State
    private var showTaskAdd = false
    
    var body: some View {
        
        //MARK: HomeTaskViewContent
        if !homeViewModel.tasks.isEmpty {
            HomeTaskViewContent(homeViewModel: homeViewModel)
        }else {
            List {
                
                //MARK: No tasks image
                Section {
                    
                    VStack(spacing: 20) {
                        
                        Spacer()
                        
                        Image(ImageSupplier.shared.get(for: .homeEmptyTasks))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.horizontal, 30)

                        Button(action: {
                            showTaskAdd.toggle()
                        }, label: {
                            HStack {
                                Spacer()
                                Image(systemName: "plus")
                                Text("Add a task")
                                Spacer()
                            }.font(.system(size: 17.5, weight: .semibold))
                            .padding()
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                        })
                        
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                    .background(Color(.systemGroupedBackground))
                }.listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                //MARK: Recently archived
                if BackgroundRoutineService.standard.archivedTasksOfSession?.count ?? 0 > 0 {
                    
                    if let tasks = BackgroundRoutineService.standard.archivedTasksOfSession {
                        Section (header: HStack {
                            Text("Recently archived")
                            Spacer()
//                            Button("Put back") {
//                                tasks.forEach { $0.archived = false }
//                                TimetableService.shared.save()
//                                BackgroundRoutineService.standard.archivedTasksOfSession = []
//                                homeViewModel.reload()
//                            }.foregroundColor(Color(.systemBlue))
                        }.font(.system(size: 14, weight: .semibold))) {
                            VStack {
                                ForEach(tasks, id: \.self) { task in
                                    HomeTaskCell(task: task)
                                        .environmentObject(homeViewModel)
                                        .frame(height: 45)
                                }
                            }.listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 20))
                        }
                    }
                    
                    Section {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(Color(.systemBlue))
                                .font(.system(size: 18, weight: .semibold))
                            Text("Learn more about automatic task archiving")
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(.secondaryLabel))
                        }.font(.system(size: 14, weight: .semibold))
                    }
                    
                }
                
            }.listStyle(InsetGroupedListStyle())
            .sheet(isPresented: $showTaskAdd, content: {
                TaskAddView {
                    homeViewModel.reload()
                }
            })
        }
        
    }
    
}

//MARK: HomeTaskViewContent
struct HomeTaskViewContent: View {
    
    @ObservedObject
    var homeViewModel: HomeViewModel
    
    var body: some View {
        List {
            
            Section {
                // Combine the timetables with the percentage of their completed tasks
                // Filter any timetables without any tasks (where the value is -1)
                ForEach(homeViewModel.timetables.map { ($0, taskCompletePercentage(for: $0)) }.filter { $0.1 != -1 }, id: \.0.self) { timetable, value in
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                        
                            Text(timetable.name)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(.label))
                            
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .frame(width: geometry.size.width * 0.9 + 7.5, height: 7.5)
                                            .cornerRadius(3.75)
                                            .foregroundColor(Color(.tertiaryLabel))

                                        Rectangle()
                                            .frame(width: geometry.size.width * 0.9 * value + 7.5, height: 7.5)
                                            .cornerRadius(3.75)
                                            .foregroundColor(Color(UIColor(timetable) ?? .clear))
                                    }.frame(width: geometry.size.width * 0.9 + 7.5, height: 7.5)
                                }
                            
                        }
                        
                        Text("\(String(format: "%.1f", value * 100))%")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(.secondaryLabel))
                    }
                }
            }
            
            ForEach(homeViewModel.tasks, id: \.self) { task in
                Section {
                    HomeTaskCell(task: task)
                        .frame(height: 45)
                }
            }
            
        }.listStyle(InsetGroupedListStyle())
        .environmentObject(homeViewModel)
    }
    
    
    func taskCompletePercentage(for timetable: Timetable) -> CGFloat {
        let tasks = homeViewModel.tasks(for: timetable)
        
        if tasks.count == 0 {
            return -1
        }
        
        let complete = CGFloat(tasks.filter { $0.completed }.count)
        
        return complete / CGFloat(tasks.count)
    }
    
}




struct HomeTaskView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTaskView(homeViewModel: HomeViewModel())
            .colorScheme(.dark)
    }
}
 
