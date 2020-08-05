//
//  AppColorPicker.swift
//  Tymed
//
//  Created by Jonah Schueller on 05.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

//MARK: ColorPickerView
struct AppColorPickerView: View {
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
