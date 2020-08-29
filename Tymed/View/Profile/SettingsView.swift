//
//  SettingsView.swift
//  Tymed
//
//  Created by Jonah Schueller on 25.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

//MARK: SettingsView
struct SettingsView: View {
    
    @State
    private var useICloud = false
    
    @State
    private var notificationOffset: NotificationOffset? = SettingsService.shared.notificationOffset
    
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
                
                HStack {
                    NavigationLink (destination: NotificationOffsetView(notificationOffset: $notificationOffset)) {
                        DetailCellDescriptor("Default notification offset",
                                             image: "bell.badge.fill",
                                             .systemGreen,
                                             value: defaultNotificationOffset())
                    }
                }
                
                NavigationLink (destination: Text("Auto archive tasks after")) {
                    DetailCellDescriptor("Auto archive tasks after",
                                         image: "tray.full.fill",
                                         .systemOrange,
                                         value: autoArchiveTasks())
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
                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 11)
                            .stroke(Color(.systemRed), lineWidth: 4)
                    )
            }.listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            
        }.listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Settings")
        .onChange(of: notificationOffset) { (value) in
            SettingsService.shared.notificationOffset = notificationOffset
        }
        .onAppear {
            
        }
    }
    
    private func defaultNotificationOffset() -> String {
        guard let value = notificationOffset else {
            return "-"
        }
        return value.title
    }
    
    private func autoArchiveTasks() -> String {
        guard let value = SettingsService.shared.taskAutoArchivingDelay else {
            return "-"
        }
        return value.title
    }
}



struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
