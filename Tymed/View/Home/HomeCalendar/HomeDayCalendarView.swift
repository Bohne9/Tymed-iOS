//
//  HomeDayCalendarView.swift
//  Tymed
//
//  Created by Jonah Schueller on 18.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

fileprivate var heightForHour: CGFloat = 60

//MARK: HomeDayCalendarView
struct HomeDayCalendarView: View {
    
    @ObservedObject
    var event: CalendarDayEntry
    
    @EnvironmentObject
    var homeViewModel: HomeViewModel
    
    var body: some View {
        ZStack(alignment: .center) {
            
            HomeDashCalendarGrid(date: event.date, startHour: 0, endHour: 24)
                .frame(height: 24 * heightForHour)
                .padding(.vertical, 10)
            
            HomeDashCalendarContent(events: event)
                .frame(height: 24 * heightForHour)
                .padding(.vertical, 10)
        }.frame(height: 24 * heightForHour + 20)
        .padding(.vertical, 10)
    }
    
    private func numberOfHours() -> Int {
        guard let start = event.startOfDay,
              let end = event.endOfDay else {
            return 0
        }
        
        let startHour = Calendar.current.dateComponents([.hour], from: start).hour ?? 0
        let endHour = Calendar.current.dateComponents([.hour], from: end).hour ?? 0
        
        return (endHour - startHour + 1)
    }
    
    private func startHour() -> Int {
        guard let start = event.startOfDay else {
            return 0
        }
        
        return Calendar.current.dateComponents([.hour], from: start).hour ?? 0
    }
    
}

//MARK: HomeDashCalendarGrid
struct HomeDashCalendarGrid: View {
    
    @EnvironmentObject
    var homeViewModel: HomeViewModel
    
    var date: Date
    
    var startHour: Int
    var endHour: Int
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ForEach (stride(
                            from: startHour,
                            through: endHour,
                            by: 1).map { $0 },
                         id: \.self) { hour in
                    HStack(spacing: 0) {
                        Text(textForTime(hour))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(.secondaryLabel))
                            .padding(.trailing, 5)
                            .frame(width: 45)
                            
                        VStack {
                            Divider()
                        }
                    }
                    .frame(height: 12)
                    .offset(x: 0, y: offset(for: hour) - 6)
                    
                }
                
                if Time.now.hour >= startHour && Time.now.hour <= endHour && Calendar.current.isDateInToday(date) {
                    HStack(spacing: 0) {
                        Text(Time.now.string() ?? "")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(.systemBlue))
                            .padding(.trailing, 5)
                            .frame(width: 45)
                            
                        
                        VStack {
                            Divider()
                                .background(Color(.systemBlue))
                        }
                    }
                    .frame(height: 12)
                    .offset(x: 0, y: offsetFor(time: Time.now) - 6)
                }
                
                
            }
        }
    }
    
    private func labelIsHidden(_ hour: Int) -> Bool {
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: self.date)
            
        return abs(date?.timeIntervalSince(Date()) ?? 0) <= 10
    }
    
    private func textForTime(_ hour: Int) -> String {
        let time = Time(hour: hour, minute: 0)
        
        return time.string() ?? ""
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
        
        ZStack {
            GeometryReader { geometry in
                ForEach(events.entries, id: \.self) { event in
                    HomeDashCalendarEvent(event: event)
                        .frame(height: height(for: event))
                        .frame(width: geometry.size.width - 55)
                        .offset(x: 60, y: offset(for: event))
                }
            }
        }
    }
    
    private func height(for event: CalendarEvent) -> CGFloat {
        guard let start = event.startDate,
              let end = event.endDate else {
            return 0
        }
        
        let duration = CGFloat(end.timeIntervalSince(start)) / 3600
        
        return heightForHour * duration
    }
    
    private func offset(for event: CalendarEvent) -> CGFloat {
        guard let startOfDay = events.startOfDay else {
            print("OFFSET 0")
            return 0
        }
        
        guard let startOfEvent = event.startDate else {
            print("OFFSET 1")
            return 0
        }
        
        // Remove the minutes from the start date
        var comp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: startOfDay)
        
        comp.minute = 0
        
        guard let start = Calendar.current.date(from: comp) else {
            return 0
        }
        
        let difference = startOfEvent.timeIntervalSince(start)
        
        print("diff \(difference)")
        
        return CGFloat(difference) / 3600.0 * heightForHour
    }
}

//MARK: HomeDashCalendarEvent
struct HomeDashCalendarEvent: View {
    
    @EnvironmentObject
    var homeViewModel: HomeViewModel
    
    @ObservedObject
    var event: CalendarEvent
    
    @State
    private var showEditView = false
    
    var body: some View {
        HStack(spacing: 15) {
            VStack {
                Spacer()
                Rectangle()
                    .foregroundColor(Color(.clear))
                    .frame(width: 10)
                Spacer()
            }
            .background(Color(UIColor(event) ?? .clear))
            
            VStack(alignment: .leading) {
                Text(event.timetable?.name.uppercased() ?? "")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(UIColor(event) ?? .clear))
                Text(event.title)
                    .font(.system(size: 14, weight: .semibold))
                Text(timeString())
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(.secondaryLabel))
                Spacer()
            }.padding(.top, 5)
            
            Spacer()
        }.background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(6)
        .padding(.trailing)
        .onTapGesture {
            showEditView.toggle()
        }.sheet(isPresented: $showEditView, content: {
            if let lesson = event.asLesson {
                LessonEditView(
                    lesson: lesson,
                    dismiss: {
                        homeViewModel.reload()
                        showEditView.toggle()
                })
            }else if let event = self.event.asEvent {
                EventEditView(event: event, presentationDelegate: homeViewModel, presentationHandler: ViewWrapperPresentationHandler())
            }else {
                Text("Ups! Something went wrong :(")
            }
        })
    }
    
    private func timetableColor() -> UIColor {
        guard let timetable = event.timetable else {
            return .clear
        }
        return UIColor(timetable) ?? .clear
    }
    
    private func timeString() -> String {
        guard let start = event.startDate,
              let end = event.endDate else {
            return ""
        }
        return "\(start.stringifyTime(with: .short)) - \(end.stringifyTime(with: .short))"
    }
    
}

