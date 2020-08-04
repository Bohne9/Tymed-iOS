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
    @State private var day: Day = .current
    
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
                                .cornerRadius(3.0)
                                .onTapGesture {
//                                    withAnimation(Animation.easeInOut(duration: 0.5)) {
                                    subjectTitle = subject.name ?? ""
//                                    }
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
                            DatePicker("", selection: $endTime, displayedComponents: DatePickerComponents.hourAndMinute)
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
            }.listStyle(InsetGroupedListStyle())
            .navigationTitle("Lesson")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel"){
                dismiss()
            }, trailing: Button("Add") {
                addLesson()
            })
        }
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
        let subject = TimetableService.shared.subject(with: subjectTitle)
        
        TimetableService.shared.addLesson(subject: subject, day: day, start: startTime, end: endTime, note: nil)
        
        TimetableService.shared.save()
        
        dismiss()
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
