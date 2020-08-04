//
//  LessonAddView.swift
//  Tymed
//
//  Created by Jonah Schueller on 03.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

class LessonAddViewWrapper: UIViewController {
    
    lazy var contentView = UIHostingController(rootView: LessonAddView(dismiss: {
        self.dismiss(animated: true, completion: nil)
    }))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(contentView)
        view.addSubview(contentView.view)
        
        setupConstraints()
    }
    
    fileprivate func setupConstraints() {
        contentView.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.view.constraintToSuperview()
    }
}

struct LessonAddCellDescriptor: View {
    
    var image: String
    var title: String
    var color: UIColor
    
    var value: String?
    
    init(_ title: String, image: String, _ color: UIColor, value: String? = nil) {
        self.title = title
        self.image = image
        self.color = color
        self.value = value
    }
    
    var body: some View {
        HStack {
            ZStack {
                Color(color)
                Image(systemName: image)
                    .font(.system(size: 15, weight: .bold))
            }.cornerRadius(6).frame(width: 28, height: 28)
            
            VStack(alignment: .leading) {
                Text(title)
                if let value = self.value {
                    Text(value)
                        .foregroundColor(Color(.systemBlue))
                        .font(.system(size: 12, weight: .semibold))
                }
            }
            
            Spacer()
        }.frame(height: 45).contentShape(Rectangle())
    }
    
}

//MARK: LessonAddView
struct LessonAddView: View {
    
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
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .background(Color(UIColor(subject) ?? .clear))
                                .cornerRadius(5.0)
                                .onTapGesture {
                                    subjectTitle = subject.name ?? ""
                                    let subject = TimetableService.shared.subject(with: subjectTitle)
                                    timetable = subject?.timetable
                                    color = subject?.color ?? "blue"
                                }
                            }
                        }.animation(.easeInOut(duration: 0.5))
                        
                    }
                    
                    SubjectTitleTextField("Subject Name", $subjectTitle) {
                        withAnimation {
                            showSubjectSuggestions.toggle()
                        }
                    } onReturn: {
                        withAnimation {
                            showSubjectSuggestions.toggle()
                        }
                    }
                    
                    NavigationLink(destination: LessonAddColorPickerView(color: $color)) {
                        LessonAddCellDescriptor("Color", image: "paintbrush.fill", UIColor(named: color) ?? .clear, value: color.capitalized)
                    }
                        
                }
                
                //MARK: Times
                Section {
                    LessonAddCellDescriptor("Start time", image: "clock.fill", .systemBlue, value: time(for: startTime))
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
                    
                    LessonAddCellDescriptor("End time", image: "clock.fill", .systemOrange, value: time(for: endTime))
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
                    
                    
                    LessonAddCellDescriptor("Day", image: "calendar", .systemGreen, value: day.string())
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
                        
                        NavigationLink(destination: LessonAddTimetablePicker(timetable: $timetable)) {
                            LessonAddCellDescriptor("Timetable", image: "tray.full.fill", .systemRed, value: timetableTitle())
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
                
                Section {
                    TextField("Notes", text: $note)
                }
                
            }.listStyle(InsetGroupedListStyle())
            .navigationTitle("Lesson")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel"){
                dismiss()
            }, trailing: Button("Add") {
                addLesson()
            })
            .onChange(of: endTime) { value in
                interval = endTime.timeIntervalSince(startTime)
                print(interval)
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
                                        addLesson()
                }), secondaryButton:
                        .cancel(Text("Keep \(timetableNameOfSubject())"),
                                action: {
                                    timetable = TimetableService.shared.subject(with: subjectTitle)?.timetable
                                    addLesson()
                    }))
            }
        }
    }
    
    private func timetableNameOfSubject() -> String {
        return TimetableService.shared.subject(with: subjectTitle, addNewSubjectIfNull: false)?.timetable?.name ?? ""
    }
    
    private func timetableTitle() -> String? {
        return timetable?.name
    }
    
    private func time(for date: Date) -> String? {
        return date.stringifyTime(with: .short)
    }
    
    private func subjectSuggestions() -> [Subject] {
        return TimetableService.shared.subjectSuggestions(for: subjectTitle)
            .prefix(3)
            .map { $0 }
    }
    
    
    private func addLesson() {
        guard let subject = TimetableService.shared.subject(with: subjectTitle) else {
            return
        }
        
        if subject.timetable != timetable {
            subjectTimetableAlert.toggle()
            return
        }
        
        subject.timetable = timetable
        subject.color = color
        
        _ = TimetableService.shared.addLesson(subject: subject, day: day, start: startTime, end: endTime, note: nil)
        
        dismiss()
    }
    
    
}

