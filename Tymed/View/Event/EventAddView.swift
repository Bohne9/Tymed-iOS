//
//  EventAddView.swift
//  Tymed
//
//  Created by Jonah Schueller on 09.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

//MARK: EventAddView
struct EventAddView: View {
    
    @ObservedObject
    var event: Event = {
        let event = TimetableService.shared.event()
        
        event.start = Date()
        event.end = Date() + 3600
        
        event.timetable = TimetableService.shared.defaultTimetable()
        
        return event
    }()
    
    @Environment(\.presentationMode)
    var presentaionMode
    
    var body: some View {
        NavigationView {
            EventAddViewContent(event: event)
                .navigationTitle("New Event")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading: Button(action: {
                    TimetableService.shared.rollback()
                    
                    presentaionMode.wrappedValue.dismiss()
                }, label: {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold))
                }), trailing: Button(action: {
                    addEvent()
                }, label: {
                    Text("Add")
                        .font(.system(size: 16, weight: .semibold))
                }).disabled(!event.isValid))
        }
    }
    
    func addEvent() {
        
        NotificationService.current.scheduleEventNotification(for: event)
        
        TimetableService.shared.save()
        
        presentaionMode.wrappedValue.dismiss()
        
    }
}

//MARK: EventAddViewContent
struct EventAddViewContent: View {
    
    @ObservedObject
    var event: Event
    
    @State
    private var showStartDatePicker = false
    
    @State
    private var showEndDatePicker = false
    
    @State
    private var showNotificationDatePicker = false
    
    @State
    private var duration: TimeInterval = 3600
    
    var body: some View {
        
        List {
            
            Section {
                
                TextField("Title", text: $event.title)
                    .font(.system(size: 16, weight: .semibold))
                
                TextField("Description", text: Binding($event.body, replacingNilWith: ""))
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
                    DatePicker("", selection: Binding($event.start, Date()))
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
                
                if showEndDatePicker, let start = event.start {
                    DatePicker("", selection: Binding($event.end, Date()), in: start...)
                        .datePickerStyle(GraphicalDatePickerStyle())
                }
                
                
                HStack {
                    DetailCellDescriptor("Notification", image: "app.badge", .systemGreen, value: textForNotification())
                    Toggle("", isOn: Binding(isNotNil: $event.notificationDate, defaultValue: Date()))
                }.animation(.default)
                .onTapGesture {
                    withAnimation {
                        showNotificationDatePicker.toggle()
                    }
                }
    
                if event.notificationDate != nil && showNotificationDatePicker {
                    DatePicker("", selection: Binding($event.notificationDate)!, in: Date()...)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .animation(.easeIn)
                }
            }
            
            //MARK: Timetable
            
            Section {
                HStack {
                    
                    NavigationLink(destination: AppTimetablePicker(timetable: $event.timetable)) {
                        DetailCellDescriptor("Timetable", image: "tray.full.fill", .systemRed, value: timetableTitle())
                        Spacer()
                        if event.timetable == TimetableService.shared.defaultTimetable() {
                            Text("Default")
                                .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                                .background(Color(.tertiarySystemGroupedBackground))
                                .font(.system(size: 13, weight: .semibold))
                                .cornerRadius(10)
                        }
                    }
                    
                }
            }
            
        }.listStyle(InsetGroupedListStyle())
        .onChange(of: event.end) { value in
            if let start = event.start,
               let end = event.end {
                duration = end.timeIntervalSince(start)
            }
        }.onChange(of: event.start) { value in
            guard let start = event.start else {
                return
            }
            event.end = start + duration
        }
        
    }
    
    func textFor(_ date: Date?) -> String {
        return date?.stringify(dateStyle: .medium, timeStyle: .short) ?? ""
    }
    
    //MARK: timetableTitle
    private func timetableTitle() -> String? {
        return event.timetable?.name
    }
    
    private func textForNotification() -> String? {
        return event.notificationDate?.stringify(dateStyle: .medium, timeStyle: .short)
    }
}


struct EventAddView_Previews: PreviewProvider {
    static var previews: some View {
        EventAddView()
            .colorScheme(.dark)
    }
}
