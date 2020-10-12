//
//  HomeDashOverview.swift
//  Tymed
//
//  Created by Jonah Schueller on 28.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI
import EventKit

//MARK: HomeDashOverviewView
struct HomeDashOverviewView: View {
    
    @EnvironmentObject
    var homeViewModel: HomeViewModel
    
    @State
    private var showEventAdd = false
    
    var body: some View {
        HStack(alignment: .top) {
            HomeDashOverviewTaskView()
            
            if let event = homeViewModel.nextEvents?.first {
                
                Spacer(minLength: 15)
                
                VStack(alignment: .leading) {
                    Text("Up Next".uppercased())
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(.label))
                    
                    HomeDashOverviewEventView(event: EventViewModel(event))
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
                .background(Color.appColor)
                .cornerRadius(8)
                .onTapGesture {
                    showEventAdd.toggle()
                }.sheet(isPresented: $showEventAdd) {
                    EventAddView()
                }
            }
        }
    }
}

//MARK: HomeDashOverviewTaskView
struct HomeDashOverviewTaskView: View {
    
    @EnvironmentObject
    var homeViewModel: HomeViewModel
    
    var body: some View {
        
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text("\(homeViewModel.eventCountToday)")
                    .font(.system(size: 35, weight: .bold))
                Text("\(event(count: homeViewModel.eventCountToday)) today")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(.secondaryLabel))
                
            }
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text("\(homeViewModel.eventCountWeek)")
                    .font(.system(size: 35, weight: .bold))
                Text("\(event(count: homeViewModel.eventCountWeek)) this week")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(.secondaryLabel))
                
            }
        }.lineLimit(2)
        
    }
    
    private func event(count: Int) -> String {
        return count == 1 ? "Event" : "Events"
    }
}

//MARK: HomeDashOverviewEventView
struct HomeDashOverviewEventView: View {
    
    @EnvironmentObject
    var homeViewModel: HomeViewModel
    
    @ObservedObject
    var event: EventViewModel
    
    @State
    private var showEventDetail = false
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            HStack {
               
                RoundedRectangle(cornerRadius: 2)
                    .foregroundColor(Color(UIColor(cgColor: event.calendar.cgColor)))
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
                
//                if let timetable = event.timetable {
//                    TimetableBadgeView(timetable: timetable, size: .small, color: .appColorLight)
//                }
            }
        }
        .padding(10)
        .background(Color.appColor)
        .cornerRadius(8)
        .onTapGesture {
            showEventDetail.toggle()
        }.sheet(isPresented: $showEventDetail, onDismiss: {
            homeViewModel.reload()
        }, content: {
            EventEditView(event: event)
        })
    }
    
    
    func dateString() -> String {
        
        let dateFormatter = RelativeDateTimeFormatter()
        
        dateFormatter.dateTimeStyle = .numeric
        dateFormatter.unitsStyle = .full
        dateFormatter.formattingContext = .beginningOfSentence
        
        if event.startDate <= Date() && Date() <= event.endDate {
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
