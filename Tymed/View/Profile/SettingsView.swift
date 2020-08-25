//
//  SettingsView.swift
//  Tymed
//
//  Created by Jonah Schueller on 25.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @State
    private var useICloud = false
    
    var body: some View {
        List {
            
            Section(header: Text("Notifications")) {
                HStack {
                    DetailCellDescriptor("Send lesson reminders", image: "paperplane.fill", .systemGreen)
                    Toggle("", isOn: $useICloud)
                        .labelsHidden()
                }
                
                Picker("Sound", selection: $useICloud) {
                    List {
                        Text("My sounds")
                    }
                }.font(.system(size: 16, weight: .semibold))
                
                HStack {
                    DetailCellDescriptor("Send task reminders", image: "list.dash", .systemOrange)
                    Toggle("", isOn: $useICloud)
                        .labelsHidden()
                }
                
                Picker("Sound", selection: $useICloud) {
                    List {
                        Text("My sounds")
                    }
                }.font(.system(size: 16, weight: .semibold))
                
                HStack {
                    DetailCellDescriptor("Other notifications", image: "circle.fill", .systemPurple)
                    Toggle("", isOn: $useICloud)
                        .labelsHidden()
                }
                
                Picker("Sound", selection: $useICloud) {
                    List {
                        Text("My sounds")
                    }
                }.font(.system(size: 16, weight: .semibold))
                
            }
            
            Section (header: Text("Storage")) {
                HStack {
                    DetailCellDescriptor("Use iCloud", image: "cloud.fill", .systemBlue)
                    Toggle("", isOn: $useICloud)
                        .labelsHidden()
                }
            }
            
            Section (header: Text("Danger zone")) {
                DetailCellDescriptor("Reset app", image: "trash.fill", .systemRed)
            }
            
        }.listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
