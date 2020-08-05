//
//  MultilineTextField.swift
//  Tymed
//
//  Created by Jonah Schueller on 04.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

struct MultilineTextField: UIViewRepresentable {
    
    class Coordinator: NSObject, UITextFieldDelegate {

        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            text = text + "\n"
            return true
        }
    }

    var placeholder: String
    @Binding var text: String
    
    init(_ place: String, _ textBinding: Binding<String>) {
        placeholder = place
        _text = textBinding
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.placeholder = placeholder
        textField.delegate = context.coordinator
        return textField
    }

    func makeCoordinator() -> MultilineTextField.Coordinator {
        return Coordinator(text: $text)
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
    
}
