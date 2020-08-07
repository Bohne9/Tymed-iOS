//
//  LessonPickerView.swift
//  Tymed
//
//  Created by Jonah Schueller on 07.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI


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
