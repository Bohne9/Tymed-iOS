//
//  TaskEditView.swift
//  Tymed
//
//  Created by Jonah Schueller on 02.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI
import CoreData

class TaskEditViewWrapper: ViewWrapper<TaskEditView> {
    
    var task: Task?
    
    override func createContent() -> UIHostingController<TaskEditView>? {
        guard let task = task else {
            return nil
        }
        
        let taskEditView = TaskEditView(task: task,
                                        dismiss: {
                                            self.homeDelegate?.reload()
                                            self.dismiss(animated: true, completion: nil)
                                        })
        
        return UIHostingController(rootView: taskEditView)
    }

}

//MARK: TaskEditView
struct TaskEditView: View {
    
    @ObservedObject var task: Task
    
    var dismiss: () -> Void
    
    var body: some View {
        NavigationView {
            TaskEditContent(task: task, dismiss: dismiss)
        }
    }
    
//    //MARK: cancel
//    private func cancel() {
//        dismiss()
//        presentationMode.wrappedValue.dismiss()
//    }
//    
//    //MARK: saveTask
//    private func saveTask() {
//        
//        if sendNotification {
//            task.getNotifications { (notifications) in
//                NotificationService.current.scheduleDueDateNotification(for: task, notificationOffset)
//                NotificationService.current.removeAllNotifications(of: task)
//            }
//        }else {
//            NotificationService.current.removeAllNotifications(of: task)
//        }
//        
//        task.title = taskTitle
//        task.text = taskDescription
//        task.due = hasDueDate ? dueDate : nil
//        task.lesson = hasLessonAttached ? lesson : nil
//        task.priority = 0
//        task.archived = isArchived
//        task.completed = isCompleted
//        task.completionDate = completionDate
//        
//        TimetableService.shared.save()
//        
//        dismiss()
//        presentationMode.wrappedValue.dismiss()
//    }
//    
}


