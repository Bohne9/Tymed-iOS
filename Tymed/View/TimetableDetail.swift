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
    
    @State
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
            Section {
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
                                    Text("See all")
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
                    })
            }
            
            //MARK: Default
            Section {
                HStack {
                    DetailCellDescriptor("Default timetable", image: "circle.fill", .systemGreen)
                
                    Toggle("", isOn: $isDefault).labelsHidden()
                }
            }
            
            //MARK: Delete
            Section {
                
                DetailCellDescriptor("Delete", image: "trash", .systemRed)
                
            }
            
        }.listStyle(InsetGroupedListStyle())
        .navigationTitle("Timetable")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: isDefault) { (value) in
            print("save")
            timetable.isDefault = isDefault
            
            do {
                try self.moc.save()
                print("Saved")
            } catch {
                print(error.localizedDescription)
            }
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


struct ArchivedTasksOverview: View {
    
    @State var timetable: Timetable
    
    @State private var showTaskDetail = false
    @State private var task: Task?
    
    var body: some View {
        List {
            Section {
                DetailCellDescriptor("Delete all archived tasks", image: "trash", .systemRed)
                    .onTapGesture {
                        deleteAllTasks()
                    }
            }
            
            Section(header: Text("Manually archived")) {
                ForEach(archivedTasksWithOutDue(), id: \.self) { (task: Task) in
                    HStack {
                        TaskPreviewCell(task: task)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                    .frame(height: 50)
                    .onTapGesture {
                        self.task = task
                        self.showTaskDetail.toggle()
                    }
                }.onDelete { (index) in
                    index.forEach { deleteTask(at: $0, hasDue: false) }
                }
            }
            
            Section(header: Text("Recently expired")) {
                ForEach(archivedTasksWithDue(), id: \.self) { (task: Task) in
                    HStack {
                        TaskPreviewCell(task: task)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                    .frame(height: 50)
                    .onTapGesture {
                        self.task = task
                        self.showTaskDetail.toggle()
                    }
                }.onDelete { (index) in
                    index.forEach { deleteTask(at: $0, hasDue: true) }
                }
            }
        }.listStyle(InsetGroupedListStyle())
        .navigationTitle("Archived tasks")
        .sheet(isPresented: $showTaskDetail) {
            if task != nil {
                TaskEditView(task: task!) {
                    
                }
            } else {
                Text("Ups! An error occurred :(")
            }
        }
    }
    
    func archivedTasksWithOutDue() -> [Task] {
        return (timetable.tasks?.allObjects as? [Task] ?? []).filter { $0.archived && $0.due == nil }.sorted()
    }
    
    func archivedTasksWithDue() -> [Task] {
        return (timetable.tasks?.allObjects as? [Task] ?? []).filter { $0.archived && $0.due != nil }.sorted()
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
