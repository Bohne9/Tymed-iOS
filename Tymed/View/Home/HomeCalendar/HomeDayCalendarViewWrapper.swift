//
//  HomeDayCalendarViewWrapper.swift
//  Tymed
//
//  Created by Jonah Schueller on 18.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

class HomeDayCalendarViewWrapper: ViewWrapper<HomeDayCalendarViewStandalone> {
    
    var calendarEntry: CalendarDayEntry?
    
    var homeViewModel: HomeViewModel?
    
    override func createContent() -> UIHostingController<HomeDayCalendarViewStandalone>? {
        
        guard let calendarEntry = self.calendarEntry,
              let homeViewModel = self.homeViewModel else {
            return nil
        }
        
        return UIHostingController(rootView: HomeDayCalendarViewStandalone(event: calendarEntry, homeViewModel: homeViewModel))
    }
}

struct HomeDayCalendarViewStandalone: View {
    
    @ObservedObject
    var event: CalendarDayEntry
    
    @ObservedObject
    var homeViewModel: HomeViewModel
    
    @State
    private var firstAppear = true
    
    var body: some View {
        ScrollView {
            ScrollViewReader { value in
                HomeDayCalendarView(event: event).environmentObject(homeViewModel)
                    .onAppear {
                        if firstAppear {
                            firstAppear = false
                            
                            if Calendar.current.isDateInToday(event.date) {
                                let now = Time.now.hour

                                value.scrollTo(now)
                            } else if let start = event.firstEventBegin() {
                                let hour = Time(from: start).hour
                                value.scrollTo(hour)
                            }
                        }
                    }
            }
        }.padding(.horizontal, 5)
    }
    
}
