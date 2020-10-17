//
//  HomeDayCalendarView.swift
//  Tymed
//
//  Created by Jonah Schueller on 18.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI
import EventKit

fileprivate var heightForHour: CGFloat = 60

//MARK: HomeDayCalendarView
struct HomeDayCalendarView: View {
    
    @ObservedObject
    var event: CalendarDayEntry
    
    @EnvironmentObject
    var homeViewModel: HomeViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            
            HomeDashCalendarGrid(date: event.date, startHour: 0, endHour: 24)
                .environmentObject(TimetableService.shared)
                .frame(height: 24 * heightForHour)
                .padding(.top, CGFloat(event.allDayEntries.count * 20) + 20)
                .padding(.bottom, 10)
            
            HomeDashCalendarContent(events: event)
                .frame(height: 24 * heightForHour)
                .padding(.bottom, 10)
                .padding(.top, CGFloat(event.allDayEntries.count * 20) + 20)
            
            HomeAllDayEvents(events: event)
                .padding(.vertical, 10)
                .frame(height: CGFloat(event.allDayEntries.count * 20))
        }.frame(height: 24 * heightForHour + 20 + CGFloat(event.allDayEntries.count * 20))
        .padding(.vertical, 10)
    }
    
}

//MARK: HomeDashCalendarGrid
struct HomeDashCalendarGrid: View {
    
    @EnvironmentObject
    var timetableService: TimetableService
    
    @EnvironmentObject
    var homeViewModel: HomeViewModel
    
    
    var date: Date
    
    var startHour: Int
    var endHour: Int
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                ForEach (startHour...endHour,
                         id: \.self) { hour in
                    HStack(spacing: 0) {
                        Text(textForHour(hour))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(.secondaryLabel))
                            .padding(.trailing, 5)
                            .frame(minWidth: 45)
                            .id(hour)
                        
                        VStack {
                            Divider()
                        }
                    }
                    .frame(height: 12)
                    .padding(.bottom, hour != endHour ? heightForHour - 12 : 0)
                    
                }
            }
            
            if Calendar.current.isDateInToday(date) {
                HStack(spacing: 0) {
                    Text(Date().stringifyTime(with: .short))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(.systemBlue))
                        .padding(.trailing, 5)
                        .frame(minWidth: 45)
                    
                    
                    VStack {
                        Divider()
                            .background(Color(.systemBlue))
                    }
                }
                .frame(height: 12)
                .offset(x: 0, y: offsetFor(time: Time.now))
            }
        }
    }
    
    private func labelIsHidden(_ hour: Int) -> Bool {
        if hour < startHour || hour > endHour {
            return false
        }
        
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: self.date)
            
        return abs(date?.timeIntervalSince(Date()) ?? 0) <= 10
    }
    
    private func textForHour(_ hour: Int) -> String {
        let time = Time(hour: hour, minute: 0)
        
        if Calendar.current.isDateInToday(date) {
            let diff = abs(Time.now.timeInterval - time.timeInterval)
            if diff < 10  {
                return ""
            }
        }
        
        let date = Calendar.current.date(bySettingHour: hour % 24, minute: 0, second: 0, of: Date())
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
//        formatter.dateFormat = "h a"
//        formatter.amSymbol = "AM"
//        formatter.pmSymbol = "PM"

        return formatter.string(from: date ?? Date())
    }
    
    private func offset(for hour: Int) -> CGFloat {
        return CGFloat((hour - startHour)) * heightForHour
    }
    
    private func offsetFor(time: Time) -> CGFloat {
        let seconds = time.timeInterval
        let start = Time(hour: startHour, minute: 0).timeInterval
        
        return CGFloat(seconds - start) / 60.0 * heightForHour
    }
    
}

//MARK: HomeDashCalendarContent
struct HomeDashCalendarContent: View {
    
    @ObservedObject
    var events: CalendarDayEntry
    
    @EnvironmentObject
    var homeViewModel: HomeViewModel
    
    var body: some View {
        
        Group {
            GeometryReader { geometry in
                ForEach(events.entries, id: \.self) { event in
                    let width = self.width(for: event, maxWidth: geometry.size.width - 80)
                    
                    HomeDashCalendarEvent(event: EventViewModel(event))
                        .frame(width: width, height: height(for: event))
                        .offset(x: offsetX(for: event, width: width, environment: events.entries), y: offsetY(for: event))
                }
            }
        }
    }
    
    private func width(for event: EKEvent, maxWidth: CGFloat) -> CGFloat {
        var collisions = events.collisionsOfStartDate(for: event, in: events.entries, withMaximumDistance: .minute(45))
        
        // In case there are startDate collisions
        if collisions > 0 {
            return maxWidth / CGFloat(collisions + 1) // Divide the space into enough parts to fit all events
        }
        
        // Check if there are any collisions at all
        collisions = events.collisionCount(for: event, within: events.entries)
        
        if collisions == 0 {
            return maxWidth
        }
        
        let collisionRank = events.collisionRank(for: event)
        
        return maxWidth - CGFloat((collisions + 1) * collisionRank)
    }
    
