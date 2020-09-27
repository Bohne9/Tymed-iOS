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
    @State private var showEventAdd = false
    
    //MARK: Tips
    @State private var showTips = true
    
    var body: some View {
        List {
            //MARK: Timetable list
            Section {
                ForEach(timetables, id: \.self) { (timetable: Timetable) in
                    NavigationLink(destination: TimetableDetail(timetable: timetable)) {
                        TimetableOverviewCell(timetable: timetable)
                            .frame(height: 55)
                    }.listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20))
                }
            }
            
            //MARK: Add timetable
            Section {
                HStack {
                    DetailCellDescriptor("Add calendar", image: "plus", .systemBlue)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(.tertiaryLabel))
                }.onTapGesture {
                    showTimetableAdd = true
                    showAddView.toggle()
                }
            }
            if showTips {
                Section {
                    VStack {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                            Text("Tips")
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    showTips = false
                                }
                            }, label: {
                                Image(systemName: "multiply")
                                    .foregroundColor(.white)
                            }).contentShape(Rectangle())
                        }.font(.system(size: 15, weight: .semibold))
                        Spacer()
                        HStack {
                            Text("You can add multiple calendars!")
                                .font(.system(size: 14, weight: .regular))
                                .lineLimit(-1)
                                Spacer()
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(height: 70)
                    .background(Color(UIColor(named: "orange")!))
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .transition(AnyTransition.scale)
            }
            
            Section {
                ProAccessBadge()
            }
            
        }.listStyle(InsetGroupedListStyle())
        .transition(.scale)
        .font(.system(size: 16, weight: .semibold))
        .navigationBarItems(trailing: Button {
            showAddActionSheet = true
        } label: {
            Image(systemName: "plus")
        })
        .sheet(isPresented: $showAddView, onDismiss: {
            showLessonAdd = false
            showTaskAdd = false
            showEventAdd = false
            showTimetableAdd = false
        }, content: {
            if showLessonAdd {
                LessonAddView(dismiss: { })
            }else if showTaskAdd {
                TaskAddView(dismiss: { })
            }else if showEventAdd {
                EventAddView()
            }else {            
                TimetableAddView()
            }
        })
        .actionSheet(isPresented: $showAddActionSheet, content: {
            ActionSheet(title: Text("What would you like to add?"), message: Text(""), buttons: [
                .default(Text("Event"), action: {
                    showEventAdd = true
                    showAddView.toggle()
                }),
                .default(Text("Task"), action: {
                    showTaskAdd = true
                    showAddView.toggle()
                }),
                .default(Text("Lesson"), action: {
                    showLessonAdd = true
                    showAddView.toggle()
                }),
                .default(Text("Calendar"), action: {
                    showTimetableAdd = true
                    showAddView.toggle()
                }),
                .cancel()
            ])
        })
        .navigationTitle("Calendars")
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
}


//MARK: TimetableOverviewCell
struct TimetableOverviewCell: View {
    
    @Environment(\.managedObjectContext) var moc
    
    @State
    var timetable: Timetable
    
    var body: some View {
        HStack {
            Rectangle()
                .foregroundColor(Color(UIColor(timetable) ?? .clear))
                .frame(width: 12.5, height: 55)
            
            Text(timetable.name)
                .font(.system(size: 15, weight: .semibold))
            
            Spacer()
            
            if timetable.isDefault {
                Text("Default")
                    .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                    .background(Color(.tertiarySystemGroupedBackground))
                    .font(.system(size: 13, weight: .semibold))
                    .cornerRadius(10)
            }
        }.listRowInsets(.none)
    }
    
}



struct TimetableOverview_Previews: PreviewProvider {
    static var previews: some View {
        TimetableOverview()
    }
}
