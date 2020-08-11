//
//  TaskPreviewCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 10.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

//MARK: TaskPreviewCell
struct TaskPreviewCell: View {
    
    @State
    var task: Task
    
    var body: some View {
        
        HStack(alignment: .center) {
            Image(systemName: task.iconForCompletion())
                .foregroundColor(Color(task.completeColor()))
                .font(.system(size: 22, weight: .semibold))
                .onTapGesture {
                    task.completed.toggle()
                    task.completionDate = task.completed ? Date() : nil
                }
            VStack(alignment: .leading) {
                Text(task.title)
                Spacer()
                Text(task.text ?? "")
            }.padding(.vertical, 5)
            Spacer()
            
            VStack(alignment: .trailing) {
                Circle()
                    .foregroundColor(Color(UIColor(task.lesson) ?? .clear))
                    .frame(width: 10, height: 10)
                Spacer()
                if let date = task.due {
                    Text(date.stringify(dateStyle: .short, timeStyle: .short))
                        .font(.system(size: 14, weight: .regular))
                }
            }.padding(.vertical, 5)
        }.frame(height: 50)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        
    }
    
}
