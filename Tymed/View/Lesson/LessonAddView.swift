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
    
    @State private var showStartTimePicker = false
    @State private var showEndTimePicker = false
    @State private var showDayPicker = false
    
    @State private var test = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    if test {
                        Text("Hello Text")
                    }
                    
                    SubjectTitleTextField("Subject Name", $subjectTitle) {
                        withAnimation {
                            test.toggle()
                        }
                    } onReturn: {
                        withAnimation {
                            test.toggle()
                        }
                    }
                }
            }.listStyle(InsetGroupedListStyle())
        }
    }
}



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

struct LessonAddView_Previews: PreviewProvider {
    static var previews: some View {
        LessonAddView {
            
        }.colorScheme(.dark)
    }
}
