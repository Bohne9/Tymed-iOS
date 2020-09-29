//
//  CalendarView.swift
//  Tymed
//
//  Created by Jonah Schueller on 28.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

struct CalendarView: View {
    
    @StateObject
    var calendarViewModel = CalendarViewModel()
    
    var body: some View {
        
        NavigationView {
            TabView(selection: $calendarViewModel.index) {
                ForEach(calendarViewModel.dayEntries.indices, id: \.self) { dayIndex in
                    HomeDayCalendarViewStandalone(event: calendarViewModel.dayEntries[dayIndex], homeViewModel: HomeViewModel())
                }
            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(placement: .principal) {
                    
                    HStack {

                        Image(systemName: "chevron.left")
                            .foregroundColor(.appColorLight)
                            .onTapGesture {
                                withAnimation {
                                    calendarViewModel.index -= 1
                                }
                            }
                        
//                        Text(calendarViewModel.titleForDay())
                        Text("\(calendarViewModel.index)")
                            .frame(width: 100)
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.appColorLight)
                            .onTapGesture {
                                withAnimation {
                                    calendarViewModel.index += 1
                                }
                            }
                    }.font(.system(size: 16, weight: .semibold))
                    
                }
                
            }.onChange(of: calendarViewModel.index) { index in
//                withAnimation {
                    if index == 0 {
                        calendarViewModel.fetchPrev()
                    }else if index == calendarViewModel.dayEntries.count - 1 {
                        calendarViewModel.fetchNext()
                    }
//                }
            }
        }
    }
}
