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
    
    var body: some View {
        
        List {
            //MARK: Name
            Section {
                Text(timetable.name ?? "")
            }
            
            //MARK: Subjects
            Section(header: Text("Subjects").font(.system(size: 12, weight: .semibold))) {
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
                
            }
            
            //MARK: Tasks
            Section(header: Text("Tasks").font(.system(size: 12, weight: .semibold))) {
                ForEach(unarchivedTasks().prefix(maxNumberOfTasks), id: \.self) { task in
                    NavigationLink(
                        destination: TaskEditContent(task: task, dismiss: {
                            
                        }).navigationBarItems(trailing: EmptyView()) ,
                        label: {
                            HStack {
                                Text(task.title ?? "")
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
            
            //MARK: Archived tasks
            Section {
                NavigationLink(
                    destination: Text("Archived Tasks"),
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
    
    private func loadValues() {
        isDefault = timetable.isDefault
    }
    
    private func subjects() -> [Subject] {
        return timetable.subjects?.allObjects as? [Subject] ?? []
    }
    
    private func unarchivedTasks() -> [Task] {
        return (timetable.tasks?.allObjects as? [Task] ?? []).filter { !$0.archived }
    }
}

