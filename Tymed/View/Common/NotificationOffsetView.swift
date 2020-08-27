//
//  NotificationOffsetView.swift
//  Tymed
//
//  Created by Jonah Schueller on 07.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

//MARK: NotificationOffsetView
struct NotificationOffsetView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding
    var notificationOffset: NotificationOffset
    
    var body: some View {
        List(NotificationOffset.allCases, id: \.value) { offset in
            
            HStack {
                Text(offset.title)
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                
                if offset == notificationOffset {
                    Image(systemName: "checkmark").foregroundColor(Color(.systemBlue))
                }
            }
            .contentShape(Rectangle())
            .frame(height: 45)
            .onTapGesture {
                notificationOffset = offset
                presentationMode.wrappedValue.dismiss()
            }
            
        }.listStyle(InsetGroupedListStyle())
        .navigationTitle("")
    }
}
