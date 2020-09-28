//
//  HomeDashOverview.swift
//  Tymed
//
//  Created by Jonah Schueller on 28.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

struct HomeDashOverviewView: View {
    
    @EnvironmentObject
    var homeViewModel: HomeViewModel
    
    
    var body: some View {
        HStack {
            
            GeometryReader { geometry in
                if let event = homeViewModel.nextCalendarEvent {
                    HomeDashOverviewEventView(event: event)
                        .frame(width: geometry.size.width / 2 - 40, height: 100)
                }
            }
        }
    }
}


struct HomeDashOverviewEventView: View {
    
    @ObservedObject
    var event: CalendarEvent
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            HStack {
               
                RoundedRectangle(cornerRadius: 2)
                    .foregroundColor(Color(.cyan))
                    .frame(width: 4, height: 12)
                
                Text(event.title)
                    .foregroundColor(Color(.white))
                    .lineLimit(2)
                    .font(.system(size: 14, weight: .semibold))
            }
            
            HStack {
                Text(dateString())
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white)
                    .padding(.leading, 15)
                
                Spacer()
                
                if let timetable = event.timetable {
                    TimetableBadgeView(timetable: timetable, size: .small)
                }
            }
        }
        .padding(10)
        .background(Color.appColorLight)
        .cornerRadius(8)
        .padding(4)
        
    }
    
    
    func dateString() -> String {
        
        let dateFormatter = RelativeDateTimeFormatter()
        
        dateFormatter.dateTimeStyle = .numeric
        dateFormatter.unitsStyle = .full
        dateFormatter.formattingContext = .beginningOfSentence
        
        if event.isNow() {
            return "Now"
        }
        
        guard let date = event.startDate else {
            return ""
        }
        
        return dateFormatter.localizedString(for: date, relativeTo: Date())
    }
}

struct HomeDashOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        HomeDashOverviewView()
    }
}
