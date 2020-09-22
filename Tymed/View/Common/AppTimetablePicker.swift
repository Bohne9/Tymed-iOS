//
//  AppTimetablePicker.swift
//  Tymed
//
//  Created by Jonah Schueller on 05.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

//MARK: AppTimetablePicker
struct AppTimetablePicker: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding
    var timetable: Timetable?
    
    var body: some View {
        List {
            ForEach(timetables(), id: \.self) { timetable in
                HStack {
                    Text(timetable?.name ?? "")
                        
                    Spacer()
                    
                    if timetable == TimetableService.shared.defaultTimetable() {
                        Text("Default")
                            .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                            .background(Color(.tertiarySystemGroupedBackground))
                            .font(.system(size: 13, weight: .semibold))
                            .cornerRadius(10)
                    }
                    
                    if self.timetable == timetable {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color(.systemBlue))
                    }
                }.contentShape(Rectangle())
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()
                    self.timetable = timetable
                    
                }
            }
        }.listStyle(InsetGroupedListStyle())
        .navigationTitle("Calendar")
    }
    
    private func timetables() -> [Timetable?] {
        return TimetableService.shared.fetchTimetables() ?? []
    }
}
