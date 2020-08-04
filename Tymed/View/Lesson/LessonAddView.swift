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


struct LessonAddView: View {
    
    var dismiss: () -> Void
    
    //MARK: Lesson Subject Title
    @State private var subjectTitle = ""
    
    //MARK: Lesson Time state
    @State private var showSubjectSuggestions = false
    
    @State private var showStartTimePicker = false
    @State private var showEndTimePicker = false
    @State private var showDayPicker = false
    
    
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
            }.listStyle(InsetGroupedListStyle())
            .navigationTitle("Lesson")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel"){
                dismiss()
            }, trailing: Button("Add") {
                dismiss()
            })
        }
    }
    
    private func subjectSuggestions() -> [Subject] {
        return TimetableService.shared.subjectSuggestions(for: subjectTitle)
            .prefix(3)
            .map { $0 }
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
            onReturn()
            textField.resignFirstResponder()
            return true
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
