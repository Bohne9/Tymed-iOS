//
//  EventEditView.swift
//  Tymed
//
//  Created by Jonah Schueller on 15.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI
import EventKit
import MapKit

private let rules: [[EKRecurrenceRule]?] = [
    [EKRecurrenceRule.init(recurrenceWith: .daily, interval: 1, end: .none)],
    [EKRecurrenceRule.init(recurrenceWith: .weekly, interval: 1, end: .none)],
    [EKRecurrenceRule.init(recurrenceWith: .monthly, interval: 1, end: .none)],
    [EKRecurrenceRule.init(recurrenceWith: .yearly, interval: 1, end: .none)],
]

struct EventEditView: View {
    
    @ObservedObject
    var event: EventViewModel
    
    @State
    var showDiscardWarning = false
    
    @Environment(\.presentationMode)
    var presentationMode
    
    @State
    private var showNoteKeyboardDismiss = false
    
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
                
            }
            
            if event.event.structuredLocation != nil {
                EventLocationView(event: event)
            }
            
            Section {
                
                HStack {
                    DetailCellDescriptor("All day", image: "24.circle", .systemBlue)
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
                
                NavigationLink(destination: RecurrenceRulePicker(recurenceRule: $event.recurrenceRules)) {
                    DetailCellDescriptor("Repeats", image: "arrow.clockwise", .systemBlue, value: textFor(rule: event.recurrenceRules?.first))
                }
                
            }
            
            //MARK: Calendar
            
            Section {
                HStack {
                    
                    NavigationLink(destination: CalendarPicker(calendar: $event.calendar)) {
                        DetailCellDescriptor("Calendar", image: "tray.full.fill", UIColor(cgColor: event.calendar.cgColor), value: timetableTitle())
                    }
                    
                }
            }
            
            Section(header: HStack {
                Text("Notes")
                Spacer()
                if showNotificationDatePicker {
                    #if canImport(UIKit) // Just to make sure UIKit is available
                    Button("Done") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        showNotificationDatePicker = false
                    }.foregroundColor(Color(.systemBlue))
                    .font(.system(size: 12, weight: .semibold))
                    #endif
                }
            }) {
                ScrollViewReader { scrollView in
                    TextEditor(text: Binding($event.notes, ""))
                        .id("notes-text-editor")
                        .onTapGesture {
                            showNotificationDatePicker = true
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                                scrollView.scrollTo("notes-text-editor", anchor: .bottom)
//                            }
                        }.frame(minHeight: 100)
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
        if !event.isAllDay {
            return date?.stringify(dateStyle: .medium, timeStyle: .short)  ?? ""
        }else {
            return date?.stringify(with: .medium)  ?? ""
        }
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
    
    private func textFor(rule: EKRecurrenceRule?) -> String {
        guard let rule = rule else { return "None" }
        
        switch rule.frequency {
        case .daily:
            return "Daily"
        case .monthly:
            return "Monthly"
        case .weekly:
            return "Weekly"
        case .yearly:
            return "Yearly"
        @unknown default:
            return "-"
        }
    }
}

//MARK: RecurrenceRulePicker
struct RecurrenceRulePicker: View {
    
    @Binding
    var recurenceRule: [EKRecurrenceRule]?
    
    @Environment(\.presentationMode)
    var presentationMode
    
    @State
    private var frequency: EKRecurrenceFrequency = .daily
    
    @State
    private var interval: Int = 1
    
    @State
    private var endDate: Date? = nil
    
    var body: some View {
        
        List {
            
            // No recurrence rule
            Section {
                HStack {
                    Text(textFor(rule: nil))
                    Spacer()
                    if recurenceRule == nil {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color(.systemBlue))
                    }
                }.contentShape(Rectangle())
                .onTapGesture {
                    recurenceRule = nil
                    presentationMode.wrappedValue.dismiss()
                }
            }
            
            Section {
                ForEach(rules, id: \.self) { rules in
                    HStack {
                        Text(textFor(rule: rules?.first))
                        Spacer()
                        if recurenceRule == rules {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color(.systemBlue))
                        }
                    }.contentShape(Rectangle())
                    .onTapGesture {
                        recurenceRule = rules
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            
            Section {
                HStack {
                    Text("Custom")
                    Spacer()
                    if isCustomRule() {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color(.systemBlue))
                    }
                }.contentShape(Rectangle())
                .onTapGesture {
                    recurenceRule = [EKRecurrenceRule(recurrenceWith: frequency, interval: interval, end: nil)]
                }
            }
            
            if isCustomRule() {
                
                // Frequency
                HStack {
                    Picker(selection: $interval, label: Text("-")) {
                        ForEach(1..<30) { value in
                            Text("\(value)")
                        }
                        
                    }.pickerStyle(WheelPickerStyle())
                    
                    Picker(selection: $frequency, label: Text("-")) {
                        ForEach([EKRecurrenceFrequency.daily, EKRecurrenceFrequency.weekly, EKRecurrenceFrequency.monthly, EKRecurrenceFrequency.yearly], id: \.self) { value in
                            Text("\(textFor(frequency: value))")
                        }
                    }.pickerStyle(WheelPickerStyle())
                }
                
            }
            
        }.font(.system(size: 15, weight: .semibold))
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Repeats")
        
    }
    
    private func isCustomRule() -> Bool {
        return recurenceRule != nil && !rules.reduce(false) { (res, rule) in
            return recurenceRule == rule ? true : res
        }
    }
    
    private func textFor(rule: EKRecurrenceRule?) -> String {
        guard let rule = rule else { return "None" }
        
        return textFor(frequency: rule.frequency)
    }
    
    private func textFor(frequency: EKRecurrenceFrequency) -> String {
        switch frequency {
        case .daily:
            return "Daily"
        case .monthly:
            return "Monthly"
        case .weekly:
            return "Weekly"
        case .yearly:
            return "Yearly"
        default:
            return "-"
        }
    }
}


struct EventLocationView: View {
    
    struct EventLocation: Identifiable {
        var id: Int = 0
        var coordinate: CLLocationCoordinate2D
    }
    
    @ObservedObject
    var event: EventViewModel
    
    @State
    var region: MKCoordinateRegion?
    
    var pins: [EventLocation] = []
    
    init(event: EventViewModel) {
        self.event = event
        if let location = event.event.structuredLocation {
            region = MKCoordinateRegion(center:
                                            location.geoLocation!.coordinate,
                                           span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            pins = [EventLocation(coordinate: location.geoLocation!.coordinate)]
        }
    }
    
    var body: some View {
        
        if event.event.structuredLocation != nil {
            Map(
                coordinateRegion: Binding($region, MKCoordinateRegion(center:
                                                                        event.event.structuredLocation!.geoLocation!.coordinate,
                                                                       span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))),
                annotationItems: pins) { pin in
                MapPin(coordinate: pin.coordinate)
            }.frame(height: 150)
            .cornerRadius(10)
            .listRowInsets(EdgeInsets())
        }else {
            Text("Choose location")
        }
    }
    
}
