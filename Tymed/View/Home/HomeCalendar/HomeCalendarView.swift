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
         
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                HomeCalendarHeaderView()
                
                VStack {
                    ForEach(homeViewModel.calendars, id: \.self) { calendar in
                        VStack {
                            HomeCalendarCellView(calendar: calendar)
                            if calendar != homeViewModel.calendars.last {
                                Divider()
                            }
                        }
                    }
                }.padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }.padding()
        }
    }
}

struct HomeCalendarCellView: View {
    
    var calendar: EKCalendar
    
    @State
    var showCalendarDetail = false
    
    var body: some View {
        HStack {
            
            Image(systemName: !calendar.isImmutable ? "checkmark.circle" : "circle")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(!calendar.isImmutable ? .systemBlue : .secondaryLabel))
            
            Text(calendar.title)
                .font(.system(size: 15, weight: .semibold))
            
            Spacer()
            
            Circle()
                .foregroundColor(Color(calendar.cgColor))
                .frame(width: 8, height: 8)
            
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
