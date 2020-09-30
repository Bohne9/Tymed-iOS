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
    
    @State
    private var showEventAdd = false
    
    var body: some View {
        HStack(alignment: .top) {
            HomeDashOverviewTaskView()
            
            if let event = homeViewModel.nextCalendarEvent {
                
                Spacer(minLength: 15)
                
                VStack(alignment: .leading) {
                    Text("Up Next".uppercased())
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(.label))
                    
                    HomeDashOverviewEventView(event: event)
                }
            }else {
                VStack(alignment: .leading) {
                    
                    HStack {
                       
                        Label("Add event", systemImage: "plus")
                            .foregroundColor(Color(.white))
                            .lineLimit(2)
                            .font(.system(size: 14, weight: .semibold))
                        
                        Spacer()
                    }
                }
                .padding(10)
                .background(Color.appColorLight)
                .cornerRadius(8)
                .onTapGesture {
                    showEventAdd.toggle()
                }.sheet(isPresented: $showEventAdd) {
                    EventAddView()
                }
            }
        }.padding(.horizontal)
    }
}

struct HomeDashOverviewTaskView: View {
    
    var body: some View {
        
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text("7")
                    .font(.system(size: 35, weight: .bold))
                Text("Events today")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(.secondaryLabel))
                
            }
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text("51")
                    .font(.system(size: 35, weight: .bold))
                Text("Events this week")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(.secondaryLabel))
                
            }
        }
        
    }
    
}

struct HomeDashOverviewEventView: View {
    
    @EnvironmentObject
    var homeViewModel: HomeViewModel
    
    @ObservedObject
    var event: CalendarEvent
    
    @State
    private var showEventDetail = false
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            HStack {
               
                RoundedRectangle(cornerRadius: 2)
                    .foregroundColor(Color(UIColor.cyan.withAlphaComponent(0.5)))
                    .frame(width: 4, height: 12)
                
                Text(event.title)
                    .foregroundColor(Color(.white))
                    .lineLimit(2)
                    .font(.system(size: 14, weight: .semibold))
            }
            
            HStack {
                Text(dateString())
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.white)
                    .padding(.leading, 15)
                
                Spacer()
                
                if let timetable = event.timetable {
                    TimetableBadgeView(timetable: timetable, size: .small, color: .appColorLight)
                }
            }
        }
        .padding(10)
        .background(Color.appColor)
        .cornerRadius(8)
        .onTapGesture {
            showEventDetail.toggle()
        }.sheet(isPresented: $showEventDetail) {
            if let event = event.asEvent {
                EventEditView(event: event, presentationDelegate: homeViewModel)
            }else if let lesson = event.asLesson {
                
            }
        }
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
