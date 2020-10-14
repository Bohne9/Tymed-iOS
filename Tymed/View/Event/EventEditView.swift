//
//  EventEditView.swift
//  Tymed
//
//  Created by Jonah Schueller on 15.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI
import EventKit

struct EventEditView: View {
    
    @ObservedObject
    var event: EventViewModel
    
    @State
    var showDiscardWarning = false
    
    @Environment(\.presentationMode)
    var presentationMode
    
    var body: some View {
        NavigationView {
            EventEditViewContent(event: event) {
                presentationMode.wrappedValue.dismiss()
            }
                .navigationTitle("Event")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading: Button(action: {
                    cancel()
                }, label: {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold))
                }), trailing: Button(action: {
                    event.save()
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Done")
                        .font(.system(size: 16, weight: .semibold))
                }).disabled(!event.hasChanges || event.title.isEmpty))
        }.actionSheet(isPresented: $showDiscardWarning, content: {
            ActionSheet(title: Text("Do you want to discard your changes?"), message: nil, buttons: [
                .destructive(Text("Discard changes"), action: {
                    event.rollback()
                    presentationMode.wrappedValue.dismiss()
                }),
                .cancel()
            ])
        })
    }
    
    func cancel() {
        if event.hasChanges {
            showDiscardWarning.toggle()
        }else {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

//MARK: EventEditViewContent
struct EventEditViewContent: View {
    
    @ObservedObject
    var event: EventViewModel
    
    @Environment(\.presentationMode)
    var presentationMode
    
    @State
    private var showStartDatePicker = false
    
    @State
    private var showEndDatePicker = false
    
    @State
    private var showNotificationDatePicker = false

    //MARK: Delete state
    @State var showDeleteAction = false
    @State var showSpanPicker = false
    @State var deleteSpan = EKSpan.thisEvent
    
    @State
    private var duration: TimeInterval = 3600
    
    var dismiss: () -> Void
    
    var body: some View {
        List {
            
            Section {
                TextField("Title", text: $event.title)
                
                Text(event.event.location ?? "Location")
            }
            
            Section {
                
                HStack {
                    DetailCellDescriptor("All day", image: "clock.arrow.circlepath", .systemBlue)
                    Toggle("", isOn: $event.isAllDay)
                }
                
                if event.isAllDay {
                    
                    DetailCellDescriptor("Day", image: "calendar", .systemBlue, value: textFor(event.startDate))
                        .onTapGesture {
                            withAnimation {
                                showStartDatePicker.toggle()
                                
                                if showEndDatePicker {
                                    showEndDatePicker = false
                                }
                            }
                        }
                    
                    if showStartDatePicker {
                        DatePicker("", selection: $event.startDate, displayedComponents: [.date])
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .onChange(of: event.startDate) { (date) in
                                event.endDate = event.startDate
                            }
                    }
                    
                } else {
                    DetailCellDescriptor("Start date", image: "calendar", .systemBlue, value: textFor(event.startDate))
                        .onTapGesture {
                            withAnimation {
                                showStartDatePicker.toggle()
                                
                                if showEndDatePicker {
                                    showEndDatePicker = false
                                }
                            }
                        }
                    
                    if showStartDatePicker {
                        DatePicker("", selection: $event.startDate)
                            .datePickerStyle(GraphicalDatePickerStyle())
                    }
                    
                    DetailCellDescriptor("End date", image: "calendar", .systemBlue, value: textFor(event.endDate))
                        .animation(.default)
                        .onTapGesture {
                            withAnimation {
                                showEndDatePicker.toggle()
                                
                                if showStartDatePicker {
                                    showStartDatePicker = false
                                }
                            }
                        }
                    
                    if showEndDatePicker {
                        DatePicker("", selection: $event.endDate, in: (event.startDate + 60)...)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .animation(.default)
                    }
                }
                
                
                HStack {
                    DetailCellDescriptor("Repeats", image: "arrow.clockwise", .systemBlue, value: "")

                    Picker(selection: $event.recurrenceRules, label: Text("")) {
                        let rules: [[EKRecurrenceRule]] = [
                            [EKRecurrenceRule.init(recurrenceWith: .daily, interval: 1, end: .none)],
                            [EKRecurrenceRule.init(recurrenceWith: .weekly, interval: 1, end: .none)],
                            [EKRecurrenceRule.init(recurrenceWith: .monthly, interval: 1, end: .none)],
                            [EKRecurrenceRule.init(recurrenceWith: .yearly, interval: 1, end: .none)],
                        ]
                        ForEach(rules, id: \.self) { rules in
                            
                            Text("\(rules.first!.description)")
                            
                        }
                    }
                }
            }
            
            //MARK: Calendar
            
            Section {
                HStack {
                    
                    NavigationLink(destination: CalendarPicker(calendar: $event.calendar)) {
                        DetailCellDescriptor("Calendar", image: "tray.full.fill", UIColor(cgColor: event.calendar.cgColor), value: timetableTitle())
                        Spacer()
                    }
                    
                }
            }
            
            if !event.isNew {
                //MARK: Delete
                Section {
                    DetailCellDescriptor("Delete", image: "trash.fill", .systemRed)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if event.event.hasRecurrenceRules {
                                showSpanPicker.toggle()
                            }else {
                                showDeleteAction.toggle()
                            }
                        }.actionSheet(isPresented: $showDeleteAction) {
                            ActionSheet(
                                title: Text("Are you sure you want to delete the event."),
                                buttons: [
                                    .destructive(Text("Delete"), action: {
                                        deleteEvent()
                                    }),
                                    .cancel()
                                ])
                        }
                }
            }
            
        }.listStyle(InsetGroupedListStyle())
        .onChange(of: event.endDate) { value in
            if let start = event.startDate,
               let end = event.endDate {
                duration = end.timeIntervalSince(start)
            }
        }.onChange(of: event.startDate) { value in
            guard let start = event.startDate else {
                return
            }
            event.endDate = start + duration
        }.onAppear {
            if let start = event.startDate,
               let end = event.endDate {
                duration = end.timeIntervalSince(start)
            }
        }.actionSheet(isPresented: $showSpanPicker) {
            ActionSheet(
                title: Text("Are you sure you want to delete the event. This is a repeating event."),
                buttons: [
                    .destructive(Text("Delete only this event"), action: {
                        deleteSpan = .thisEvent
                        deleteEvent()
                    }),
                    .destructive(Text("Delete all future events"), action: {
                        deleteSpan = .futureEvents
                        deleteEvent()
                    }),
                    .cancel()
                ])
        }
    }

    func textFor(_ date: Date?) -> String {
        return date?.stringify(dateStyle: .medium, timeStyle: .short)  ?? ""
    }

    //MARK: timetableTitle
    private func timetableTitle() -> String? {
        return event.calendar.title
    }
    
//    private func textForNotification() -> String? {
//        return event.notificationDate?.stringify(dateStyle: .medium, timeStyle: .short)
//    }
    
    //MARK: deleteEvent
    private func deleteEvent() {
        
        showSpanPicker = false
        showDeleteAction = false
        
        EventService.shared.deleteEvent(event.event, deleteSpan)
        
        dismiss()
        
    }
}
