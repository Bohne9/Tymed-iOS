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
    
    var taskDelegate: HomeTaskDetailDelegate?
    
    var task: Task?
    
    var contentView: UIHostingController<TaskEditView>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let task = task else {
            return
        }
        
        let taskEditView = TaskEditView(task: task,
                                        dismiss: {
                                            self.taskDelegate?.reload()
                                            self.dismiss(animated: true, completion: nil)
                                        })
        
        contentView = UIHostingController(rootView: taskEditView)
        
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
    
    @State var task: Task
    
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var showDismissWarning = false
    
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
    
    @State var notificationOffset: NotificationOffset = NotificationOffset.atDueDate
    
    //MARK: Lesson state
    @State private var hasLessonAttached = false
    
    @State private var presentLessonPicker = false
    
    @State private var lesson: Lesson?
    
    //MARK: Archive state
    @State var isArchived: Bool = false
    
    //MARK: Delete state
    @State var showDeleteAction = false
    
    var dismiss: () -> Void
    
    var body: some View {
        NavigationView {
            List {
                
                //MARK: Title
                Section {
                    TextField("Title", text: $taskTitle)
                    TextField("Description", text: $taskDescription).lineLimit(-1)
                }
                
                //MARK: Complete
                Section {
                    HStack {
                        DetailCellDescriptor("Completed", image: completeIcon(), completeColor(), value: completionDate?.stringify(dateStyle: .short, timeStyle: .short))
                            .animation(.easeOut)
                        
                        Toggle("", isOn: $isCompleted)
                    }.frame(height: 45)
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
                        //MARK: Notification
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
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                        
                                }.contentShape(Rectangle())
                                .frame(height: 45)
                            }).frame(height: 45)
                    }
                }
                //MARK: Archive
                Section {
                    HStack {
                        ZStack {
                            Color(.systemOrange)
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
                            Color(.systemRed)
                            Image(systemName: "trash.fill")
                                .font(.system(size: 15, weight: .bold))
                        }.cornerRadius(6).frame(width: 28, height: 28)
                        
                        Text("Delete")
                        
                        Spacer()
                        
                    }.frame(height: 45)
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
            .navigationBarItems(leading: Button("Cancel", action: {
                if hasUnsavedChanges() {
                    showDismissWarning.toggle()
                    return
                }
                
                cancel()
            }), trailing: Button("Done", action: {
                saveTask()
            }))
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
            }
        }.onAppear {
            loadTaskValues()
        }.onChange(of: isCompleted) { completed in
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
        }
        
    }
    
    private func completeIcon() -> String {
        if isCompleted {
            return "checkmark.circle"
        }else {
            if Date() < dueDate {
                return "circle"
            }else {
                return "exclamationmark.circle.fill"
            }
        }
    }
    
    private func completeColor() -> UIColor {
        if isCompleted {
            if completionDate ?? Date() <= dueDate || !hasDueDate {
                return .systemGreen
            }else {
                return .systemOrange
            }
        }else {
            if Date() <= dueDate || !hasDueDate {
                return .systemBlue
            }else {
                return .systemRed
            }
        }
    }
    
    //MARK: titleForLessonCell
    private func titleForLessonCell() -> String {
        return lesson?.subject?.name ?? "Choose a lesson"
    }
    
    //MARK: textForLessonDate
    private func textForLessonDate() -> String {
        guard let lesson = self.lesson else {
            return ""
        }
        
        return "\(lesson.day.shortString()) \u{2022} \(lesson.startTime.string() ?? "") - \(lesson.endTime.string() ?? "")"
    }
    
    //MARK: foregroundColorForLessonCell
    private func foregroundColorForLessonCell() -> Color {
        return lesson?.subject?.name != nil ? Color(.label) : Color(.systemBlue)
    }
    
    //MARK: textForNotificationCell
    private func textForNotificationCell() -> String {
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
    private func saveTask() {
        
        task.title = taskTitle
        task.text = taskDescription
        task.due = hasDueDate ? dueDate : nil
        task.lesson = hasLessonAttached ? lesson : nil
        task.priority = 0
        task.archived = isArchived
        task.completed = isCompleted
        task.completionDate = completionDate
        
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
