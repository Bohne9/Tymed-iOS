//
//  TaskEditView.swift
//  Tymed
//
//  Created by Jonah Schueller on 02.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI
import CoreData

class TaskEditViewWrapper: UIViewController {
    
    var task: Task?
    
    var contentView: UIHostingController<TaskEditView>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let task = task else {
            return
        }
        
        contentView = UIHostingController(rootView: TaskEditView(task) {
            self.dismiss(animated: true, completion: nil)
        })
        
        guard let content = contentView else {
            return
        }
        
        addChild(content)
        view.addSubview(content.view)
        
        setupConstraints()
    }
    
    fileprivate func setupConstraints() {
        contentView?.view.translatesAutoresizingMaskIntoConstraints = false
        contentView?.view.constraintToSuperview()
    }
}

//MARK: TaskEditView
struct TaskEditView: View {
    
    var task: Task
    
    var dismiss: () -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    //MARK: Title states
    @State private var taskTitle: String = ""
    
    @State private var taskDescription: String = ""
    
    //MARK: Due date state
    @State private var hasDueDate = false
    
    @State private var presentDueDatePicker = false
    
    @State private var dueDate = Date()
    
    @State private var sendNotification = false
    
    @State private var presentNotificationPicker = false
    
    @State var notificationOffset: NotificationOffset = NotificationOffset.atDueDate
    
    //MARK: Lesson state
    @State private var hasLessonAttached = false
    
    @State private var presentLessonPicker = false
    
    @State private var lesson: Lesson?
    
    //MARK: Archive state
    @State private var isArchived = false
    
    init(_ task: Task, _ dismiss: @escaping () -> Void) {
        self.task = task
        self.dismiss = dismiss
        self.taskTitle = task.title
        self.taskDescription = task.text ?? ""
        
        loadTaskValues()
    }
    
    
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
                                .font(.system(size: 15, weight: .bold))
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
                                    .font(.system(size: 15, weight: .bold))
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
                                .font(.system(size: 15, weight: .bold))
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
                //MARK: Archive
                Section {
                    HStack {
                        ZStack {
                            Color(.systemBlue)
                            Image(systemName: "tray.full.fill")
                                .font(.system(size: 15, weight: .bold))
                        }.cornerRadius(6).frame(width: 28, height: 28)
                        
                        Text("Archived")
                        
                        Spacer()
                        
                        Toggle("", isOn: $isArchived)
                    }.frame(height: 45)
                }
                //MARK: Delete
                Section {
                    HStack {
                        ZStack {
                            Color(.systemBlue)
                            Image(systemName: "trash.fill")
                                .font(.system(size: 15, weight: .bold))
                        }.cornerRadius(6).frame(width: 28, height: 28)
                        
                        Text("Delete")
                        
                        Spacer()
                        
                    }.frame(height: 45)
                    .onTapGesture {
                        
                    }
                }
            }.listStyle(InsetGroupedListStyle())
            .navigationTitle("Task")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel", action: {
                cancel()
            }), trailing: Button("Done", action: {
                saveTask()
            }))
        }
    }
    
    private func loadTaskValues() {
//        guard let task = task else {
//            return
//        }
        
        
        taskTitle = task.title
        taskDescription = task.text ?? taskDescription
        dueDate = task.due ?? dueDate
        lesson = task.lesson
        isArchived = task.archived
        
        task.getNotifications { (notifications) in
            sendNotification = notifications.count != 0
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
    
    private func saveTask() {
//        guard let task = task else {
//            return
//        }
        
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
            task.getNotifications { (notifications) in
                if notifications.count == 0 {
                    NotificationService.current.scheduleDueDateNotification(for: task, notificationOffset)
                }
            }
        }else {
            NotificationService.current.notificationDueDateRequest(for: task)
        }
        
        dismiss()
        presentationMode.wrappedValue.dismiss()
    }
    
    private func deleteTask() {
//        guard let task = task else {
//            return
//        }
        
        TimetableService.shared.deleteTask(task)
        
        dismiss()
        presentationMode.wrappedValue.dismiss()
        
    }
}


struct TaskEditView_Previews: PreviewProvider {
    static var previews: some View {
        TaskAddView(dismiss: {
            
        }).colorScheme(.dark)
    }
}
