//
//  HomeView.swift
//  Tymed
//
//  Created by Jonah Schueller on 27.04.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    
    @Environment(\.managedObjectContext) var context

    @FetchRequest(entity: Subject.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Subject.name, ascending: false)]
    )
    var subjects: FetchedResults<Subject>

    @FetchRequest(entity: Lesson.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Lesson
                    .id, ascending: false)]
    )
    var lessons: FetchedResults<Lesson>
    
    @State
    var showsAddSheet = false
    
    
    //MARK: body
    var body: some View {
        
        List {
            
            VStack(spacing: 12) {
                
                HStack {
                    Text("C.A.R.L")
                    Spacer()
                    Text("NOW")
                }.font(.system(size: 15, weight: .semibold))
                
                HStack {
                    Text("Databases")
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                    Text("10:30-12:00")
                        .font(.system(size: 15, weight: .semibold))
                }
                
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding()
            
        }.padding(.top)
    
    }
    
    
    
}

struct TopBar: View {
    
    var geo: GeometryProxy
    
    @Binding
    var currentPage: Int
    
    @Binding
    var offset: CGFloat
    
    @Binding
    var dragOffset: CGFloat
    
    var body: some View {
        HStack {
            ZStack(alignment: .topTrailing) {
                
                Button("Dash"){
                    self.currentPage = 0
                    withAnimation(Animation.easeOut(duration: 0.2)) {
                        self.dragOffset = 0
                        self.offset = 0
                    }
                }.opacity(self.currentPage == 0 ? 1.0 : 0.7)
                    .foregroundColor(Color(.label))
                
                Circle().frame(width: 7.5, height: 7.5).foregroundColor(Color.red)
                    .offset(x: 7.5, y: 0)
            }
                
            .padding(.horizontal)
            Button("Tasks"){
                self.currentPage = 1
                withAnimation(Animation.easeOut(duration: 0.2)) {
                    self.dragOffset = 0
                    self.offset = -self.geo.size.width
                }
            }.opacity(self.currentPage == 1 ? 1.0 : 0.7)
                .padding(.trailing) .foregroundColor(Color(.label))
            
            Button("Week"){
                self.currentPage = 2
                withAnimation(Animation.easeOut(duration: 0.2)) {
                    self.dragOffset = 0
                    self.offset = -2 * self.geo.size.width
                }
            }.opacity(self.currentPage == 2 ? 1.0 : 0.7) .foregroundColor(Color(.label))
            
            Spacer()
        }.font(.system(size: 30, weight: .bold))
            .padding(.top, 35)
        
    }
    
}


struct TopBar2: View {
    
    @State
    var currentPage: Int = 0
    
    var body: some View {
        HStack {
            ZStack(alignment: .topTrailing) {
                
                Button("Dash"){
                    self.currentPage = 0
                    
                }.opacity(self.currentPage == 0 ? 1.0 : 0.7)
                    .foregroundColor(Color(.label))
                
                Circle().frame(width: 7.5, height: 7.5).foregroundColor(Color.red)
                    .offset(x: 7.5, y: 0)
            }
                
            .padding(.horizontal)
            Button("Tasks"){
                self.currentPage = 1
                
            }.opacity(self.currentPage == 1 ? 1.0 : 0.7)
                .padding(.trailing) .foregroundColor(Color(.label))
            
            Button("Week"){
                self.currentPage = 2
                
            }.opacity(self.currentPage == 2 ? 1.0 : 0.7) .foregroundColor(Color(.label))
            
            Spacer()
        }.font(.system(size: 30, weight: .bold))
            .padding(.bottom)
        
    }
    
}
