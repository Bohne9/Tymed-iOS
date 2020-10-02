//
//  HomeTaskCell.swift
//  Tymed
//
//  Created by Jonah Schueller on 19.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

//MARK: HomeTaskCell
struct HomeTaskCell: View {
    
    @EnvironmentObject
    var homeViewModel: HomeViewModel
    
    @EnvironmentObject
    var taskViewModel: TaskViewModel
    
    @ObservedObject
    var task: Task
    
    @State
    var showTaskDetail = false
    
    var body: some View {
        HStack(spacing: 15) {
            RoundedRectangle(cornerRadius: 5, style: .circular)
                .foregroundColor(Color(UIColor(task.timetable) ?? .clear))
                .frame(width: 8, height: 40)
            
            Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 22.5, weight: .semibold))
                .foregroundColor(Color(task.completed ? .secondaryLabel : .systemBlue))
                .frame(width: 25, height: 25)
                .onTapGesture {
                    withAnimation {
                        task.completed.toggle()
                        TimetableService.shared.save()
                        taskViewModel.reload()
                        homeViewModel.reload()
                    }
                }
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    if task.completed {
                        Text(task.title)
                            .font(.system(size: 15, weight: .semibold))
                            .strikethrough()
                            .foregroundColor(Color(.secondaryLabel))
                    }else {
                        Text(task.title)
                            .font(.system(size: 15, weight: .semibold))
                    }

                    if task.archived {
                        Image(systemName: "tray.full.fill")
                            .foregroundColor(Color(task.completed ? .tertiaryLabel : .secondaryLabel))
                            .font(.system(size: 13, weight: .semibold))
                    }
                }
                
                
                if let date = task.due {
                    Text(textFor(date: date))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(colorFor(due: date)))
                }
            }
            
            Spacer()
            
            if task.archived {
                Image(systemName: "tray.and.arrow.up.fill")
                    .font(.system(size: 17.5, weight: .semibold))
                    .foregroundColor(Color(.systemBlue))
                    .padding(.trailing)
                    .onTapGesture {
                        withAnimation {
                            task.unarchive()
                            TimetableService.shared.save()
                            homeViewModel.reload()
                            taskViewModel.reload()
                        }
                    }
            }
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
            TaskEditView(task: task, dismiss: { homeViewModel.reload() })
        }).onChange(of: task.completed) { value in
            task.completionDate = value ? Date() : nil
            TimetableService.shared.save()
        }
    }
    
    private func textFor(date: Date) -> String {
        return "\(date.stringify(dateStyle: .short, timeStyle: .short))"
    }
    
    private func colorFor(due date: Date) -> UIColor {
        if task.completed {
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
