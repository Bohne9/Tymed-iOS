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
                RoundedRectangle(cornerRadius: 4, style: .circular)
                    .foregroundColor(Color(reminder.calendar.cgColor))
                    .frame(width: 8, height: 25)
                
            }
            
            Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(reminder.isCompleted ? .secondaryLabel : .systemBlue))
                .frame(width: 25, height: 25)
                .onTapGesture {
                    withAnimation {
                        reminder.isCompleted.toggle()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                ReminderService.shared.save(reminder.reminder)
                                taskViewModel.reload()
                                homeViewModel.reload()
                            }
                        }
                    }
                }
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    if reminder.isCompleted {
                        Text(reminder.title)
                            .font(.system(size: 14, weight: .semibold))
                            .strikethrough()
                            .foregroundColor(Color(.secondaryLabel))
                    }else {
                        Text(reminder.title)
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
                
                
                if let date = reminder.dueDate() {
                    Text(textFor(date: date))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(colorFor(due: date)))
                }
            }
            
            Spacer()
            
        }
        .background(Color(.secondarySystemBackground))
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            showTaskDetail.toggle()
        }.sheet(isPresented: $showTaskDetail, onDismiss: {
            taskViewModel.reload()
            homeViewModel.reload()
        }, content: {
            TaskEditView(reminder: reminder, dismiss: { homeViewModel.reload() })
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
