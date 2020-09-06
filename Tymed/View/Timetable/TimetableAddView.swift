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
        subject.color = "blue"
        
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
            
//            List {
                ForEach(lessons()) { lesson in
                    VStack {
                        HStack {
                            
                            ZStack {
                                
                            }
                            
                            Image(systemName: "trash")
                            LessonAddRow(lesson: lesson)
//                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                .background(Color(.secondarySystemGroupedBackground))
                        }
                        
                        Divider()
                    }
                }.background(Color(.secondarySystemGroupedBackground))
//            }
//            .frame(height: CGFloat(lessons().count) * 110)
//            .listStyle(DefaultListStyle())
//            .background(Color(.secondarySystemGroupedBackground))
            
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
    private var endDate: Date = Date() + 3600
    
    var body: some View {
        VStack {
        
            Picker("", selection: $day) {
                ForEach(Day.allCases, id: \.rawValue) { day in
                    Text(day.string())
                }
            }
            .labelsHidden()
            .pickerStyle(WheelPickerStyle())
            .frame(height: 45)
            .clipped()
            .padding(4)
            
            HStack {
                
                DatePicker("", selection: $startDate, displayedComponents: .hourAndMinute)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .labelsHidden()
                
                Text(":")
                
                DatePicker("", selection: $endDate, displayedComponents: .hourAndMinute)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .labelsHidden()
            }
            
        }.frame(height: 110)
        .onChange(of: day) { (value) in
            lesson.dayOfWeek = day
        }.onChange(of: startDate) { (value) in
            lesson.startTime = Time(from: startDate)
        }.onChange(of: endDate) { (value) in
            lesson.endTime = Time(from: endDate)
        }
    }
}

struct TimetableAddView_Previews: PreviewProvider {
    static var previews: some View {
        TimetableAddView()
    }
}
