//
//  CustomTextField.swift
//  Tymed
//
//  Created by Jonah Schueller on 05.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

//MARK: CustomTextField
struct CustomTextField: UIViewRepresentable {
    
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
        textField.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return textField
    }

    func makeCoordinator() -> CustomTextField.Coordinator {
        return Coordinator(text: $text, onBeginEditing: onBeginEditing, onReturn: onReturn)
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
    
}
