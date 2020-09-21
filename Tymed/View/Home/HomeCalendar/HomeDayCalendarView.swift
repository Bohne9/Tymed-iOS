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
                .environmentObject(TimetableService.shared)
                .frame(height: 24 * heightForHour)
                .padding(.vertical, 10)
            
            HomeDashCalendarContent(events: event)
                .frame(height: 24 * heightForHour)
                .padding(.vertical, 10)
        }.frame(height: 24 * heightForHour + 20)
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
                    .id(hour)
                    .frame(height: 12)
                    .padding(.bottom, hour != endHour ? heightForHour - 12 : 0)
                    
                }
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
                .offset(x: 0, y: offsetFor(time: Time.now))
            }
        }
    }
    
    private func labelIsHidden(_ hour: Int) -> Bool {
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: self.date)
            
        return abs(date?.timeIntervalSince(Date()) ?? 0) <= 10
    }
    
    private func textForTime(_ hour: Int) -> String {
        let time = Time(hour: hour, minute: 0)
        
        if Calendar.current.isDateInToday(date) {
            let diff = abs(Time.now.timeInterval - time.timeInterval)
            if diff < 10 {
                return ""
            }
        }
        
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
        
        Group {
            GeometryReader { geometry in
                ForEach(events.entries, id: \.self) { event in
                    let width = self.width(for: event, maxWidth: geometry.size.width - 60)
                    
                    HomeDashCalendarEvent(event: event)
                        .frame(width: width, height: height(for: event))
                        .offset(x: offsetX(for: event, width: width, environment: events.entries), y: offsetY(for: event))
                }
            }
        }
    }
    
    private func width(for event: CalendarEvent, maxWidth: CGFloat) -> CGFloat {
        let collisions = event.collisionCount(within: events.entries)
        
        if collisions == 0 {
            return maxWidth
        }
        
        return maxWidth / CGFloat(collisions + 1)
    }
    
    private func height(for event: CalendarEvent) -> CGFloat {
        guard let start = event.startDate,
              let end = event.endDate else {
            return 0
        }
        
        let duration = CGFloat(end.timeIntervalSince(start)) / 3600
        
        return heightForHour * duration
    }
    
    private func offsetX(for event: CalendarEvent, width: CGFloat, environment: [CalendarEvent]) -> CGFloat {
        return 60 + CGFloat(event.collisionRank(in: environment)) * width
    }
    
    private func offsetY(for event: CalendarEvent) -> CGFloat {
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
                if eventDuration() > 45 {
                    Text(event.timetable?.name.uppercased() ?? "")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(UIColor(event) ?? .clear))
                }
                Text(event.title)
                    .font(.system(size: 14, weight: .semibold))
                    .minimumScaleFactor(0.75)
                if eventDuration() > 20 {
                    Text(timeString())
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color(.secondaryLabel))
                        .minimumScaleFactor(0.75)
                }
                Spacer()
            }.padding(.top, 5)
            
            Spacer()
        }.background(Color(UIColor.tertiarySystemGroupedBackground.withAlphaComponent(0.75)))
        .cornerRadius(6)
//        .padding(.trailing)
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
//        .contextMenu {
//
//        }.previewContext(Text("Hallo"))
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
    
    private func eventDuration() -> TimeInterval {
        guard let start = event.startDate,
              let end = event.endDate else {
            return 0
        }
        
        return start.distance(to: end) / 60
    }
    
}

