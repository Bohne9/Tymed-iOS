//
//  TimetableOverview.swift
//  Tymed
//
//  Created by Jonah Schueller on 08.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

//MARK: TimetableOverview
struct TimetableOverview: View {
    
//    @State
//    var timetables: [Timetable] = TimetableService.shared.fetchTimetables() ?? []
    
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(
        entity: Timetable.entity(),
        sortDescriptors: [])
    var timetables: FetchedResults<Timetable>
    
    @State private var showAddActionSheet = false
    
    @State private var showAddView = false
    @State private var showLessonAdd = false
    @State private var showTaskAdd = false
    @State private var showTimetableAdd = false
    
    var body: some View {
        List {
            //MARK: Timetable list
            Section {
                ForEach(timetables, id: \.self) { (timetable: Timetable) in
                    NavigationLink(destination: TimetableDetail(timetable: timetable)
                                    .environment(\.managedObjectContext, moc)) {
                        HStack {
                            Text(timetable.name ?? "")
                                .font(.system(size: 15, weight: .semibold))
                            
                            Spacer()
                            
                            if timetable.isDefault {
                                Text("Default")
                                    .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                                    .background(Color(.tertiarySystemGroupedBackground))
                                    .font(.system(size: 13, weight: .semibold))
                                    .cornerRadius(10)
                            }
                        }
                            .frame(height: 45)
                    }
                }
            }
            
            //MARK: Add timetable
            Section {
                HStack {
                    DetailCellDescriptor("Add timetable", image: "plus", .systemBlue)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(.tertiaryLabel))
                }.onTapGesture {
                    showTimetableAdd = true
                    showAddView.toggle()
                }
            }
            
            HStack {
                Spacer()
                
//                Image("Group 12-1024")
                
                Spacer()
            }
            
        }.listStyle(InsetGroupedListStyle())
        .font(.system(size: 16, weight: .semibold))
        .navigationBarItems(trailing: Button {
            showAddActionSheet = true
        } label: {
            Image(systemName: "plus")
        })
        .sheet(isPresented: $showAddView, onDismiss: {
            showLessonAdd = false
            showTaskAdd = false
            showTimetableAdd = false
        }, content: {
            if showLessonAdd {
                LessonAddView(dismiss: { })
            }else if showTaskAdd {
                TaskAddView(dismiss: { })
            }else {
                Text("Timetable")
            }
        })
        .actionSheet(isPresented: $showAddActionSheet, content: {
            ActionSheet(title: Text("What do you want to add?"), message: Text(""), buttons: [
                .default(Text("Lesson"), action: {
                    showLessonAdd = true
                    showAddView.toggle()
                }),
                .default(Text("Task"), action: {
                    showTaskAdd = true
                    showAddView.toggle()
                }),
                .default(Text("Timetable"), action: {
                    showTimetableAdd = true
                    showAddView.toggle()
                }),
                .destructive(Text("Cancel"), action: {
                    showAddActionSheet = false
                })
            ])
        })
        .navigationTitle("Timetable")
    }
}


//MARK: TimetableOverviewCell
struct TimetableOverviewCell: View {
    
    @Environment(\.managedObjectContext) var moc
    
    @State
    var timetable: Timetable
    
    var body: some View {
        HStack {
            Text(timetable.name ?? "")
                .font(.system(size: 15, weight: .semibold))
            
            Spacer()
            
            if timetable.isDefault {
                Text("Default")
                    .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                    .background(Color(.tertiarySystemGroupedBackground))
                    .font(.system(size: 13, weight: .semibold))
                    .cornerRadius(10)
            }
        }
    }
    
}



struct TimetableOverview_Previews: PreviewProvider {
    static var previews: some View {
        TimetableOverview()
    }
}
