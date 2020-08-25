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
                }.font(.system(size: 14, weight: .semibold))
                
                HStack {
                    DetailCellDescriptor("Send task reminders", image: "list.dash", .systemOrange)
                    Toggle("", isOn: $useICloud)
                        .labelsHidden()
                }
                
                Picker("Sound", selection: $useICloud) {
                    List {
                        Text("My sounds")
                    }
                }.font(.system(size: 14, weight: .semibold))
                
                HStack {
                    DetailCellDescriptor("Other notifications", image: "app.badge", .systemPurple)
                    Toggle("", isOn: $useICloud)
                        .labelsHidden()
                }
                
                Picker("Sound", selection: $useICloud) {
                    List {
                        Text("My sounds")
                    }
                }.font(.system(size: 14, weight: .semibold))
                
            }
            
            Section (header: Text("Default values")) {
                
                NavigationLink (destination: Text("Default notification offset")) {
                    DetailCellDescriptor("Default notification offset", image: "bell.badge.fill", .systemGreen, value: "15 minutes")
                }
                
                NavigationLink (destination: Text("Auto archive tasks after")) {
                    DetailCellDescriptor("Auto archive tasks after", image: "tray.full.fill", .systemOrange, value: "1 hour")
                }
                
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
