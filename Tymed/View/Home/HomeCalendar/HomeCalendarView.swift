//
//  HomeCalendarView.swift
//  Tymed
//
//  Created by Jonah Schueller on 05.10.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI
import EventKit

struct HomeCalendarView: View {
    
    @EnvironmentObject
    var homeViewModel: HomeViewModel
    
    var body: some View {
        List {
            ForEach(homeViewModel.calendars, id: \.self) { calendar in
                HomeCalendarCellView(calendar: calendar)
            }
        }.listStyle(InsetGroupedListStyle())
    }
}

struct HomeCalendarCellView: View {
    
    var calendar: EKCalendar
    
    @State
    var showCalendarDetail = false
    
    var body: some View {
        HStack {
            
            Image(systemName: calendar.isImmutable ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(calendar.cgColor))
            
            Text(calendar.title)
                .font(.system(size: 15, weight: .semibold))
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(.secondaryLabel))
        }.padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            showCalendarDetail.toggle()
        }.sheet(isPresented: $showCalendarDetail) {
            Text("Calendar detail")
        }
    }
    
}

struct HomeCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        HomeCalendarView()
    }
}
