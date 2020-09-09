//
//  EventAddView.swift
//  Tymed
//
//  Created by Jonah Schueller on 09.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

//MARK: EventModel
class EventModel: ObservableObject {
    
    @Published
    public var title: String = ""
    
    @Published
    public var body: String = ""
    
    @Published
    public var start: Date = Date()
    
    @Published
    public var end: Date = Date() + 3600
    
    @Published
    public var notes: String = ""
    
    @Published
    public var notification: Date = Date()
    
    @Published
    public var task: Task?
    
    @Published
    public var subject: Subject?
    
    @Published
    public var lesson: Lesson?
    
    @Published
    public var timetable: Timetable?
    
    
    func create() -> Event {
        
        let event = TimetableService.shared.event()
        
        event.title = title
        event.body = body
            
        event.start = start
        event.end = end
        
        event.notes = notes
        
        TimetableService.shared.save()
        
        return event
    }
}

//MARK: EventAddView
struct EventAddView: View {
    
    var event = EventModel()
    
    var body: some View {
        NavigationView {
            EventAddViewContent(event: event)
                .navigationTitle("New Event")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading: Button(action: {
                    
                }, label: {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold))
                }), trailing: Button(action: {
                    
                }, label: {
                    Text("Add")
                        .font(.system(size: 16, weight: .semibold))
                }))
        }
    }
}

//MARK: EventAddViewContent
struct EventAddViewContent: View {
    
    @ObservedObject
    var event: EventModel
    
    @State
    private var showStartDatePicker = false
    
    @State
    private var showEndDatePicker = false
    
    var body: some View {
        
        List {
            
            Section {
                
                TextField("Title", text: $event.title)
                
                TextField("Description", text: $event.body)
            }
            
            Section {
                
                DetailCellDescriptor("Start date", image: "calendar", .systemBlue, value: textFor(event.start))
                    .onTapGesture {
                        withAnimation {
                            showStartDatePicker.toggle()
                            
                            if showEndDatePicker {
                                showEndDatePicker = false
                            }
                        }
                    }
                
                if showStartDatePicker {
                    DatePicker("", selection: $event.start)
                        .datePickerStyle(GraphicalDatePickerStyle())
                }
                
                DetailCellDescriptor("End date", image: "calendar", .systemOrange, value: textFor(event.end))
                    .onTapGesture {
                        withAnimation {
                            showEndDatePicker.toggle()
                            
                            if showStartDatePicker {
                                showStartDatePicker = false
                            }
                        }
                    }
                
                if showEndDatePicker {
                    DatePicker("", selection: $event.end)
                        .datePickerStyle(GraphicalDatePickerStyle())
                }
            }
            
        }.listStyle(InsetGroupedListStyle())
        
    }
    
    func textFor(_ date: Date) -> String {
        return date.stringify(dateStyle: .long, timeStyle: .short)
    }
    
    
}


struct EventAddView_Previews: PreviewProvider {
    static var previews: some View {
        EventAddView()
            .colorScheme(.dark)
    }
}
