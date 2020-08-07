//
//  TaskAddView.swift
//  Tymed
//
//  Created by Jonah Schueller on 02.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI
import CoreData

class TaskAddViewWrapper: UIViewController {
    
    var taskDelegate: HomeTaskDetailDelegate?
    
    lazy var contentView = UIHostingController(rootView: TaskAddView(dismiss: {
        self.taskDelegate?.reload()
        self.dismiss(animated: true, completion: nil)
    }))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(contentView)
        view.addSubview(contentView.view)
        
        setupConstraints()
    }
    
    fileprivate func setupConstraints() {
        contentView.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.view.constraintToSuperview()
    }
}

//MARK: TaskAddView
struct TaskAddView: View {
    
    var dismiss: () -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    //MARK: Title states
    @State
    private var taskTitle = ""
    
    @State
    private var taskDescription = ""
    
    
    //MARK: Due date state
    @State
    private var hasDueDate = true
    
    @State
    private var presentDueDatePicker = false
    
    @State
    private var dueDate = Date()
    
    @State
    private var sendNotification = false
    
    @State
    private var presentNotificationPicker = false
    
    @State
    var notificationOffset: NotificationOffset = NotificationOffset.atEvent
    
    //MARK: Lesson state
    @State
    private var hasLessonAttached = false
    
    @State
    private var presentLessonPicker = false
    
    @State
    private var lesson: Lesson?
    
    var body: some View {
        NavigationView {
            List {
                
                //MARK: Title
                Section {
                    TextField("Title", text: $taskTitle)
                    TextField("Description", text: $taskDescription).lineLimit(-1)
                }
                
                //MARK: Due Date
                Section {
                    HStack {
                        
                        DetailCellDescriptor("Due date", image: "calendar", .systemRed, value: dueDate.stringify(dateStyle: .short, timeStyle: .short))
                        .onTapGesture {
                            withAnimation {
                                presentDueDatePicker.toggle()
                            }
                        }
                        
                        Toggle("", isOn: $hasDueDate).labelsHidden()
                    }.frame(height: 45)
                    
                    
                    if hasDueDate {
                        if presentDueDatePicker {
                            DatePicker("", selection: $dueDate)
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .frame(height: 350)
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
                                        Text(notificationOffset.title)
                                    }
                                }).frame(height: 45)
                        }
                    }
                    
                }
                
                //MARK: Lesson Attach
                Section {
                    
                    HStack {
                        DetailCellDescriptor("Lesson", image: "doc.text.fill", .systemBlue)
                        
                        Toggle("", isOn: $hasLessonAttached)
                    }.frame(height: 45)
                    
                    
                    if hasLessonAttached {
                        NavigationLink(
                            destination: LessonPickerView(lesson: $lesson),
                            label: {
                                HStack {
                                    if lesson != nil {
                                        Circle()
                                            .frame(width: 10, height: 10)
                                            .foregroundColor(subjectColor(lesson))
                                    }
                                    
                                    Text(titleForLessonCell())
                                        .foregroundColor(foregroundColorForLessonCell())
                                    Spacer()
                                    if lesson != nil {
                                        Text(lessonTime(lesson))
                                    }
                                        
                                }.contentShape(Rectangle())
                                .frame(height: 45)
                                .font(.system(size: 14, weight: .semibold))
                            }).frame(height: 45)
                    }
                }
            }.listStyle(InsetGroupedListStyle())
            .font(.system(size: 16, weight: .semibold))
            .navigationTitle("Task")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel", action: {
                cancel()
            }), trailing: Button("Add", action: {
                addTask()
            }))
        }
    }
    
    private func titleForLessonCell() -> String {
        return lesson?.subject?.name ?? "Choose a lesson"
    }
    
    private func textForLessonDate() -> String {
        guard let lesson = self.lesson else {
            return ""
        }
        
        return "\(lesson.day.shortString()) \u{2022} \(lesson.startTime.string() ?? "") - \(lesson.endTime.string() ?? "")"
    }
    
    private func foregroundColorForLessonCell() -> Color {
        return lesson?.subject?.name != nil ? Color(.label) : Color(.systemBlue)
    }
    
    private func textForNotificationCell() -> String {
        return (dueDate - notificationOffset.timeInterval).stringify(dateStyle: .short, timeStyle: .short)
    }
    
    private func subjectColor(_ lesson: Lesson?) -> Color {
        return Color(UIColor(lesson) ?? .clear)
    }
    
    private func lessonTime(_ lesson: Lesson?) -> String {
        return "\(lesson?.startTime.string() ?? "") - \(lesson?.endTime.string() ?? "")"
    }
    
    private func cancel() {
        dismiss()
        presentationMode.wrappedValue.dismiss()
    }
    
    private func addTask() {
        let task = TimetableService.shared.task()
        
        task.title = taskTitle
        task.text = taskDescription
        task.due = hasDueDate ? dueDate : nil
        task.lesson = hasLessonAttached ? lesson : nil
        task.completed = false
        task.priority = 0
        task.archived = false
        
        guard let defaultTimetable = TimetableService.shared.defaultTimetable() else {
            return
        }
        task.timetable = defaultTimetable
        
        TimetableService.shared.save()
        
        if sendNotification {
            NotificationService.current.scheduleDueDateNotification(for: task, notificationOffset)
        }
        
        dismiss()
        presentationMode.wrappedValue.dismiss()
    }
}