    private func height(for event: EKEvent) -> CGFloat {
        guard var start = event.startDate,
              var end = event.endDate else {
            return 0
        }
        
        // Bound the start/ end date to the current day
        start = max(start, events.date.startOfDay)
        end = min(end, events.date.endOfDay)
        
        let duration = CGFloat(end.timeIntervalSince(start)) / 3600 // Duration of event in hours
        
        return heightForHour * duration
    }
    
    private func offsetX(for event: EKEvent , width: CGFloat, environment: [EKEvent]) -> CGFloat {
        let collisions = events.collisionsOfStartDate(for: event, in: events.entries, withMaximumDistance: .minute(45))
        
        let collisionRank = events.collisionRank(for: event)
        // In case there are startDate collisions
        if collisions > 0 {
            return 60 + CGFloat(events.collisionRank(for: event)) * width
        }
        
        return 60 + CGFloat(collisionRank * 10) // Move the event on the X axis to show all calendar indicators of the colliding events
    }
    
    private func offsetY(for event: EKEvent) -> CGFloat {
        guard let startOfDay = events.startOfDay else {
            return 0
        }
        
        guard let startOfEvent = event.startDate else {
            return 0
        }
        
        // Remove the minutes from the start date
        var comp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: startOfDay)
        
        comp.minute = 0
        
        guard let start = Calendar.current.date(from: comp) else {
            return 0
        }
        
        let difference = startOfEvent.timeIntervalSince(start)
        
        return CGFloat(difference) / 3600.0 * heightForHour
    }
}

//MARK: HomeDashCalendarEvent
struct HomeDashCalendarEvent: View {
    
    @EnvironmentObject
    var homeViewModel: HomeViewModel
    
    @ObservedObject
    var event: EventViewModel
    
    @State
    private var showEditView = false
    
    var body: some View {
        let eventDuration = self.eventDuration()
        
        return HStack(spacing: 15) {
            VStack {
                Spacer()
                Rectangle()
                    .foregroundColor(Color(.clear))
                    .frame(width: 10)
                Spacer()
            }.background(Color(calendarColor()))
            
            VStack(alignment: .leading) {
                if eventDuration > 45 {
                    HStack {
                        Text(event.calendar.title)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(calendarColor()))
                            .minimumScaleFactor(0.7)
                        
                        Spacer()
                        
                        if event.event.structuredLocation != nil {
                            Image(systemName: "location.circle.fill")
                                .foregroundColor(Color(.label))
                                .font(.system(size: 12, weight: .semibold))
                        }
                    }
                }
                Text(event.title)
                    .font(.system(size: 14, weight: .semibold))
                    .minimumScaleFactor(0.7)
                if eventDuration > 20 {
                    Text(timeString())
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color(.secondaryLabel))
                        .minimumScaleFactor(0.7)
                }
                
                if eventDuration > 45 {
                   Spacer()
                }
            }.padding(.top, eventDuration > 45 ? 5 : 0)
            
            Spacer()
        }.background(Color(UIColor(cgColor: event.calendar.cgColor).withAlphaComponent(0.35)))
        .cornerRadius(6)
        .onTapGesture {
            showEditView.toggle()
        }.sheet(isPresented: $showEditView, onDismiss: {
            homeViewModel.reload()
        }, content: {
            EventEditView(event: event)
        })
    }
    
    private func calendarColor() -> UIColor {
        return UIColor(cgColor: event.calendar.cgColor)
    }
    
    private func timeString() -> String {
        guard let start = event.startDate,
              let end = event.endDate else {
            return ""
        }
        return "\(start.stringifyTime(with: .short)) - \(end.stringifyTime(with: .short))"
    }
    
    private func eventDuration() -> TimeInterval {
        guard let start = event.startDate,
              let end = event.endDate else {
            return 0
        }
        
        return start.distance(to: end) / 60
    }
    
}


//MARK: HomeAllDayEvents
struct HomeAllDayEvents: View {
    
    
    @ObservedObject
    var events: CalendarDayEntry
    
    @EnvironmentObject
    var homeViewModel: HomeViewModel
    
    
    var body: some View {
        VStack(spacing: 2) {
            ForEach(events.allDayEntries, id: \.self) { event in
                HomeAllDayEventsRow(event: EventViewModel(event))
            }
            
        }
    }
    
}


struct HomeAllDayEventsRow: View {
    
    @EnvironmentObject
    var homeViewModel: HomeViewModel
    
    @ObservedObject
    var event: EventViewModel
    
    @State
    private var showEditView = false
    
    var body: some View {
        HStack {
            VStack {
                Spacer()
                Rectangle()
                    .foregroundColor(Color(.clear))
                    .frame(width: 4)
                Spacer()
            }
            .background(Color(UIColor(cgColor: event.calendar.cgColor)))
            
            Text(event.title)
                .font(.system(size: 10, weight: .semibold))
            
            Spacer()
            
            Text("All day")
                .font(.system(size: 10, weight: .regular))
                .padding(.trailing, 10)
        }.frame(height: 20)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(2.5)
        .onTapGesture {
            showEditView.toggle()
        }.sheet(isPresented: $showEditView) {
            homeViewModel.reload()
        } content: {
            EventEditView(event: event)
        }

    }
    
    
}
