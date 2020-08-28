//
//  LesonEditView.swift
//  Tymed
//
//  Created by Jonah Schueller on 05.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

class LessonEditViewWrapper: ViewWrapper<LessonEditView> {
    
    var lesson: Lesson?
    
    override func createContent() -> UIHostingController<LessonEditView>? {
        guard let lesson = lesson else {
            return nil
        }
        
        return UIHostingController(rootView: LessonEditView(
                                    lesson: lesson,
                                    dismiss: {
                                        self.homeDelegate?.reload()
                                        self.dismiss(animated: true, completion: nil)
                                    }))
    }
    
}

//MARK: LessonEditView
struct LessonEditView: View {
    
    @ObservedObject var lesson: Lesson
    
    var dismiss: () -> Void
    
    var body: some View {
        NavigationView {
            LessonEditContentView(lesson: lesson, dismiss: dismiss)
        }
    }
    
}

//MARK: LessonEditContentView
struct LessonEditContentView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var moc
    
    @ObservedObject var lesson: Lesson
    
    var dismiss: () -> Void
    
    //MARK: Lesson Subject Title
    @State private var subjectTitle = ""
    
    //MARK: Lesson Time state
    @State private var showSubjectSuggestions = false
    
    @State private var showStartTimePicker = false
    @State private var showEndTimePicker = false
    @State private var showDayPicker = false
    
    @State private var startTime = Date()
    @State private var endTime = Date() + TimeInterval(3600)
    @State private var interval: TimeInterval = 3600
    
    @State private var day: Day = .current
    
    @State private var sendNotification = false
    @State private var presentNotificationPicker = false
    @State private var notificationOffset: NotificationOffset?
    
    //MARK: Color
    @State private var color: String = "blue"
    
    //MARK: Note
    @State private var note = ""
    
    //MARK: Timetable
    @State private var timetable: Timetable? = TimetableService.shared.defaultTimetable()
    
    
    @State private var subjectTimetableAlert = false
    @State private var showLessonDeleteAlert = false
    
    
    var body: some View {
        List {
            Section {
                if showSubjectSuggestions {
                    
                    HStack(spacing: 15) {
                        ForEach(subjectSuggestions(), id: \.self) { (subject: Subject) in
                            HStack {
                                Spacer()
                                Text(subject.name)
                                    .minimumScaleFactor(0.01)
                                    .lineLimit(1)
                                    .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
                                
                                Spacer()
                            }
                            .frame(height: 30)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .background(Color(UIColor(subject) ?? .clear))
                            .cornerRadius(10.5)
                            .onTapGesture {
                                selectSubjectTitle(subject)
                            }
                        }
                    }.frame(height: 45)
                    .animation(.easeInOut(duration: 0.5))
                    
                }
                
                CustomTextField("Subject Name", $subjectTitle) {
                    withAnimation {
                        showSubjectSuggestions.toggle()
                    }
                } onReturn: {
                    withAnimation {
                        showSubjectSuggestions.toggle()
                    }
                }
                
                NavigationLink(destination: AppColorPickerView(color: $color)) {
                    DetailCellDescriptor("Color", image: "paintbrush.fill", UIColor(named: color) ?? .clear, value: color.capitalized)
                }
                    
            }
            
            if lesson.unarchivedTasks?.count ?? 0 > 0 {
                Section {
                    ForEach(lessonTasks(), id: \.self) { task in
                        TaskPreviewCell(task: task)
                    }
                }
            }
            
            //MARK: Times
            Section {
                DetailCellDescriptor("Start time", image: "clock.fill", .systemBlue, value: time(for: startTime))
                    .onTapGesture {
                        withAnimation {
                            showStartTimePicker.toggle()
                            showEndTimePicker = false
                            showDayPicker = false
                        }
                    }
                
                if showStartTimePicker {
                    HStack {
                        Spacer()
                        DatePicker("", selection: $startTime, displayedComponents: DatePickerComponents.hourAndMinute)
                            .labelsHidden()
                            .datePickerStyle(GraphicalDatePickerStyle())
                    }.frame(height: 45)
                }
                
                DetailCellDescriptor("End time", image: "clock.fill", .systemOrange, value: time(for: endTime))
                    .onTapGesture {
                        withAnimation {
                            showEndTimePicker.toggle()
                            showStartTimePicker = false
                            showDayPicker = false
                        }
                    }
                
                if showEndTimePicker {
                    HStack {
                        Spacer()
                        DatePicker("", selection: $endTime, in: startTime..., displayedComponents: DatePickerComponents.hourAndMinute)
                            .labelsHidden()
                            .datePickerStyle(GraphicalDatePickerStyle())
                    }.frame(height: 45)
                }
                
                
                DetailCellDescriptor("Day", image: "calendar", .systemGreen, value: day.string())
                    .onTapGesture {
                        withAnimation {
                            showDayPicker.toggle()
                            showStartTimePicker = false
                            showEndTimePicker = false
                        }
                    }
                
                if showDayPicker {
                    Picker("", selection: $day) {
                        ForEach(Day.allCases, id: \.self) { day in
                            Text(day.string())
                        }
                    }.pickerStyle(WheelPickerStyle())
                    .frame(height: 120)
                }
                
                //MARK: Notification
                HStack {
                    DetailCellDescriptor("Notification", image: "alarm.fill", .systemGreen, value: textForNotificationCell())
                    .onTapGesture {
                        withAnimation {
                            presentNotificationPicker.toggle()
                        }
                    }
                    
                    Toggle("", isOn: $sendNotification).labelsHidden()
                }.frame(height: 45)
                
                
                if sendNotification && presentNotificationPicker {
                    NavigationLink(
                        destination: NotificationOffsetView(notificationOffset: $notificationOffset),
                        label: {
                            HStack {
                                Spacer()
                                Text(notificationOffset?.title ?? "")
                            }
                        }).frame(height: 45)
                }
            }
            
            
            //MARK: Timetable
            
            Section {
                HStack {
                    
                    NavigationLink(destination: AppTimetablePicker(timetable: $timetable)) {
                        DetailCellDescriptor("Timetable", image: "tray.full.fill", .systemRed, value: timetableTitle())
                        Spacer()
                        if timetable == TimetableService.shared.defaultTimetable() {
                            Text("Default")
                                .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                                .background(Color(.tertiarySystemGroupedBackground))
                                .font(.system(size: 13, weight: .semibold))
                                .cornerRadius(10)
                        }
                    }
                    
                }
            }
            
            //MARK: Notes
            Section {
                MultilineTextField("Notes", $note)
            }
            
            Section {
                DetailCellDescriptor("Delete", image: "trash.fill", .systemRed)
                    .onTapGesture {
                        showLessonDeleteAlert.toggle()
                    }
            }
            
        }.listStyle(InsetGroupedListStyle())
        .font(.system(size: 16, weight: .semibold))
        .navigationTitle("Lesson")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: Button("Cancel"){
            dismiss()
        }, trailing: Button("Done") {
            saveLesson()
        })
        .onChange(of: endTime) { value in
            interval = endTime.timeIntervalSince(startTime)
        }
        .onChange(of: startTime) { value in
            endTime = startTime + interval
        }
        .actionSheet(isPresented: $showLessonDeleteAlert) {
            ActionSheet(
                title: Text("Are you sure?"),
                message: Text("You cannot undo this."),
                buttons: [.destructive(Text("Delete"), action: {
                    deleteLesson()
                }), .cancel()])
        }
        .alert(isPresented: $subjectTimetableAlert) {
            Alert(
                title: Text("Do you want to switch timetables?"),
                message: Text("All other lessons of the subject will change the timetables aswell."),
                primaryButton:
                    .destructive(Text("Use \(timetable?.name ?? "")"),
                                 action: {
                                    saveLesson()
            }), secondaryButton:
                    .cancel(Text("Keep \(timetableNameOfSubject())"),
                            action: {
                                timetable = TimetableService.shared.subject(with: subjectTitle)?.timetable
                                saveLesson()
                }))
        }.onAppear(perform: loadLessonValues)
        .onDisappear {
            saveLesson(dismiss: false)
        }
    }
    
    //MARK: deleteLesson
    private func deleteLesson() {
        presentationMode.wrappedValue.dismiss()
        DispatchQueue.main.async {
            TimetableService.shared.deleteLesson(lesson)
        }
    }
    
    private func loadLessonValues() {
        if let subject = lesson.subject {
            selectSubjectTitle(subject)
            timetable = subject.timetable
            color = subject.color
        }
        
        startTime = lesson.startTime.date ?? Date()
        endTime = lesson.endTime.date ?? Date()
        day = lesson.day
        note = lesson.note ?? ""
        
        lesson.getNotifications { (notifications) in
            sendNotification = notifications.count != 0
            if sendNotification, let not = notifications.first {
                if let date = (not.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate(),
                   let start = lesson.startTime.date {
                    notificationOffset = NotificationOffset(value: start.timeIntervalSince(date))
                }
            }
        }
    }
    
    private func lessonTasks(_ limit: Int = 3) -> [Task] {
        return (lesson.tasks?.allObjects as? [Task] ?? []).filter { !$0.archived }.prefix(limit).map { $0 }
    }
    
    private func selectSubjectTitle(_ subject: Subject) {
        subjectTitle = subject.name
        let subject = TimetableService.shared.subject(with: subjectTitle)
        timetable = subject?.timetable
        color = subject?.color ?? "blue"
    }
    
    //MARK: timetableNameOfSubject
    private func timetableNameOfSubject() -> String {
        return TimetableService.shared.subject(with: subjectTitle, addNewSubjectIfNull: false)?.timetable?.name ?? ""
    }
    
    //MARK: timetableTitle
    private func timetableTitle() -> String? {
        return timetable?.name
    }
    
    //MARK: time
    private func time(for date: Date) -> String? {
        return date.stringifyTime(with: .short)
    }
    
    private func textForNotificationCell() -> String? {
        if !sendNotification {
            return nil
        }
        guard let notificationOffset = notificationOffset else {
            return ""
        }
        
        return "\(day.string()), \((startTime - notificationOffset.timeInterval).stringifyTime(with: .short))"
    }
    
    //MARK: subjectSuggestions
    private func subjectSuggestions() -> [Subject] {
        return TimetableService.shared.subjectSuggestions(for: subjectTitle)
            .prefix(3)
            .map { $0 }
    }
    
    //MARK: saveLesson
    private func saveLesson(dismiss: Bool = true) {
        guard let subject = TimetableService.shared.subject(with: subjectTitle) else {
            return
        }
        
        if subject.timetable != timetable {
            subjectTimetableAlert.toggle()
            return
        }
        
        if sendNotification {
            lesson.getNotifications { (notifications) in
                NotificationService.current.removeAllNotifications(of: lesson)
                
                guard let notificationOffset = notificationOffset else {
                    return
                }
                
                NotificationService.current.scheduleStartNotification(for: lesson, notificationOffset)
            }
        }else {
            NotificationService.current.removeAllNotifications(of: lesson)
        }
        
        subject.timetable = timetable
        subject.color = color
        subject.name = subjectTitle
        
        lesson.subject = subject
        
        lesson.startTime = Time(from: startTime)
        lesson.endTime = Time(from: endTime)
        lesson.dayOfWeek = Int32(day.rawValue)
        lesson.note = note
        
        
        TimetableService.shared.save()
        
        if dismiss {
            self.dismiss()
        }
    }
    
}

