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
    private var isNewDefault = false
    
    @State
    private var subjects: [Subject] = []
    
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
                                    .foregroundColor(.white)
                                
                                Text("Subject")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(Color(.systemGray))
                                
                                Spacer()
                                
                                Button {
                                    withAnimation {
                                        subjects.removeAll { (sub) -> Bool in
                                            sub.id == subject.id
                                        }
                                        TimetableService.shared.deleteSubject(subject)
                                    }
                                } label: {
                                    Image(systemName: "multiply.circle.fill")
                                        .foregroundColor(Color(.systemGray))
                                        .font(.system(size: 20, weight: .semibold))
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
                addTimetable()
            }, label: {
                Text("Add")
            }))
            .navigationTitle("Timetable")
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
        subject.color = "red"
        
        subjects.append(subject)
    }
}

//MARK: SubjectAddSection
struct SubjectAddSection: View {
    
    @ObservedObject
    var subject: Subject
    
    var body: some View {
        VStack {
            HStack {
                
                TextField("Name", text: $subject.name)
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
                .frame(width: 30, height: 30)
                .padding(4)
                .clipped()
                .contentShape(RoundedRectangle(cornerRadius: 5))
            }
            
            Divider()
            
            ForEach(lessons()) { lesson in
                LessonAddRow(lesson: lesson)
                Divider()
            }
            
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
    }
}

//MARK: LessonAddRow
struct LessonAddRow: View {
    
    @ObservedObject
    var lesson: Lesson
    
    @State
    private var day: Int32 = 1
    
    @State
    private var startDate: Date = Date()
    
    @State
    private var endDate: Date = Date()
    
    var body: some View {
        HStack(spacing: 0) {
            
            Picker("", selection: $day) {
                ForEach(Day.allCases, id: \.rawValue) { day in
                    Text(day.string())
                }
            }
            .labelsHidden()
            .pickerStyle(WheelPickerStyle())
            .frame(maxWidth: 130)
            .padding(4)
            .clipped()
            .contentShape(RoundedRectangle(cornerRadius: 5))
            
            Spacer()
            
            HStack {
                
                Spacer()
                
                DatePicker("", selection: $startDate, displayedComponents: .hourAndMinute)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .labelsHidden()
                
                Text(":")
                
                DatePicker("", selection: $endDate, displayedComponents: .hourAndMinute)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .labelsHidden()
            }
            
        }
    }
}

struct TimetableAddView_Previews: PreviewProvider {
    static var previews: some View {
        TimetableAddView()
    }
}
