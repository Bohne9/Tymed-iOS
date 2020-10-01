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
        VStack(alignment: .leading, spacing: 15) {

            Text("Tasks")
                .font(.system(size: 24, weight: .semibold))
            
            //MARK: HomeTaskViewContent
            if !homeViewModel.tasks.isEmpty {
                HomeTaskViewContent(homeViewModel: homeViewModel)
            }else {
                
                HomeDashTaskView()
                
                //MARK: No tasks image
                VStack(spacing: 20) {
                    
                    Spacer()
                    
                    Image(ImageSupplier.shared.get(for: .homeEmptyTasks))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.horizontal, 50)
                    
                    Button(action: {
                        showTaskAdd.toggle()
                    }, label: {
                        Label("Add a task", systemImage: "plus")
                            .font(.system(size: 17.5, weight: .semibold))
                            .padding()
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                    })
                    
                    Spacer()
                }.padding(.horizontal, 30)
            }
            //MARK: Recently archived
            if BackgroundRoutineService.standard.archivedTasksOfSession?.count ?? 0 > 0 {
                
                if let tasks = BackgroundRoutineService.standard.archivedTasksOfSession {
                    Section (header: HStack {
                        Text("Recently archived")
                        Spacer()
                    }.font(.system(size: 14, weight: .semibold))) {
                        VStack {
                            ForEach(tasks, id: \.self) { task in
                                HomeTaskCell(task: task)
                            }
                        }
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
            
            Spacer()
        }.padding()
        .environmentObject(homeViewModel)
        .sheet(isPresented: $showTaskAdd, content: {
            TaskAddView {
                homeViewModel.reload()
            }
        })
    }
    
}

//MARK: HomeTaskViewContent
struct HomeTaskViewContent: View {
    
    @ObservedObject
    var homeViewModel: HomeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HomeDashTaskView()
            
            // Overdue header
            HStack {
                Text("Overdue")
                
                Spacer()
                
                Button("Reschedule") {
                    
                }
            }.font(.system(size: 16, weight: .semibold))
            
            HStack {
                Text("Overdue")
                
                Spacer()
                
                Button("Reschedule") {
                    
                }
            }.font(.system(size: 16, weight: .semibold))
            
            
            ForEach(homeViewModel.tasks, id: \.self) { task in
                HomeTaskCell(task: task)
            }
        }
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
 
