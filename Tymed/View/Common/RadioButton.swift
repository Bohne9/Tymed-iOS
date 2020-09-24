//
//  RadioButton.swift
//  Tymed
//
//  Created by Jonah Schueller on 24.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

struct RadioButton: View {
    
    @Binding
    var value: Bool
    
    let onTap: () -> Void

    var body: some View {
        Group{
            if value {
                ZStack{
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 20, height: 20)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                }
            } else {
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    .onTapGesture {
                        value.toggle()
                        onTap()
                    }
            }
        }
    }
}
