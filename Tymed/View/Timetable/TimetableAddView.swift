//
//  TimetableAddView.swift
//  Tymed
//
//  Created by Jonah Schueller on 29.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

struct TimetableAddView: View {
    
    @Environment(\.presentationMode)
    var presentationMode
    
    @State
    private var timetableName: String = ""
    
    @State
    private var isNewDefault = false
    
    var body: some View {
        NavigationView {
            List {
                
                Section(header: Text("Name")) {
                    TextField("Name", text: $timetableName)
                }
                
                Section {
                    HStack {
                        DetailCellDescriptor("Make default timetable", image: "circlebadge.fill", .systemGreen)
                        
                        Toggle("", isOn: $isNewDefault)
                            .labelsHidden()
                    }
                }
                
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Cancel")
            }), trailing: Button(action: {
                addTimetable()
            }, label: {
                Text("Add")
            }))
            .navigationTitle("Timetable")
        }
    }
    
    private func addTimetable() {
        let timetable = TimetableService.shared.timetable()
        
        timetable.name = timetableName
        
        
        if isNewDefault {
            TimetableService.shared.setDefaultTimetable(timetable)
        }else {
            timetable.isDefault = false
        }
        
        TimetableService.shared.save()
        
        presentationMode.wrappedValue.dismiss()
    }
    
}

struct TimetableAddView_Previews: PreviewProvider {
    static var previews: some View {
        TimetableAddView()
    }
}
