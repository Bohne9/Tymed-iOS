//
//  EventEditView.swift
//  Tymed
//
//  Created by Jonah Schueller on 15.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

class EventEditViewWrapper: ViewWrapper<EventEditView> {
    
    var event: Event?
    
    override func createContent() -> UIHostingController<EventEditView>? {
        guard let event = event else {
            return nil
        }
        
        return UIHostingController(rootView: EventEditView(
                                    event: event,
                                    dismiss: {
                                        self.homeDelegate?.reload()
                                        self.dismiss(animated: true, completion: nil)
                                    }))
    }
    
}

struct EventEditView: View {
    
    @ObservedObject
    var event: Event
    
    var dismiss: () -> Void
    
    var body: some View {
        NavigationView {
            EventEditViewContent(event: event)
                .navigationTitle("Event")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading: Button(action: {
                    TimetableService.shared.reset()
                    dismiss()
                }, label: {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold))
                }), trailing: Button(action: {
                    NotificationService.current.scheduleEventNotification(for: event)
                    TimetableService.shared.save()
                    dismiss()
                }, label: {
                    Text("Done")
                        .font(.system(size: 16, weight: .semibold))
                }))
        }
    }
}

struct EventEditViewContent: View {
    
    @ObservedObject
    var event: Event
    
    @State
    private var showStartDatePicker = false
    
    @State
    private var showEndDatePicker = false
    
    @State
    private var showNotificationDatePicker = false

    
    var body: some View {
        List {
            
            Section {
                
                TextField("Title", text: $event.title)
                
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
                    DatePicker("", selection: Binding($event.end, Date()))
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .animation(.default)
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
            
    }

    func textFor(_ date: Date?) -> String {
        return date?.stringify(dateStyle: .long, timeStyle: .short)  ?? ""
    }

    //MARK: timetableTitle
    private func timetableTitle() -> String? {
        return event.timetable?.name
    }
    
    private func textForNotification() -> String? {
        return event.notificationDate?.stringify(dateStyle: .medium, timeStyle: .short)
    }
}
