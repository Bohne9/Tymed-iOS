//
//  TaskAddView.swift
//  Tymed
//
//  Created by Jonah Schueller on 02.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

class TaskAddViewWrapper: UIViewController {
    
    let contentView = UIHostingController(rootView: TaskAddView())
    
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
    
    @Environment(\.presentationMode) var presentationMode
    
    //MARK: Title states
    @State
    private var taskTitle = ""
    
    @State
    private var taskDescription = ""
    
    
    //MARK: Due date state
    @State
    private var hasDueDate = false
    
    @State
    private var presentDueDatePicker = false
    
    @State
    private var dueDate = Date()
    
    @State
    private var sendNotification = false
    
    @State
    private var presentNotificationPicker = false
    
    @State
    var notificationOffset: NotificationOffset = NotificationOffset.atDueDate
    
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
                        ZStack {
                            Color(.systemRed)
                            Image(systemName: "calendar")
                                .font(.system(size: 18, weight: .bold))
                        }.cornerRadius(6).frame(width: 28, height: 28)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Due date")
                                if hasDueDate {
                                    Text(dueDate.stringify(dateStyle: .short, timeStyle: .short))
                                        .foregroundColor(Color(.systemBlue))
                                        .font(.system(size: 12, weight: .semibold))
                                }
                            }
                            Spacer()
                        }.contentShape(Rectangle())
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
                        
                        HStack {
                            ZStack {
                                Color(.systemGreen)
                                Image(systemName: "alarm.fill")
                                    .font(.system(size: 18, weight: .bold))
                            }.cornerRadius(6).frame(width: 28, height: 28)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Notification")
                                    if sendNotification {
                                        Text(textForNotificationCell())
                                            .foregroundColor(Color(.systemBlue))
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                }
                                Spacer()
                            }.contentShape(Rectangle())
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
                        ZStack {
                            Color(.systemBlue)
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 18, weight: .bold))
                        }.cornerRadius(6).frame(width: 28, height: 28)
                        
                        Text("Lesson")
                        
                        Spacer()
                        
                        Toggle("", isOn: $hasLessonAttached)
                    }.frame(height: 45)
                    
                    if hasLessonAttached {
                        NavigationLink(
                            destination: LessonPickerView(lesson: $lesson),
                            label: {
                                HStack {
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text(titleForLessonCell())
                                            .foregroundColor(foregroundColorForLessonCell())
                                        if lesson != nil {
                                            Spacer()
                                            Text(textForLessonDate())
                                                .foregroundColor(Color(.systemBlue))
                                                .font(.system(size: 12, weight: .semibold))
                                        }
                                    }
                                }
                            }).frame(height: 45)
                    }
                }
            }.listStyle(InsetGroupedListStyle())
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
    
    private func cancel() {
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
        
        presentationMode.wrappedValue.dismiss()
    }
}


//MARK: NotificationOffsetView
struct NotificationOffsetView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding
    var notificationOffset: NotificationOffset
    
    var body: some View {
        List(NotificationOffset.allCases, id: \.rawValue) { offset in
            
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
    
    var body: some View {
        Text("Coming soon")
    }
}


struct TaskAddView_Previews: PreviewProvider {
    static var previews: some View {
        TaskAddView().colorScheme(.dark)
    }
}
