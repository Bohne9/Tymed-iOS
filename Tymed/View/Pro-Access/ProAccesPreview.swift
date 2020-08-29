//
//  ProAccesPreview.swift
//  Tymed
//
//  Created by Jonah Schueller on 29.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

struct ProAccesPreview: View {
    var body: some View {
//        ScrollView {
            VStack {
                HStack {
                    VStack(spacing: 4) {
                        Text("Tymed")
                        Rectangle()
                            .frame(width: 90, height: 7.5)
                            .foregroundColor(Color(.systemBlue))
                    }
                        .font(.system(size: 26, weight: .heavy))
                    
                    Text("Pro")
                        .font(.system(size: 22, weight: .heavy))
                        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                        .background(Color(.systemBlue))
                        .cornerRadius(18)
                        .foregroundColor(.white)
                 
                    Spacer()
                }
                .padding(.bottom, 20)
                
                HStack {
                    Text("Get full access to great features!")
                        .font(.system(size: 20, weight: .heavy))
                        
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text(String("\u{2022}") + " Share your timetables & tasks with your friends 👨‍👧‍👧")
                    Text(String("\u{2022}") + " Add multiple timetables")
                    
                }
                .padding(EdgeInsets(top: 20, leading: 5, bottom: 5, trailing: 5))
                .font(.system(size: 16, weight: .heavy))
                
                Spacer()
                
                Text("7 days free trail, then $0.99 per month.")
                Text("Cancel anytime.")
                    .padding(.bottom, 5)
                
                
                Button(action: {
                    
                }, label: {
                    
                    HStack {
                        Spacer()
                        (Text("Start your free trail now!")
                            .font(.system(size: 18, weight: .bold))
                         +
                        Text("\nNo registration required.")
                            .font(.system(size: 12, weight: .regular))
                        )
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        Spacer()
                    }.frame(height: 50)
                    .background(Color(.systemBlue))
                    .cornerRadius(10)
                        
                }).padding(.bottom)
                
            }.padding()
//        }
    }
}

struct ProAccesPreview_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProAccesPreview()
                .colorScheme(.dark)
                .background(Color.black)
        }
    }
}
