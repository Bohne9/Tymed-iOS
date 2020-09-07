//
//  TimetableAddView.swift
//  Tymed
//
//  Created by Jonah Schueller on 29.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

struct TimetableAddView: View {
    
    @Environment(\.presentationMode)
    var presentationMode
    
    @State
    private var timetableName: String = ""
    
    @State
    private var isNewDefault = {
        return !(TimetableService.shared.defaultTimetable() != nil)
    }()
    
    @State
    private var subjects: [Subject] = []
    
    @State
    private var shouldSave = false
    
    var body: some View {
        NavigationView {
            List {
                
                Section(header: Text("Name")) {
                    TextField("Name", text: $timetableName)
                }
                
                Section {
                    HStack {
                        DetailCellDescriptor("Make default timetable", image: "circlebadge.fill", .systemGreen)
                        
                        Toggle("", isOn: $isNewDefault)
                            .labelsHidden()
                    }
                }
                
                Text("Quick setup")
                
                //MARK: Subjects
                ForEach(subjects) { subject in
                    
                    Section {
                        VStack {
                            HStack(alignment: .top) {
                                
                                Image(systemName: "plus.square.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color(.secondaryLabel))
                                
                                Text("Subject")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(Color(.secondaryLabel))
                                
                                Spacer()
                                
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(Color(.systemGray))
                                    .font(.system(size: 20, weight: .semibold))
                                    .onTapGesture {
                                        withAnimation {
                                            subjects.removeAll { (sub) -> Bool in
                                                sub.id == subject.id
                                            }
                                            TimetableService.shared.deleteSubject(subject)
                                        }
                                    }
                            }.frame(height: 30)
                            
                            SubjectAddSection(subject: subject)
                        }
                    }
                    
                }
                
                //MARK: Add subject
                Section {
                    HStack {
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                addSubject()
                            }
                        } label: {
                            VStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Color(.systemBlue))
                                    .font(.system(size: 20, weight: .semibold))
                                    .padding(.bottom, 4)
                                Text("Add subject")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                                                        
                        }

                        Spacer()
                        
                    }.padding(.vertical, 4)
                }
                
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Cancel")
            }), trailing: Button(action: {
                shouldSave = true
                addTimetable()
            }, label: {
                Text("Add")
            }))
            .navigationTitle("Timetable")
            .onDisappear() {
                discardChanges()
            }
        }
    }
    
    private func addTimetable() {
        let timetable = TimetableService.shared.timetable()
        
        timetable.name = timetableName
        
        subjects.forEach { (subject) in
            subject.timetable = timetable
        }
        
        if isNewDefault {
            TimetableService.shared.setDefaultTimetable(timetable)
        }else {
            timetable.isDefault = false
        }
        
        TimetableService.shared.save()
        
        presentationMode.wrappedValue.dismiss()
    }
 
    private func addSubject() {
        
        let subject = TimetableService.shared.subject()
        
        subject.name = ""
        subject.color = "blue"
        
        subjects.append(subject)
    }

    /// In case the user hits the "Cancel" button or dismisses the view by swiping down all the created core data objects must be deleted.
    private func discardChanges() {
        if !shouldSave {
            subjects.forEach { (subject) in
                TimetableService.shared.deleteSubject(subject)
            }
        }
    }
}

//MARK: SubjectAddSection
struct SubjectAddSection: View {
    
    @ObservedObject
    var subject: Subject
    
    var body: some View {
        VStack {
            HStack {
                
                TextField("Subject Name", text: $subject.name)
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
                
                Picker("", selection: $subject.color) {
                    ForEach(colors(), id: \.self) { color in
                        Rectangle()
                            .frame(width: 25, height: 25)
                            .foregroundColor(Color(UIColor(named: color)!))
                            .cornerRadius(5)
                    }
                }.labelsHidden()
                .pickerStyle(InlinePickerStyle())
                .frame(width: 30, height: 40)
                .padding(4)
                .clipped()
                .contentShape(RoundedRectangle(cornerRadius: 5))
            }
            
            Divider()
            
            ForEach(lessons()) { lesson in
                VStack {
                    LessonAddRow(lesson: lesson)
                        .background(Color(.secondarySystemGroupedBackground))
                
                    Divider()
                }
            }.background(Color(.secondarySystemGroupedBackground))
            
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(Color(.systemGreen))
                    .font(.system(size: 20, weight: .semibold))
                Text("Add lesson")
                Spacer()
            }.contentShape(Rectangle())
            .frame(height: 40)
            .padding(.bottom, 5)
            .onTapGesture {
                withAnimation {
                    addLesson()
                }
            }
            
        }
    }
    
    private func colors() -> [String] {
        return ["red", "blue", "orange", "green", "dark"]
    }
    
    private func lessons() -> [Lesson] {
        return subject.lessons?.allObjects as? [Lesson] ?? []
    }
    
    private func addLesson() {
        let lesson = TimetableService.shared.lesson()
        
        lesson.subject = subject
        lesson.day = Day.current
        lesson.startTime = Time(from: Date())
        lesson.endTime = Time(from: Date() + 3600)
    }
}

//MARK: LessonAddRow
struct LessonAddRow: View {
    
    @ObservedObject
    var lesson: Lesson
    
    var body: some View {
        
        NavigationLink(destination: LessonEditContentView(lesson: lesson, dismiss: {
            
        }).navigationBarItems(leading: EmptyView())) {
            HStack {
                
                Text(lesson.day.string())
                
                Spacer()
                
                Text(textForTime())
                
            }.font(.system(size: 17, weight: .semibold))
            .cornerRadius(5)
            .frame(height: 40)
        }
        
    }
    
    private func textForTime() -> String {
        return "\(lesson.startTime.string() ?? "-") - \(lesson.endTime.string() ?? "-")"
    }
}

struct TimetableAddView_Previews: PreviewProvider {
    static var previews: some View {
        TimetableAddView()
    }
}
