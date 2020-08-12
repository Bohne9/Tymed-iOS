//
//  TimetableDetail.swift
//  Tymed
//
//  Created by Jonah Schueller on 08.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

struct TimetableDetail: View {
    
    @Environment(\.managedObjectContext) var moc
    
    @ObservedObject
    var timetable: Timetable
    
    @State
    var isDefault = false
    
    var maxNumberOfSubjects = 4
    var maxNumberOfTasks = 4
    
    @State private var showLessonAdd = false
    @State private var showTaskAdd = false
    
    var body: some View {
        
        List {
            //MARK: Name
            Section(header: Text("Name").font(.system(size: 12, weight: .semibold))) {
                Text(timetable.name ?? "")
            }
            
            //MARK: Subjects
            Section(header: Text("Subjects").font(.system(size: 12, weight: .semibold))) {
                if subjects().count > 0 {
                    ForEach(subjects().prefix(maxNumberOfSubjects), id: \.self) { subject in
                        NavigationLink(
                            destination: Text("Subject detail"),
                            label: {
                                HStack {
                                    Circle()
                                        .foregroundColor(Color(UIColor(subject) ?? .clear))
                                        .frame(width: 10, height: 10)
                                    Text(subject.name ?? "")
                                        .font(.system(size: 15, weight: .semibold))
                                    Spacer()
                                    Text("\(subject.lessons?.count ?? 0) lessons")
                                        .font(.system(size: 12, weight: .semibold))
                                }.frame(height: 45)
                            })
                    }
                    if subjects().count > maxNumberOfSubjects {
                        NavigationLink(
                            destination: Text("See all subjects"),
                            label: {
                                HStack {
                                    Text("See all subjects")
                                    Spacer()
                                }.foregroundColor(Color(.systemBlue))
                                .font(.system(size: 15, weight: .semibold))
                            })
                    }
                }else {
                    HStack {
                        DetailCellDescriptor("Add your first lesson", image: "plus", .systemBlue)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                    .onTapGesture {
                        showLessonAdd.toggle()
                    }
                    .sheet(isPresented: $showLessonAdd) {
                        LessonAddView(timetable) {
                            
                        }
                    }
                }
            }
            
            //MARK: Tasks
            if unarchivedTasks().count > 0 {
                Section(header: Text("Tasks").font(.system(size: 12, weight: .semibold))) {
                    ForEach(unarchivedTasks().prefix(maxNumberOfTasks), id: \.self) { task in
                        NavigationLink(
                            destination: TaskEditContent(task: task, dismiss: {
                                
                            }).navigationBarItems(trailing: EmptyView()) ,
                            label: {
                                HStack {
                                    Text(task.title)
                                        .font(.system(size: 15, weight: .semibold))
                                    Spacer()
                                }.frame(height: 45)
                            })
                    }
                    if unarchivedTasks().count > maxNumberOfTasks {
                        NavigationLink(
                            destination: Text("See all tasks"),
                            label: {
                                HStack {
                                    Text("See all")
                                    Spacer()
                                }.foregroundColor(Color(.systemBlue))
                                .font(.system(size: 15, weight: .semibold))
                            })
                    }
                }
            }
            
            //MARK: Archived tasks
            Section {
                NavigationLink(
                    destination: ArchivedTasksOverview(timetable: timetable),
                    label: {
                        DetailCellDescriptor("Archived tasks", image: "tray.full.fill", .systemOrange)
                            .font(.system(size: 15, weight: .semibold))
                    })
            }
            
            //MARK: Default
            Section {
                HStack {
                    DetailCellDescriptor("Default timetable", image: "circle.fill", .systemGreen)
                        .font(.system(size: 15, weight: .semibold))
                    Toggle("", isOn: $timetable.isDefault).labelsHidden()
                }
            }
            
            //MARK: Delete
            Section {
                DetailCellDescriptor("Delete", image: "trash", .systemRed)
                    .font(.system(size: 15, weight: .semibold))
            }
            
        }.listStyle(InsetGroupedListStyle())
        .navigationTitle("Timetable")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: timetable.isDefault) { (value) in
            TimetableService.shared.setDefaultTimetable(timetable)
        }.onAppear(perform: loadValues)
    }
    
    //MARK: loadValues
    private func loadValues() {
        isDefault = timetable.isDefault
    }
    
    //MARK: subjects
    private func subjects() -> [Subject] {
        return timetable.subjects?.allObjects as? [Subject] ?? []
    }
    
    //MARK: unarchivedTasks
    private func unarchivedTasks() -> [Task] {
        return (timetable.tasks?.allObjects as? [Task] ?? []).filter { !$0.archived }
    }
}


//MARK: ArchivedTasksOverview
struct ArchivedTasksOverview: View {
    
    @ObservedObject
    var timetable: Timetable
    
    var body: some View {
        List {
            //MARK: Delete all
            Section {
                DetailCellDescriptor("Delete all archived tasks", image: "trash", .systemRed)
                    .onTapGesture {
                        deleteAllTasks()
                    }
            }
            
            //MARK: Manually archived
            Section(header: Text("Manually archived")) {
                ForEach(archivedTasksWithOutDue(), id: \.self) { (task: Task) in
                    NavigationLink(destination:
                                    TaskEditContent(task: task, dismiss: { })
                                    .navigationBarItems(trailing: EmptyView())
                    ) {
                        TaskPreviewCell(task: task)
                            .frame(height: 50)
                    }
                }.onDelete { (index) in
                    index.forEach { deleteTask(at: $0, hasDue: false) }
                }
            }
            
            //MARK: Expired
            Section(header: Text("Expired")) {
                ForEach(archivedTasksWithDue(), id: \.self) { (task: Task) in
                    NavigationLink(destination:
                                    TaskEditContent(task: task, dismiss: { })
                                    .navigationBarItems(trailing: EmptyView())
                    ) {
                        TaskPreviewCell(task: task)
                            .frame(height: 50)
                    }
                }
                .onDelete { (index) in
                    index.forEach { deleteTask(at: $0, hasDue: true) }
                }
            }
        }.listStyle(InsetGroupedListStyle())
        .navigationTitle("Archived tasks")
    }
    
    func archivedTasksWithOutDue() -> [Task] {
        return (timetable.tasks?.allObjects as? [Task] ?? []).filter { $0.archived && $0.due == nil }.sorted().reversed()
    }
    
    func archivedTasksWithDue() -> [Task] {
        return (timetable.tasks?.allObjects as? [Task] ?? []).filter { $0.archived && $0.due != nil }.sorted().reversed()
    }
    
    func deleteTask(at index: IndexSet.Element, hasDue: Bool) {
        
        let task = (hasDue ? archivedTasksWithDue() : archivedTasksWithOutDue())[index]
        
        TimetableService.shared.deleteTask(task)
        
    }
    
    func deleteAllTasks() {
        timetable.tasks?.forEach({ (task) in
            guard let task = task as? Task else {
                return
            }
            
            TimetableService.shared.deleteTask(task)
        })
    }
}