struct LessonAddTimetablePicker: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding
    var timetable: Timetable?
    
    var body: some View {
        List {
            ForEach(timetables(), id: \.self) { timetable in
                HStack {
                    Text(timetable?.name ?? "")
                        
                    Spacer()
                    
                    if timetable == TimetableService.shared.defaultTimetable() {
                        Text("Default")
                            .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                            .background(Color(.tertiarySystemGroupedBackground))
                            .font(.system(size: 13, weight: .semibold))
                            .cornerRadius(10)
                    }
                    
                    if self.timetable == timetable {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color(.systemBlue))
                    }
                }.contentShape(Rectangle())
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()
                    self.timetable = timetable
                    
                }
            }
        }.listStyle(InsetGroupedListStyle())
        .navigationTitle("Timetable")
    }
    
    private func timetables() -> [Timetable?] {
        return TimetableService.shared.fetchTimetables() ?? []
    }
}

//MARK: ColorPickerView
struct LessonAddColorPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding
    var color: String
    
    var body: some View {
        List {
            ForEach(colors(), id: \.self) { color in
                HStack {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(Color(UIColor(named: color) ?? .clear))
                    
                    Text(color.capitalized)
                        .font(.system(size: 15, weight: .semibold))
                    
                    Spacer()
                    
                    if self.color == color {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color(.systemBlue))
                    }
                }.contentShape(Rectangle())
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()
                    self.color = color
                    
                }
            }
        }.listStyle(InsetGroupedListStyle())
        .navigationTitle("Color")
    }
    
    private func colors() -> [String] {
        return ["blue", "orange", "red", "green", "dark"]
    }
}

//MARK: SubjectTitleTextField
struct SubjectTitleTextField: UIViewRepresentable {
    
    class Coordinator: NSObject, UITextFieldDelegate {

        @Binding var text: String
        
        var onBeginEditing: () -> Void
        var onReturn: () -> Void

        init(text: Binding<String>, onBeginEditing: @escaping () -> Void, onReturn: @escaping () -> Void) {
            _text = text
            self.onBeginEditing = onBeginEditing
            self.onReturn = onReturn
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
        
        func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            onBeginEditing()
            return true
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            onReturn()
        }
    }

    var placeholder: String
    @Binding var text: String
    var onBeginEditing: () -> Void
    var onReturn: () -> Void
    
    init(_ place: String, _ textBinding: Binding<String>, onBeginEditing: @escaping () -> Void, onReturn: @escaping () -> Void) {
        placeholder = place
        _text = textBinding
        self.onBeginEditing = onBeginEditing
        self.onReturn = onReturn
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.placeholder = placeholder
        textField.autocorrectionType = .no
        textField.delegate = context.coordinator
        return textField
    }

    func makeCoordinator() -> SubjectTitleTextField.Coordinator {
        return Coordinator(text: $text, onBeginEditing: onBeginEditing, onReturn: onReturn)
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
    
}


//MARK: LessonAddView_Previews
struct LessonAddView_Previews: PreviewProvider {
    static var previews: some View {
        LessonAddView {
            
        }.colorScheme(.dark)
    }
}
