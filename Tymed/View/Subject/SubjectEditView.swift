//
//  SubjectEditView.swift
//  Tymed
//
//  Created by Jonah Schueller on 14.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

struct SubjectEditView: View {
    
    @ObservedObject
    var subject: Subject
    
    var body: some View {
        List {
            
            Section {
                TextField("Name", text: $subject.name)
                    .font(.system(size: 16, weight: .semibold))
                    .frame(height: 45)
            }
            
            Section {
                NavigationLink(destination: AppColorPickerView(color: $subject.color)) {
                    DetailCellDescriptor("Color", image: "paintbrush", UIColor(subject) ?? .clear, value: subject.color.uppercased())
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            
            Section(header: Text("Lessons")) {
                
                ForEach(lessons()) { lesson in
                    NavigationLink(destination: LessonEditView(lesson: lesson, dismiss: {
                        
                    })) {
                        HStack {
                            Text(textForDay(of: lesson))
                            Spacer()
                            Text(textForTime(of: lesson))
                        }.font(.system(size: 14, weight: .semibold))
                        .frame(height: 45)
                    }
                }
                
            }
            
            Section {
                DetailCellDescriptor("Delete", image: "trash", .systemRed)
                    .font(.system(size: 16, weight: .semibold))
            }
            
        }.listStyle(InsetGroupedListStyle())
        .navigationTitle("Subject")
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
