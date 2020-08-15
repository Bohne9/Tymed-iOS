//
//  SubjectEditView.swift
//  Tymed
//
//  Created by Jonah Schueller on 14.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

struct SubjectEditView: View {

    @Environment(\.presentationMode)
    var presentationMode
    
    @ObservedObject
    var subject: Subject
    
    @State
    private var showDeleteAlert = false
    
    var body: some View {
        List {
            
            Section {
                TextField("Name", text: $subject.name)
                    .font(.system(size: 16, weight: .semibold))
                    .frame(height: 45)
            }
            
            Section {
                NavigationLink(destination: AppColorPickerView(color: $subject.color)) {
                    DetailCellDescriptor("Color", image: "paintbrush", UIColor(subject) ?? .clear, value: subject.color.capitalized)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            
            Section(header: Text("Lessons")) {
                
                ForEach(lessons()) { lesson in
                    NavigationLink(destination: LessonEditContentView(lesson: lesson, dismiss: {
                        
                    }).navigationBarItems(trailing: EmptyView())
                    ) {
                        HStack {
                            Text(textForDay(of: lesson))
                            Spacer()
                            Text(textForTime(of: lesson))
                        }.font(.system(size: 14, weight: .semibold))
                        .frame(height: 45)
                    }
                }.onDelete { (indexSet) in
                    deleteLessons(indexSet)
                }
                
            }
            
            Section {
                DetailCellDescriptor("Delete", image: "trash", .systemRed)
                    .font(.system(size: 16, weight: .semibold))
                    .onTapGesture {
                        showDeleteAlert.toggle()
                    }
            }
            
        }.listStyle(InsetGroupedListStyle())
        .navigationTitle("Subject")
        .actionSheet(isPresented: $showDeleteAlert) {
            ActionSheet(
                title: Text("Are you sure?"),
                message: Text("You cannot undo this."),
                buttons: [.destructive(Text("Delete"), action: {
                    deleteSubject()
                }), .cancel()])
        }
    }
    
    func deleteLessons(_ indexSet: IndexSet) {
        indexSet.forEach { (index) in
            guard let lesson = subject.lessons?.allObjects[index] as? Lesson else {
                return
            }
            TimetableService.shared.deleteLesson(lesson)
        }
    }
    
    func deleteSubject() {
        TimetableService.shared.deleteSubject(subject)
        presentationMode.wrappedValue.dismiss()
    }
    
    func lessons() -> [Lesson] {
        return (subject.lessons?.allObjects as? [Lesson] ?? []).sorted { (lhs, rhs) -> Bool in
            if lhs.day != rhs.day {
                return lhs.day < rhs.day
            }
            if lhs.startTime != rhs.startTime {
                return lhs.startTime < rhs.startTime
            }
            return lhs.endTime < rhs.endTime
        }
    }
    
    func textForDay(of lesson: Lesson) -> String {
        return "\(lesson.day.string())"
    }
    
    func textForTime(of lesson: Lesson) -> String {
        return "\(lesson.startTime.string() ?? "") - \(lesson.endTime.string() ?? "")"
    }
}
