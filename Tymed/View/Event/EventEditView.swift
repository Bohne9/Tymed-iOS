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
    
    @State
    private var duration: TimeInterval = 3600
    
    var dismiss: () -> Void
    
    var body: some View {
        List {
            
            Section(header: Text("Title"))  {
                TextField("Title", text: $event.title)
                    .font(.system(size: 16, weight: .medium))
//                VStack(alignment: .leading, spacing: 0) {
//                    Text("Title")
//                        .font(.system(size: 14, weight: .regular))
//                        .foregroundColor(Color(.secondaryLabel))
//                }.padding(.bottom, 2)
            }
            
            Section(header: Text("Date & Time")) {
                HStack {
                    Text("Starts")
                        .font(.system(size: 16, weight: .medium))
                    Spacer()
                    
                    Text(textFor(event.startDate))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(.systemBlue))
                }.contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        if showEndDatePicker {
                            showEndDatePicker = false
                        }
                        showStartDatePicker.toggle()
                    }
                }
                
                if showStartDatePicker {
                    DatePicker("", selection: $event.startDate)
                        .datePickerStyle(GraphicalDatePickerStyle())
                }
                
                HStack {
                    Text("Ends")
                        .font(.system(size: 16, weight: .medium))
                    Spacer()
                    
                    Text(textFor(event.endDate))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(.systemBlue))
                }.contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        if showStartDatePicker {
                            showStartDatePicker = false
                        }
                        showEndDatePicker.toggle()
                    }
                }
                
                if showEndDatePicker {
                    DatePicker("", selection: $event.endDate, in: (event.startDate + 60)...)
                        .datePickerStyle(GraphicalDatePickerStyle())
                }
                
//                HStack {
//                    DetailCellDescriptor("Notification", image: "app.badge", .systemGreen, value: textForNotification())
//                    Toggle("", isOn: Binding(isNotNil: $event.notificationDate, defaultValue: Date()))
//                }.animation(.default)
//                .onTapGesture {
//                    withAnimation {
//                        showNotificationDatePicker.toggle()
//                    }
//                }
    
//                if event.notificationDate != nil && showNotificationDatePicker {
//                    DatePicker("", selection: Binding($event.notificationDate)!, in: Date()...)
//                        .datePickerStyle(GraphicalDatePickerStyle())
//                        .animation(.easeIn)
//                }
                
                HStack {
                    Text("All day")
                        .font(.system(size: 16, weight: .medium))
                    Spacer()
                    
                    Toggle("", isOn: $event.isAllDay)
                        .foregroundColor(Color(.systemBlue))
                }
            }
            
            //MARK: Calendar
            
            Section {
                HStack {
                    
                    NavigationLink(destination: CalendarPicker(calendar: $event.calendar)) {
                        DetailCellDescriptor("Calendar", image: "tray.full.fill", .systemRed, value: timetableTitle())
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
                            showDeleteAction.toggle()
                        }.actionSheet(isPresented: $showDeleteAction) {
                            ActionSheet(
                                title: Text(""),
                                message: nil,
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
        showDeleteAction = false
        dismiss()
        
    }
}
