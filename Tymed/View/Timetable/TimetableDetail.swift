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
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject
    var timetable: Timetable
    
    @State
    var isDefault = false
    
    var maxNumberOfSubjects = 4
    var maxNumberOfTasks = 4
    
    @State private var showLessonAdd = false
    @State private var showTaskAdd = false
    @State private var showTimetableDeleteAlert = false
    
    var body: some View {
        
        List {
            //MARK: Name
            Section(header: Text("Name").font(.system(size: 12, weight: .semibold))) {
                
                TextField("Calendar name", text: $timetable.name)
                
            }
            
            //MARK: Subjects
            Section(header: Text("Subjects").font(.system(size: 12, weight: .semibold))) {
                if subjects().count > 0 {
                    ForEach(subjects().prefix(maxNumberOfSubjects), id: \.self) { subject in
                        NavigationLink(
                            destination: SubjectEditView(subject: subject),
                            label: {
                                HStack {
                                    Circle()
                                        .foregroundColor(Color(UIColor(subject) ?? .clear))
                                        .frame(width: 10, height: 10)
                                    Text(subject.name)
                                        .font(.system(size: 15, weight: .semibold))
                                    Spacer()
                                    Text("\(subject.lessons?.count ?? 0) lessons")
                                        .font(.system(size: 12, weight: .semibold))
                                }.frame(height: 45)
                            })
                    }
                    if subjects().count > maxNumberOfSubjects {
                        NavigationLink(
                            destination: AllSubjectsOverviewView(timetable: timetable),
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
                                TaskPreviewCell(task: task)
                                    .frame(height: 50)
                            })
                    }
                    if unarchivedTasks().count > maxNumberOfTasks {
                        NavigationLink(
                            destination: AllTasksOverviewView(timetable: timetable),
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
            if archivedTasks().count > 0 { // Only show the section if there are any archived tasks.
                Section {
                    NavigationLink(
                        destination: ArchivedTasksOverview(timetable: timetable),
                        label: {
                            DetailCellDescriptor("Archived tasks", image: "tray.full.fill", .systemOrange)
                                .font(.system(size: 15, weight: .semibold))
                        })
                }
            }
            
            //MARK: Default
            Section {
                HStack {
                    DetailCellDescriptor("Default calendar", image: "circle.fill", .systemGreen)
                        .font(.system(size: 15, weight: .semibold))
                    Toggle("", isOn: $timetable.isDefault).labelsHidden()
                }
            }
            
            //MARK: Color
            Section {
                NavigationLink(destination: AppColorPickerView(color: $timetable.color)) {
                    DetailCellDescriptor("Color", image: "paintbrush.fill", UIColor(timetable) ?? .clear, value: timetable.color.capitalized)
                }
            }
            
            //MARK: Delete
            Section {
                DetailCellDescriptor("Delete", image: "trash", .systemRed)
                    .font(.system(size: 15, weight: .semibold))
                    .onTapGesture {
                        showTimetableDeleteAlert.toggle()
                    }
            }
            
        }.listStyle(InsetGroupedListStyle())
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: timetable.isDefault) { (value) in
            TimetableService.shared.setDefaultTimetable(timetable)
        }.onAppear(perform: loadValues)
        .actionSheet(isPresented: $showTimetableDeleteAlert) {
            ActionSheet(
                title: Text("Are you sure?"),
                message: Text("You cannot undo this."),
                buttons: [.destructive(Text("Delete"), action: {
                    deleteTimetable()
                }), .cancel()])
        }.onChange(of: timetable.name) { value in
            TimetableService.shared.save()
        }
    }
    
    private func deleteTimetable() {
        TimetableService.shared.deleteTimetable(timetable)
        presentationMode.wrappedValue.dismiss()
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
    
    //MARK: archivedTasks
    private func archivedTasks() -> [Task] {
        return (timetable.tasks?.allObjects as? [Task] ?? []).filter { $0.archived }
    }
}


//MARK: ArchivedTasksOverview
struct ArchivedTasksOverview: View {
    
    @Environment(\.presentationMode) var presentationMode
    
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
            Section(header: Text("Archived")) {
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
        presentationMode.wrappedValue.dismiss()
    }
}




struct AllSubjectsOverviewView: View {
    
    @ObservedObject
    var timetable: Timetable
    
    var body: some View {
        List {
            ForEach(subjects()) { subject in
                NavigationLink(
                    destination: SubjectEditView(subject: subject),
                    label: {
                        HStack {
                            Circle()
                                .foregroundColor(Color(UIColor(subject) ?? .clear))
                                .frame(width: 10, height: 10)
                            Text(subject.name)
                                .font(.system(size: 15, weight: .semibold))
                            Spacer()
                            Text("\(subject.lessons?.count ?? 0) lessons")
                                .font(.system(size: 12, weight: .semibold))
                        }.frame(height: 45)
                    })
            }
        }.listStyle(InsetGroupedListStyle())
        .navigationTitle("All subjects")
    }
    
    func subjects() -> [Subject] {
        timetable.subjects?.allObjects as? [Subject] ?? []
    }
}

struct AllTasksOverviewView: View {
    
    @ObservedObject
    var timetable: Timetable
    
    var body: some View {
        List {
            ForEach(unarchivedTasks(), id: \.self) { task in
                NavigationLink(
                    destination: TaskEditContent(task: task, dismiss: { }).navigationBarItems(leading: EmptyView()),
                    label: {
                        TaskPreviewCell(task: task)
                            .frame(height: 50)
                    })
            }
        }.listStyle(InsetGroupedListStyle())
        .navigationTitle("All subjects")
    }
    
    //MARK: unarchivedTasks
    private func unarchivedTasks() -> [Task] {
        return (timetable.tasks?.allObjects as? [Task] ?? []).filter { !$0.archived }
    }
}
