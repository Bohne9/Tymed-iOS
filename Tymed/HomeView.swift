//
//  HomeView.swift
//  Tymed
//
//  Created by Jonah Schueller on 27.04.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    
    //    @Environment(\.managedObjectContext) var context
    
    //    @FetchRequest(entity: Subject.entity(),
    //                  sortDescriptors: [NSSortDescriptor(keyPath: \Subject.name, ascending: false)]
    //    )
    //    var subjects: FetchedResults<Subject>
    //
    //    @FetchRequest(entity: Lesson.entity(),
    //                  sortDescriptors: [NSSortDescriptor(keyPath: \Lesson
    //                    .id, ascending: false)]
    //    )
    //    var lessons: FetchedResults<Lesson>
    
    @State
    var showsAddSheet = false
    
    @State
    var offset: CGFloat = 0
    
    @State
    var dragOffset: CGFloat = 0
    
    @GestureState
    var dragState: CGFloat = 0
    
    @State
    var currentPage = 0
    
    let drag = DragGesture(minimumDistance: 45)
    
    //MARK: body
    var body: some View {
        
        //MARK: NavigationView
        GeometryReader { geo in
            
            VStack {
                
                //MARK: Top navigation
//                TopBar(geo: geo, currentPage: self.$currentPage, offset: self.$offset, dragOffset: self.$dragOffset)
                
                //MARK: Content
                
                ZStack {
                    List {
                        Text("Dash")
                    }
                    
                    List {
                        Text("Dash")
                    }.offset(x: geo.size.width, y: 0)
                    
                    List {
                        Text("Hallo")
                        //                            }
                    }.offset(x: geo.size.width * 2, y: 0)
                    
                }.offset(x: self.offset + self.dragState,y: 0)
            }
            .animation(Animation.interactiveSpring())
//            .simultaneousGesture(self.drag.onEnded({ (value) in
//                //MARK: Drag gesture
//                let off = value.predictedEndTranslation.width
//                print("end - \(self.dragState)")
//                if self.currentPage == 0 && off > 0 ||
//                    self.currentPage == 2 && off < 0 { // Out of bounds
//
//                    withAnimation(Animation.interactiveSpring()) {
//                        self.dragOffset = 0
//                    }
//                }else if off < -100 { // Swipe right
//                    self.currentPage = self.currentPage + 1 // Go to next page
//                    withAnimation(Animation.interactiveSpring()) {
//                        self.dragOffset = 0
//                        self.offset = -CGFloat(self.currentPage) * geo.size.width
//                    }
//                }else if off > 100 { // Swift left
//                    self.currentPage = max(self.currentPage - 1, 0) // Go to previous page
//                    withAnimation(Animation.interactiveSpring()) {
//                        self.dragOffset = 0
//                        self.offset = -CGFloat(self.currentPage) * geo.size.width
//                    }
//                }else { // Any other case, just reset
//                    withAnimation(Animation.interactiveSpring()) {
//                        self.dragOffset = 0
//                    }
//                }
//            }).updating(self.$dragState, body: { (value, state, transaction) in
//                print(value.translation.width)
//                state = value.translation.width
//            }))
            
            
            Spacer()
            
        }
    
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
