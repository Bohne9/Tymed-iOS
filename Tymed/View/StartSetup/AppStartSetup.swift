//
//  AppStartSetup.swift
//  Tymed
//
//  Created by Jonah Schueller on 23.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

class AppStartSetupWrapper: ViewWrapper<AppStartSetup> {
    
    override func createContent() -> UIHostingController<AppStartSetup>? {
        return UIHostingController(rootView: AppStartSetup())
    }
}

struct AppStartSetup: View {
    
    private let presetTitles = ["School", "University", "Productivity", "Other"]
    
    @State
    var name = ""
    
    var body: some View {
        NavigationView {
            VStack {
                
                VStack(alignment: .leading) {
                    
                    Text("Let's get to know each other")
                    Text("What is your name:")
                    
                    TextField("Name", text: $name)
                    
                }.padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .padding()
                
                HStack {
                    Text("Select a preset:")
                    Spacer()
                }.padding(.horizontal)
                
                GeometryReader { proxy in
                    
                    VStack {
                        
                        TabView {
                            
                            ForEach(0...3, id: \.self) { value in
                                
                                VStack {
                                    
                                    Spacer()
                                    
                                    HStack {
                                        Spacer()
                                        Text(presetTitles[value])
                                        
                                        Spacer()
                                    }
                                    
                                    Spacer()
                                    
                                }
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        }
                        .frame(width: proxy.size.width, height: proxy.size.height * 0.75)
                        .tabViewStyle(PageTabViewStyle())
                        
                        HStack {
                            HStack {
                                Text("You can changes the preset later.")
                                    .font(.system(size: 12, weight: .regular))
                                Spacer()
                            }.padding(.horizontal)
                        }
                    }
                
                }
                Spacer()
                
                Button(action: {
                    
                }, label: {
                    HStack {
                        Spacer()
                        Text("Continue")
                            .font(.system(size: 18, weight: .semibold))
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemBlue))
                    .foregroundColor(Color(.label))
                    .cornerRadius(12)
                    .padding()
                })
                
            }.navigationTitle("Welcome")
            .font(.system(size: 16, weight: .semibold))
        }
    }
}

struct AppStartSetup_Previews: PreviewProvider {
    static var previews: some View {
        AppStartSetup()
            .colorScheme(.dark)
    }
}
