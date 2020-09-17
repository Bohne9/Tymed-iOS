//
//  HomeDashView.swift
//  Tymed
//
//  Created by Jonah Schueller on 17.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

fileprivate var heightForHour: CGFloat = 80

class HomeDashViewWrapper: ViewWrapper<HomeDashView> {
    
    
    override func createContent() -> UIHostingController<HomeDashView>? {
        
        return UIHostingController(rootView: HomeDashView())
    }
    
}

//MARK: HomeDashView
struct HomeDashView: View {
    
    @ObservedObject
    var homeViewModel = HomeViewModel()
    
    var body: some View {
        List {
            
            Section {
                VStack(alignment: .leading) {
                    Text(Date().stringify(with: .long, relativeFormatting: false).uppercased())
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(.systemBlue))
                    
                    Text("Good morning Jonah 🙋‍♂️,\nyou got a busy day before.\nYour day starts at 8 am with Math. You'll be done at 7 pm. \n\nHave a great day! 👍")
                        .font(.system(size: 16, weight: .medium))
                        .padding(.top, 5)
                }
                .padding(.vertical, 10)
            }
            
            Section(header:
                        Text("Tasks")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(.label))) {
                ForEach(homeViewModel.tasks, id: \.self) { task in
                    Section {
                        HomeDashTaskCell(task: task)
                            .frame(height: 45)
                    }
                }
            }
            
            Section(header:
                        Text("Today")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(.label))) {
                HomeDashCalendarCell(event: CalendarDayEntry(for: Date(), entries: homeViewModel.events))
            }
            
        }.listStyle(InsetGroupedListStyle())
    }
}


//MARK: HomeDashTaskCell
struct HomeDashTaskCell: View {
    
    @ObservedObject
    var task: Task
    
    @State
    var showTaskDetail = false
    
    var body: some View {
        HStack(spacing: 15) {
            Rectangle()
                .foregroundColor(Color(UIColor(task.timetable)!))
                .frame(width: 10, height: 55)
            
            Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 22.5, weight: .semibold))
                .foregroundColor(Color(task.completed ? .systemGreen : .systemBlue))
                .frame(width: 25, height: 25)
                .onTapGesture {
                    withAnimation {
                        task.completed.toggle()
                    }
                }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(task.title)
                    .font(.system(size: 15, weight: .semibold))
                
                if let date = task.due {
                    Text(textFor(date: date))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(.secondaryLabel))
                }
            }
            
            Spacer()
        }.contentShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            showTaskDetail.toggle()
        }.sheet(isPresented: $showTaskDetail, content: {
            TaskEditView(task: task, dismiss: { })
        })
        .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 20))
    }
    
    private func textFor(date: Date) -> String {
        return "\(date.stringify(dateStyle: .short, timeStyle: .short))"
    }
    
}

//MARK: HomeDashCalendarCell
struct HomeDashCalendarCell: View {
    
    @State
    var event: CalendarDayEntry
    
    var body: some View {
        ZStack {
            HomeDashCalendarGrid(startHour: startHour(), endHour: startHour() + numberOfHours())
                .frame(height: CGFloat(numberOfHours()) * heightForHour + 20)
                .padding(.vertical, 10)
            
            HomeDashCalendarContent(events: event)
                .frame(height: CGFloat(numberOfHours()) * heightForHour + 20)
                .padding(.vertical, 10)
        }
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
    
    var startHour: Int
    var endHour: Int
    
    var body: some View {
        Group {
            GeometryReader { geometry in
                ForEach (stride(
                            from: startHour,
                            through: endHour,
                            by: 1).map { $0 },
                         id: \.self) { hour in
                    HStack(spacing: 0) {
                        Text("\(hour % 12) \(hour > 12 ? "pm" : "am")")
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
            }
        }
    }
    
    private func offset(for hour: Int) -> CGFloat {
        return CGFloat((hour - startHour)) * heightForHour
    }
    
}

//MARK: HomeDashCalendarContent
struct HomeDashCalendarContent: View {
    
    @State
    var events: CalendarDayEntry
    
    var body: some View {
        
        Group {
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
        guard let startOfDay = events.startOfDay,
              let startOfEvent = event.startDate else {
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
    
    @State
    var event: CalendarEvent
    
    @State
    private var showEditView = false
    
    var body: some View {
        HStack(spacing: 15) {
            Rectangle()
                .foregroundColor(Color(UIColor(event)!))
                .frame(width: 10, height: heightForHour)
            
            VStack(alignment: .leading) {
                Text(event.timetable?.name.uppercased() ?? "")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(UIColor(event)!))
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
                LessonEditView(lesson: lesson, dismiss: { showEditView.toggle() })
            }else if let event = self.event.asEvent {
                EventEditView(event: event, presentationHandler: ViewWrapperPresentationHandler())
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

struct HomeDashView_Previews: PreviewProvider {
    static var previews: some View {
        HomeDashView().colorScheme(.dark)
    }
}
