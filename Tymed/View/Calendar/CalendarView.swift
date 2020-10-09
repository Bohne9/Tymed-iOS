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
            CalendarDayView()
                .environmentObject(calendarViewModel)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    
                    ToolbarItem(placement: .principal) {
                        
                        HStack {

                            Image(systemName: "chevron.left")
                                .foregroundColor(.appColorLight)
                                .font(.system(size: 18, weight: .semibold))
                                .onTapGesture {
                                    withAnimation {
                                        calendarViewModel.prevDay()
                                    }
                                }
                            
                            Text(calendarViewModel.titleForDay())
                                .frame(minWidth: 120)
                                .font(.system(size: 16, weight: .semibold))
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.appColorLight)
                                .font(.system(size: 18, weight: .semibold))
                                .onTapGesture {
                                    withAnimation {
                                        calendarViewModel.nextDay()
                                    }
                                }
                        }
                        
                    }
                    
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            calendarViewModel.currentDay()
                        } label: {
                            Image(systemName: "calendar.circle.fill")
                        }

                    }
                    
            }
        }
    }
}
