//
//  LesonEditView.swift
//  Tymed
//
//  Created by Jonah Schueller on 05.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

class LessonEditViewWrapper: UIViewController {
    
    var lessonDelegate: HomeDetailTableViewControllerDelegate?
    var lesson: Lesson?
    
    var contentView: UIHostingController<LessonEditView>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let lesson = lesson else {
            return
        }
        
        contentView = UIHostingController(rootView: LessonEditView(
                                                                lesson: lesson,
                                                                dismiss: {
                                                                    self.lessonDelegate?.detailWillDismiss()
                                                                    self.dismiss(animated: true, completion: nil)
                    }))
        
        addChild(contentView)
        view.addSubview(contentView.view)
        
        setupConstraints()
    }
    
    fileprivate func setupConstraints() {
        contentView.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.view.constraintToSuperview()
    }
}

//MARK: LessonEditView
struct LessonEditView: View {
    
    @State var lesson: Lesson
    
    var dismiss: () -> Void
    
    //MARK: Lesson Subject Title
    @State private var subjectTitle = ""
    
    //MARK: Lesson Time state
    @State private var showSubjectSuggestions = false
    
    @State private var showStartTimePicker = false
    @State private var showEndTimePicker = false
    @State private var showDayPicker = false
    
    @State private var startTime = Date()
    @State private var endTime = Date() + TimeInterval(3600)
    @State private var interval: TimeInterval = 3600
    
    @State private var day: Day = .current
    
    //MARK: Color
    @State private var color: String = "blue"
    
    //MARK: Note
    @State private var note = ""
    
    //MARK: Timetable
    @State private var timetable: Timetable? = TimetableService.shared.defaultTimetable()
    
    
    @State private var subjectTimetableAlert = false
    
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    if showSubjectSuggestions {
                        
                        HStack(spacing: 15) {
                            ForEach(subjectSuggestions(), id: \.self) { (subject: Subject) in
                                HStack {
                                    Spacer()
                                    Text(subject.name ?? "")
                                        .minimumScaleFactor(0.01)
                                        .lineLimit(1)
                                        .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
                                    
                                    Spacer()
                                }
                                .frame(height: 30)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .background(Color(UIColor(subject) ?? .clear))
                                .cornerRadius(10.5)
                                .onTapGesture {
                                    selectSubjectTitle(subject)
                                }
                            }
                        }.frame(height: 45)
                        .animation(.easeInOut(duration: 0.5))
                        
                    }
                    
                    CustomTextField("Subject Name", $subjectTitle) {
                        withAnimation {
                            showSubjectSuggestions.toggle()
                        }
                    } onReturn: {
                        withAnimation {
                            showSubjectSuggestions.toggle()
                        }
                    }
                    
