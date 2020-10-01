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
                .foregroundColor(Color(task.completed ? .systemGreen : .secondaryLabel))
                .frame(width: 25, height: 25)
                .onTapGesture {
                    withAnimation {
                        task.completed.toggle()
                        TimetableService.shared.save()
                        homeViewModel.reload()
                    }
                }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(task.title)
                    .font(.system(size: 15, weight: .semibold))
                
                if let date = task.due {
                    Text(textFor(date: date))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(.secondaryLabel))
                }
            }
            
            Spacer()
        }.padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 10))
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            showTaskDetail.toggle()
        }.sheet(isPresented: $showTaskDetail, content: {
            TaskEditView(task: task, dismiss: { homeViewModel.reload() })
        })
        .onChange(of: task.completed) { value in
            task.completionDate = value ? Date() : nil
            TimetableService.shared.save()
        }
    }
    
    private func textFor(date: Date) -> String {
        return "\(date.stringify(dateStyle: .short, timeStyle: .short))"
    }
    
}