struct TaskEditContent: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var task: Task
    
    //MARK: Title states
    @State var taskTitle: String = ""
    
    @State var taskDescription: String = ""
    
    //MARK: Completed state
    @State var isCompleted = false
    
    @State var completionDate: Date?
    
    //MARK: Due date state
    @State private var hasDueDate = false
    
    @State private var presentDueDatePicker = false
    
    @State var dueDate: Date = Date()
    
    @State private var sendNotification = false
    
    @State private var presentNotificationPicker = false
    
    @State var notificationOffset: NotificationOffset?
    
    //MARK: Lesson state
    @State private var hasLessonAttached = false
    
    @State private var presentLessonPicker = false
    
    @State private var lesson: Lesson?
    
    //MARK: Archive state
    @State var isArchived: Bool = false
    
    @State var showDismissWarning = false
    
    
    //MARK: Delete state
    @State var showDeleteAction = false
    
    var dismiss: () -> Void
    
    var body: some View {
        List {
            
            //MARK: Title
            Section {
                TextField("Title", text: $task.title)
                TextField("Description", text: $taskDescription).lineLimit(5)
                    .font(.system(size: 13, weight: .semibold))
            }
            
            //MARK: Complete
            Section {
                HStack {
                    DetailCellDescriptor("Completed", image: task.iconForCompletion(), task.completeColor(), value: task.completionDate?.stringify(dateStyle: .short, timeStyle: .short))
                        .animation(.easeOut)
                    
                    Toggle("", isOn: $task.completed)
                }.frame(height: 45)
            }
            
            //MARK: Due Date
            Section {
                HStack {
                    
                    DetailCellDescriptor("Due date", image: "calendar", .systemRed, value:
                                            hasDueDate ? dueDate.stringify(dateStyle: .short, timeStyle: .short) : nil)
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
                                    Text(notificationOffset?.title ?? "")
                                        .font(.system(size: 14, weight: .semibold))
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
                        destination: LessonPickerView(lesson: $task.lesson),
                        label: {
                            HStack {
                                if task.lesson != nil {
                                    Circle()
                                        .frame(width: 12, height: 12)
                                        .foregroundColor(subjectColor(task.lesson))
                                }
                                
                                Text(titleForLessonCell())
                                    .foregroundColor(foregroundColorForLessonCell())
                                    .font(.system(size: 14, weight: .semibold))
                                Spacer()
                                if task.lesson != nil {
                                    Text(textForLessonDate())
                                        .multilineTextAlignment(.trailing)
                                        .font(.system(size: 12, weight: .semibold))
                                        .lineLimit(2)
                                }
                                    
                            }.contentShape(Rectangle())
                            .frame(height: 45)
                        }).frame(height: 45)
                }
            }
            //MARK: Archive
            Section {
                HStack {
                    DetailCellDescriptor("Archived", image: "tray.full.fill", .systemOrange)
                    
                    Toggle("", isOn: $task.archived)
                }.frame(height: 45)
            }
            
            
            //MARK: Delete
            Section {
                DetailCellDescriptor("Delete", image: "trash.fill", .systemRed)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showDeleteAction.toggle()
                    }.actionSheet(isPresented: $showDeleteAction) {
                        ActionSheet(
                            title: Text(""),
                            message: nil,
                            buttons: [
                                .destructive(Text("Delete"), action: {
                                    deleteTask()
                                }),
                                .cancel()
                            ])
                    }
            }
        }
        .font(.system(size: 16, weight: .semibold))
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Task") //MARK: NavigationBar
        .navigationBarTitleDisplayMode(.inline)
        .actionSheet(isPresented: $showDismissWarning) {
            ActionSheet(
                title: Text(""),
                message: nil,
                buttons: [
                    .destructive(Text("Discard any changes?"), action: {
                        showDismissWarning.toggle()
                        cancel()
                    }),
                    .cancel()
                ])
        }.navigationBarItems(leading: Button("Cancel", action: {
            cancel()
        }), trailing: Button("Save", action: {
            saveTask()
        }))
        .onAppear {
            loadTaskValues()
        }.onChange(of: task.completed) { completed in
            completionDate = completed ? Date() : nil
        }
    }
    
    //MARK: loadTaskValues
    private func loadTaskValues() {
        
        taskTitle = task.title
        taskDescription = task.text ?? taskDescription
        dueDate = task.due ?? dueDate
        hasDueDate = task.due != nil
        lesson = task.lesson
        hasLessonAttached = lesson != nil
        isArchived = task.archived
        isCompleted = task.completed
        completionDate = task.completionDate
        
        task.getNotifications { (notifications) in
            sendNotification = notifications.count != 0
            if sendNotification, let not = notifications.first {
                if let date = (not.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate() {
                    let notificationOffset = NotificationOffset.from(dueDate: dueDate, notificationDate: date)
                    
                    if notificationOffset != self.notificationOffset {
                        self.notificationOffset = notificationOffset
                    }
                }
            }
        }
        
    }
    
    //MARK: titleForLessonCell
    private func titleForLessonCell() -> String {
        return task.lesson?.subject?.name ?? "Choose a lesson"
    }
    
    //MARK: textForLessonDate
    private func textForLessonDate() -> String {
        guard let lesson = self.task.lesson else {
            return ""
        }
        
//        return "\(lesson.day.shortString()) \u{2022} \(lesson.startTime.string() ?? "") - \(lesson.endTime.string() ?? "")"
        return "\(lesson.day.shortString()) \n \(lesson.startTime.string() ?? "") - \(lesson.endTime.string() ?? "")"
    }
    
    //MARK: foregroundColorForLessonCell
    private func foregroundColorForLessonCell() -> Color {
        return task.lesson?.subject?.name != nil ? Color(.label) : Color(.systemBlue)
    }
    
    //MARK: textForNotificationCell
    private func textForNotificationCell() -> String {
        if !sendNotification {
            return ""
        }
        
        guard let notificationOffset = notificationOffset else {
            return ""
        }
        
        return (dueDate - notificationOffset.timeInterval).stringify(dateStyle: .short, timeStyle: .short)
    }
    
    //MARK: subjectColor
    private func subjectColor(_ lesson: Lesson?) -> Color {
        return Color(UIColor(lesson) ?? .clear)
    }
    
    //MARK: lessonTime
    private func lessonTime(_ lesson: Lesson?) -> String {
        return "\(lesson?.startTime.string() ?? "") - \(lesson?.endTime.string() ?? "")"
    }
    
    //MARK: cancel
    private func cancel() {
        dismiss()
        presentationMode.wrappedValue.dismiss()
    }
    
    //MARK: hasUnsavedChanges
    private func hasUnsavedChanges() -> Bool {
        return
            (task.title != taskTitle) ||
            (task.text != taskDescription) ||
            (task.due != dueDate) ||
            (task.lesson != lesson) ||
            (task.archived != isArchived) ||
            (task.completed != isCompleted) ||
            (task.lesson != nil && !hasLessonAttached) ||
            (task.due != nil && !hasDueDate)
    }
    
    //MARK: saveTask
    private func saveTask(dismiss: Bool = true) {
        if sendNotification {
            task.getNotifications { (notifications) in
                guard let notificationOffset = notificationOffset else {
                    return
                }
                NotificationService.current.scheduleDueDateNotification(for: task, notificationOffset)
                NotificationService.current.removeAllNotifications(of: task)
            }
        }else {
            NotificationService.current.removeAllNotifications(of: task)
        }
        
        task.text = taskDescription
        task.due = hasDueDate ? dueDate : nil
        task.lesson = hasLessonAttached ? lesson : nil
        
        TimetableService.shared.save()
        
        if dismiss {
            self.dismiss()
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    //MARK: deleteTask
    private func deleteTask() {
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
