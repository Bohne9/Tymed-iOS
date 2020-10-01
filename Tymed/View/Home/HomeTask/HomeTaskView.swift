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

    @StateObject
    var taskViewModel = TaskViewModel()
    
    @State
    private var showTaskAdd = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {

            HStack {
                Text("Tasks")
                    .font(.system(size: 24, weight: .semibold))

                Spacer()
                
                Button {
                    showTaskAdd.toggle()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 25, weight: .semibold))
                }

            }
            
            
            //MARK: HomeTaskViewContent
            if taskViewModel.hasTasks {
                HomeTaskViewContent(taskViewModel: taskViewModel)
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
        .sheet(isPresented: $showTaskAdd, onDismiss: taskViewModel.reload, content: {
            TaskAddView {
                homeViewModel.reload()
            }
        })
    }
    
}

//MARK: HomeTaskViewContent
struct HomeTaskViewContent: View {
    
    @ObservedObject
    var taskViewModel: TaskViewModel
    
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
            
            ForEach(taskViewModel.overdueTasks, id: \.self) { task in
                HomeTaskCell(task: task)
            }
            
            if !taskViewModel.unlimitedTasks.isEmpty {
                HomeTaskViewSection(header: "Unlimited", tasks: taskViewModel.unlimitedTasks)
            }
            
            if !taskViewModel.todayTasks.isEmpty {
                HomeTaskViewSection(header: "Today", tasks: taskViewModel.todayTasks)
            }
            
            if !taskViewModel.weekTasks.isEmpty {
                HomeTaskViewSection(header: "Week", tasks: taskViewModel.weekTasks)
            }
            
            if !taskViewModel.laterTasks.isEmpty {
                HomeTaskViewSection(header: "Later", tasks: taskViewModel.laterTasks)
            }
            
            if !taskViewModel.recentlyArchived.isEmpty {
                // Recently archived header
                HStack {
                    Text("Recently Archived")
                    
                    Spacer()
                    
                    Button("Unarchive & reschedule") {
                        
                    }.font(.system(size: 14, weight: .semibold))
                }.font(.system(size: 16, weight: .semibold))
                
                ForEach(taskViewModel.recentlyArchived, id: \.self) { task in
                    HomeTaskCell(task: task)
                }
            }
            
        }
    }
    
}

struct HomeTaskViewSection: View {
    
    var header: String
    
    var tasks: [Task]
    
    var body: some View {
        
        VStack {
            HStack {
                Text(header)
                
                Spacer()
                
            }.font(.system(size: 16, weight: .semibold))
            
            ForEach(tasks, id: \.self) { task in
                HomeTaskCell(task: task)
            }
        }
        
    }
    
}


struct HomeTaskView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTaskView(homeViewModel: HomeViewModel())
            .colorScheme(.dark)
    }
}
 
