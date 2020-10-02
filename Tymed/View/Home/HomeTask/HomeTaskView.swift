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
                }.sheet(isPresented: $showTaskAdd, onDismiss: taskViewModel.reload, content: {
                    TaskAddView {
                        homeViewModel.reload()
                    }
                })

            }
            
            
            //MARK: HomeTaskViewContent
            if taskViewModel.hasTasks {
                HomeTaskViewContent(taskViewModel: taskViewModel)
            }else {
                
                HomeDashTaskView(taskViewModel: taskViewModel)
                
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
                        HStack {
                            Spacer()
                            Label("Add a task", systemImage: "plus")
                                .font(.system(size: 17.5, weight: .semibold))
                            Spacer()
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                    }).sheet(isPresented: $showTaskAdd, onDismiss: taskViewModel.reload, content: {
                        TaskAddView {
                            homeViewModel.reload()
                        }
                    })
                    
                    Spacer()
                }.padding(.horizontal, 30)
            }
            /*
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
            */
            Spacer()
        }.padding()
        .onAppear {
            taskViewModel.reload()
            homeViewModel.reload()
        }
        .environmentObject(homeViewModel)
    }
    
}

//MARK: HomeTaskViewContent
struct HomeTaskViewContent: View {
    
    @ObservedObject
    var taskViewModel: TaskViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HomeDashTaskView(taskViewModel: taskViewModel)
            
            if !taskViewModel.overdueTasks.isEmpty {
                // Overdue header
                HStack {
                    Text("Overdue")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Spacer()
                    
                    Button("Reschedule") {
                        taskViewModel.overdueTasks.forEach { (task) in
                            task.due = Date() + 3600 * 2
                        }
                        TimetableService.shared.save()
                        taskViewModel.reload()
                    }.font(.system(size: 14, weight: .semibold))
                }
                
                ForEach(taskViewModel.overdueTasks, id: \.self) { task in
                    HomeTaskCell(task: task)
                }
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
                        taskViewModel.overdueTasks.forEach { (task) in
                            task.unarchive()
                            task.due = Date() + 3600 * 2
                        }
                        TimetableService.shared.save()
                        taskViewModel.reload()
                    }.font(.system(size: 14, weight: .semibold))
                }.font(.system(size: 16, weight: .semibold))
                
                ForEach(taskViewModel.recentlyArchived, id: \.self) { task in
                    HomeTaskCell(task: task)
                }
            }
            
            HomeTaskViewHelp()
            
            if !taskViewModel.archivedTasks.isEmpty {
                HStack {
                    Image(systemName: "tray.full.fill")
                        .foregroundColor(Color(.systemBlue))
                        .font(.system(size: 16, weight: .semibold))
                    Text("Archive")
                        .font(.system(size: 14, weight: .semibold))
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color(.secondaryLabel))
                        .font(.system(size: 12, weight: .semibold))
                    
                }.padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .frame(height: 40)
                .padding(.vertical)
            }
            
        }.environmentObject(taskViewModel)
    }
    
}

//MARK: HomeTaskViewSection
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

//MARK: HomeTaskViewHelp
struct HomeTaskViewHelp: View {
    
    @State
    private var showHelpView = false
    
    var body: some View {
        
        HStack(alignment: .top) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(Color(.systemBlue))
                .font(.system(size: 15, weight: .semibold))
                .padding(.top, 2.5)
            VStack(alignment: .leading, spacing: 5) {
                Text("Need help?")
                    .font(.system(size: 14, weight: .semibold))
                
                Text("Learn about the icons and more.")
                    .foregroundColor(Color(.secondaryLabel))
                    .font(.system(size: 12, weight: .regular))
            }
            Spacer()
            
            VStack {
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(.secondaryLabel))
                    .font(.system(size: 12, weight: .semibold))
                Spacer()
            }
        }.padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .frame(height: 45)
        .padding(.vertical)
        .onTapGesture {
            showHelpView.toggle()
        }.sheet(isPresented: $showHelpView) {
            Text("Help")
        }
    }
    
}


struct HomeTaskView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTaskView(homeViewModel: HomeViewModel())
            .colorScheme(.dark)
    }
}
 