                    NavigationLink(destination: AppColorPickerView(color: $color)) {
                        DetailCellDescriptor("Color", image: "paintbrush.fill", UIColor(named: color) ?? .clear, value: color.capitalized)
                    }
                        
                }
                
                if lesson.tasks?.count ?? 0 > 0 {
                    Section {
                        ForEach(lessonTasks(), id: \.self) { task in
                            Text(task.title)
                        }
                    }
                }
                
                //MARK: Times
                Section {
                    DetailCellDescriptor("Start time", image: "clock.fill", .systemBlue, value: time(for: startTime))
                        .onTapGesture {
                            withAnimation {
                                showStartTimePicker.toggle()
                                showEndTimePicker = false
                                showDayPicker = false
                            }
                        }
                    
                    if showStartTimePicker {
                        HStack {
                            Spacer()
                            DatePicker("", selection: $startTime, displayedComponents: DatePickerComponents.hourAndMinute)
                                .labelsHidden()
                                .datePickerStyle(GraphicalDatePickerStyle())
                        }.frame(height: 45)
                    }
                    
                    DetailCellDescriptor("End time", image: "clock.fill", .systemOrange, value: time(for: endTime))
                        .onTapGesture {
                            withAnimation {
                                showEndTimePicker.toggle()
                                showStartTimePicker = false
                                showDayPicker = false
                            }
                        }
                    
                    if showEndTimePicker {
                        HStack {
                            Spacer()
                            DatePicker("", selection: $endTime, in: startTime..., displayedComponents: DatePickerComponents.hourAndMinute)
                                .labelsHidden()
                                .datePickerStyle(GraphicalDatePickerStyle())
                        }.frame(height: 45)
                    }
                    
                    
                    DetailCellDescriptor("Day", image: "calendar", .systemGreen, value: day.string())
                        .onTapGesture {
                            withAnimation {
                                showDayPicker.toggle()
                                showStartTimePicker = false
                                showEndTimePicker = false
                            }
                        }
                    
                    if showDayPicker {
                        Picker("", selection: $day) {
                            ForEach(Day.allCases, id: \.self) { day in
                                Text(day.string())
                            }
                        }.pickerStyle(WheelPickerStyle())
                        .frame(height: 120)
                    }
                }
                
                
                //MARK: Timetable
                
                Section {
                    HStack {
                        
                        NavigationLink(destination: AppTimetablePicker(timetable: $timetable)) {
                            DetailCellDescriptor("Timetable", image: "tray.full.fill", .systemRed, value: timetableTitle())
                            Spacer()
                            if timetable == TimetableService.shared.defaultTimetable() {
                                Text("Default")
                                    .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                                    .background(Color(.tertiarySystemGroupedBackground))
                                    .font(.system(size: 13, weight: .semibold))
                                    .cornerRadius(10)
                            }
                        }
                        
                    }
                }
                
                //MARK: Notes
                Section {
                    MultilineTextField("Notes", $note)
                }
                
                Section {
                    DetailCellDescriptor("Delete", image: "trash.fill", .systemRed)
                        .onTapGesture {
                            deleteLesson()
                        }
                }
                
            }.listStyle(InsetGroupedListStyle())
            .font(.system(size: 16, weight: .semibold))
            .navigationTitle("Lesson")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel"){
                dismiss()
            }, trailing: Button("Done") {
                saveLesson()
            })
            .onChange(of: endTime) { value in
                interval = endTime.timeIntervalSince(startTime)
            }
            .onChange(of: startTime) { value in
                endTime = startTime + interval
            }
            .alert(isPresented: $subjectTimetableAlert) {
                Alert(
                    title: Text("Do you want to switch timetables?"),
                    message: Text("All other lessons of the subject will change the timetables aswell."),
                    primaryButton:
                        .destructive(Text("Use \(timetable?.name ?? "")"),
                                     action: {
                                        saveLesson()
                }), secondaryButton:
                        .cancel(Text("Keep \(timetableNameOfSubject())"),
                                action: {
                                    timetable = TimetableService.shared.subject(with: subjectTitle)?.timetable
                                    saveLesson()
                    }))
            }
        }.onAppear(perform: loadLessonValues)
        .onDisappear {
            saveLesson()
        }
    }
    
    private func loadLessonValues() {
        if let subject = lesson.subject {
            selectSubjectTitle(subject)
            timetable = subject.timetable
            color = subject.color ?? "blue"
        }
        
        startTime = lesson.startTime.date ?? Date()
        endTime = lesson.endTime.date ?? Date()
        day = lesson.day
        note = lesson.note ?? ""
    }
    
    private func lessonTasks() -> [Task] {
        return (lesson.tasks?.allObjects as? [Task] ?? []).filter { !$0.archived }
    }
    
    private func selectSubjectTitle(_ subject: Subject) {
        subjectTitle = subject.name ?? ""
        let subject = TimetableService.shared.subject(with: subjectTitle)
        timetable = subject?.timetable
        color = subject?.color ?? "blue"
    }
    
    //MARK: timetableNameOfSubject
    private func timetableNameOfSubject() -> String {
        return TimetableService.shared.subject(with: subjectTitle, addNewSubjectIfNull: false)?.timetable?.name ?? ""
    }
    
    //MARK: timetableTitle
    private func timetableTitle() -> String? {
        return timetable?.name
    }
    
    //MARK: time
    private func time(for date: Date) -> String? {
        return date.stringifyTime(with: .short)
    }
    
    //MARK: subjectSuggestions
    private func subjectSuggestions() -> [Subject] {
        return TimetableService.shared.subjectSuggestions(for: subjectTitle)
            .prefix(3)
            .map { $0 }
    }
    
    //MARK: saveLesson
    private func saveLesson() {
        guard let subject = TimetableService.shared.subject(with: subjectTitle) else {
            return
        }
        
        if subject.timetable != timetable {
            subjectTimetableAlert.toggle()
            return
        }
        
        subject.timetable = timetable
        subject.color = color
        subject.name = subjectTitle
        
        lesson.subject = subject
        
        lesson.startTime = Time(from: startTime)
        lesson.endTime = Time(from: endTime)
        lesson.dayOfWeek = Int32(day.rawValue)
        lesson.note = note
        
        
        TimetableService.shared.save()
        
        dismiss()
    }
    
    //MARK: deleteLesson
    private func deleteLesson() {
        print("Delete not implemented")
    }
}


