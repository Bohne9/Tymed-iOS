//
//  TaskEditView.swift
//  Tymed
//
//  Created by Jonah Schueller on 02.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI
import CoreData

//MARK: TaskEditView
struct TaskEditView: View {
    
    @ObservedObject var reminder: ReminderViewModel
    
    var dismiss: () -> Void
    
    var body: some View {
        NavigationView {
            TaskEditContent(reminder: reminder, dismiss: dismiss)
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
    
    @ObservedObject var reminder: ReminderViewModel
    
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
    
    //MARK: Timetable
    @State private var timetable: Timetable? = TimetableService.shared.defaultTimetable()
    
    @State var notificationOffset: NotificationOffset?
    
    //MARK: Lesson state
    @State private var hasLessonAttached = false
    
    @State private var presentLessonPicker = false
    
    @State private var lesson: Lesson?
    
    //MARK: Archive state
    @State var isArchived: Bool = false
    
    @State var showDismissWarning = false
    
    //MARK: Notes
    @State var showNotesKeyboardResign = false
    
    //MARK: Delete state
    @State var showDeleteAction = false
    
    var dismiss: () -> Void
    
    var body: some View {
        List {
            
            //MARK: Title
            Section {
                TextField("Title", text: $reminder.title)
            }
            
            //MARK: Complete
            Section {
                HStack {
                    DetailCellDescriptor("Completed",
                                         image: reminder.iconForCompletion(),
                                         reminder.completeColor(),
                                         value: reminder.completionDate?.stringify(
                                            dateStyle: .short,
                                            timeStyle: .short))
                        .animation(.easeOut)
                    
                    Toggle("", isOn: $reminder.isCompleted)
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
            
            Section(header: HStack {
                Label("Notes", systemImage: "note.text")
                    .font(.system(size: 12, weight: .semibold))
                Spacer()
                if showNotesKeyboardResign {
                    #if canImport(UIKit) // Just to make sure UIKit is available
                    Button("Done") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        showNotesKeyboardResign = false
                    }.foregroundColor(Color(.systemBlue))
                    .font(.system(size: 12, weight: .semibold))
                    #endif
                }
            }) {
                TextEditor(text: Binding($reminder.notes, ""))
                    .onTapGesture {
                        showNotesKeyboardResign = true
                    }.frame(minHeight: 100)
            }
            
            //MARK: Calendar
            
            Section {
                HStack {
                    
                    NavigationLink(destination: CalendarPicker(calendar: $reminder.calendar)) {
                        DetailCellDescriptor("Calendar", image: "tray.full.fill", UIColor(cgColor: reminder.calendar.cgColor), value: timetableTitle())
                        Spacer()
                    }
                    
                }
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
        }.onChange(of: reminder.isCompleted) { completed in
            completionDate = completed ? Date() : nil
        }
    }
    
    //MARK: loadTaskValues
    private func loadTaskValues() {
        
        taskTitle = reminder.title
        dueDate = reminder.dueDate() ?? dueDate
        hasDueDate = reminder.dueDate() != nil
        hasLessonAttached = lesson != nil
        isCompleted = reminder.isCompleted
        completionDate = reminder.completionDate
        
        /*
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
        */
    }
    
    //MARK: timetableTitle
    private func timetableTitle() -> String? {
        return reminder.calendar.title
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
        return reminder.hasChanges
    }
    
    //MARK: saveTask
    private func saveTask(dismiss: Bool = true) {
        
        /*
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
        */
 
        ReminderService.shared.save(reminder.reminder)
        
        if dismiss {
            self.dismiss()
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    //MARK: deleteTask
    private func deleteTask() {
        ReminderService.shared.deleteReminder(reminder.reminder)
        
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
