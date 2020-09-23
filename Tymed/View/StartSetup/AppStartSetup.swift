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
                .font(.system(size: 16, weight: .semibold))
                
                GeometryReader { proxy in
                    TabView {
                        
                        ForEach(0...2, id: \.self) { value in
                            
                            VStack {
                                
                                Spacer()
                                
                                HStack {
                                    Spacer()
                                    Text("Student")
                                    
                                    Spacer()
                                }
                                
                                Spacer()
                                
                            }
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .padding()
                        }
                    }
//                    .padding()
                    .frame(width: proxy.size.width, height: proxy.size.height * 0.6)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
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
        }
    }
}

struct AppStartSetup_Previews: PreviewProvider {
    static var previews: some View {
        AppStartSetup()
            .colorScheme(.dark)
    }
}
