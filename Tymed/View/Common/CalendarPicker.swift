//
//  CalendarPicker.swift
//  Tymed
//
//  Created by Jonah Schueller on 06.10.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI
import EventKit

struct CalendarPicker: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding
    var calendar: EKCalendar?
    
    var calendars: [EKCalendar] = EventService.shared.editableCalendars()
    
    var body: some View {
        List {
            ForEach(calendars, id: \.self) { calendar in
                HStack {
                    Text(calendar.title)
                        
                    Spacer()
                    
                    if self.calendar?.calendarIdentifier == calendar.calendarIdentifier {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color(.systemBlue))
                    }
                }.contentShape(Rectangle())
                .onTapGesture {
                    self.calendar = calendar
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }.listStyle(InsetGroupedListStyle())
        .navigationTitle("Calendar")
    }
}
