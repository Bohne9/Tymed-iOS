//
//  DetailCellDescriptor.swift
//  Tymed
//
//  Created by Jonah Schueller on 05.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

struct DetailCellDescriptor: View {
    
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
                    .font(.system(size: 15, weight: .semibold))
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
