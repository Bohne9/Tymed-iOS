//
//  HomeTaskView.swift
//  Tymed
//
//  Created by Jonah Schueller on 19.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

class HomeTaskViewWrapper: ViewWrapper<HomeTaskView> {
    
    var homeViewModel: HomeViewModel?
    
    override func createContent() -> UIHostingController<HomeTaskView>? {
        guard let homeViewModel = self.homeViewModel else {
            return nil
        }
        
        return UIHostingController(rootView: HomeTaskView(homeViewModel: homeViewModel))
    }
    
}

//MARK: HomeTaskView
struct HomeTaskView: View {
    
    @ObservedObject
    var homeViewModel: HomeViewModel
    
    var body: some View {
        List {
            
            Section {
                // Combine the timetables with the percentage of their completed tasks
                // Filter any timetables without any tasks (where the value is -1)
                ForEach(homeViewModel.timetables.map { ($0, taskCompletePercentage(for: $0)) }.filter { $0.1 != -1 }, id: \.0.self) { timetable, value in
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                        
                            Text(timetable.name)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(.label))
                            
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .frame(width: geometry.size.width * 0.9 + 7.5, height: 7.5)
                                            .cornerRadius(3.75)
                                            .foregroundColor(Color(.tertiaryLabel))

                                        Rectangle()
                                            .frame(width: geometry.size.width * 0.9 * value + 7.5, height: 7.5)
                                            .cornerRadius(3.75)
                                            .foregroundColor(Color(UIColor(timetable) ?? .clear))
                                    }.frame(width: geometry.size.width * 0.9 + 7.5, height: 7.5)
                                }
                            
                        }
                        
                        Text("\(String(format: "%.1f", value * 100))%")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(.secondaryLabel))
                    }
                }
                
            }
            
        }.listStyle(InsetGroupedListStyle())
    }
    
    
    func taskCompletePercentage(for timetable: Timetable) -> CGFloat {
        let tasks = homeViewModel.tasks(for: timetable)
        
        if tasks.count == 0 {
            return -1
        }
        
        let complete = CGFloat(tasks.filter { $0.completed }.count)
        
        return complete / CGFloat(tasks.count)
    }
    
}



struct HomeTaskView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTaskView(homeViewModel: HomeViewModel())
    }
}
