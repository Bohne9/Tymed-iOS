//
//  HomeTaskCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 19.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI
import EventKit

//MARK: HomeTaskCell
struct HomeTaskCell: View {
    
    @EnvironmentObject
    var homeViewModel: HomeViewModel
    
    @EnvironmentObject
    var taskViewModel: TaskViewModel
    
    @ObservedObject
    var reminder: ReminderViewModel
    
    @State
    var showTaskDetail = false
    
    var body: some View {
        HStack(spacing: 15) {
            if reminder.calendar != nil {            
                RoundedRectangle(cornerRadius: 5, style: .circular)
                    .foregroundColor(Color(reminder.calendar.cgColor))
                    .frame(width: 8, height: 40)
            }
            
            Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 22.5, weight: .semibold))
                .foregroundColor(Color(reminder.isCompleted ? .secondaryLabel : .systemBlue))
                .frame(width: 25, height: 25)
                .onTapGesture {
                    withAnimation {
                        reminder.isCompleted.toggle()
                        taskViewModel.reload()
                        homeViewModel.reload()
                    }
                }
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    if reminder.isCompleted {
                        Text(reminder.title)
                            .font(.system(size: 15, weight: .semibold))
                            .strikethrough()
                            .foregroundColor(Color(.secondaryLabel))
                    }else {
                        Text(reminder.title)
                            .font(.system(size: 15, weight: .semibold))
                    }
                }
                
                
                if let date = reminder.dueDate() {
                    Text(textFor(date: date))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(colorFor(due: date)))
                }
            }
            
            Spacer()
            
        }.padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 10))
        .frame(height: 55)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            showTaskDetail.toggle()
        }.sheet(isPresented: $showTaskDetail, onDismiss: {
            taskViewModel.reload()
            homeViewModel.reload()
        }, content: {
//            TaskEditView(task: task, dismiss: { homeViewModel.reload() })
        }).onChange(of: reminder.isCompleted) { value in
            reminder.completionDate = value ? Date() : nil
        }
    }
    
    private func textFor(date: Date) -> String {
        return "\(date.stringify(dateStyle: .short, timeStyle: .short))"
    }
    
    private func colorFor(due date: Date) -> UIColor {
        if reminder.isCompleted {
            return .tertiaryLabel
        }
        
        if date < Date(){
            return .systemRed
        }else if date.timeIntervalSinceNow < 3600 {
            return .systemOrange
        }
        return .secondaryLabel
    }
}