//MARK: NotificationOffsetView
struct NotificationOffsetView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding
    var notificationOffset: NotificationOffset
    
    var body: some View {
        List(NotificationOffset.allCases, id: \.value) { offset in
            
            HStack {
                Text(offset.title)
                Spacer()
                
                if offset == notificationOffset {
                    Image(systemName: "checkmark").foregroundColor(Color(.systemBlue))
                }
            }
            .contentShape(Rectangle())
            .frame(height: 45)
            .onTapGesture {
                notificationOffset = offset
                presentationMode.wrappedValue.dismiss()
            }
            
        }.listStyle(InsetGroupedListStyle())
        .navigationTitle("")
    }
}

//MARK: LessonPickerView
struct LessonPickerView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding
    var lesson: Lesson?
    
    var lessons: [Day: [Lesson]] = {
        guard let lessons = TimetableService.shared.fetchLessons() else {
            return [Day: [Lesson]]()
        }
        
        return TimetableService.shared.sortLessonsByWeekDay(lessons)
    }()
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("None")
                    Spacer()
                }.contentShape(Rectangle())
                .onTapGesture {
                    self.lesson = nil
                    presentationMode.wrappedValue.dismiss()
                }
            }
            
            ForEach(weekDays(), id: \.self) { (day: Day) in
                Section(header: Text(day.string()).font(.system(size: 12, weight: .semibold))) {
                    ForEach(lessonsFor(day)) { lesson in
                        HStack {
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(subjectColor(lesson))
                            
                            Text(lesson.subject?.name ?? "")
                            Spacer()
                            Text(lessonTime(lesson))
                        }.contentShape(Rectangle())
                        .frame(height: 45)
                        .font(.system(size: 16, weight: .semibold))
                        .onTapGesture {
                            self.lesson = lesson
                            presentationMode.wrappedValue.dismiss()
                        }
                        
                    }
                }
            }
        }.listStyle(InsetGroupedListStyle())
        .navigationTitle("Lesson")
    }
    
    private func weekDays() -> [Day] {
        return Array(lessons.keys).sorted(by: { $0 < $1})
    }
    
    private func lessonsFor(_ day: Day) -> [Lesson] {
        return lessons[day] ?? []
    }
    
    private func subjectColor(_ lesson: Lesson) -> Color {
        return Color(UIColor(lesson) ?? .clear)
    }
    
    private func lessonTime(_ lesson: Lesson) -> String {
        return "\(lesson.startTime.string() ?? "") - \(lesson.endTime.string() ?? "")"
    }
}


struct TaskAddView_Previews: PreviewProvider {
    static var previews: some View {
        TaskAddView(dismiss: {
            
        }).colorScheme(.dark)
    }
}

struct LessonPickerView_Previews: PreviewProvider {
    
    static var previews: some View {
        LessonPickerView(lesson: .constant(nil)).colorScheme(.dark)
    }
}
