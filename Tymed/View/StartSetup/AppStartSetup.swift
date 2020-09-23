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
                
                Text("Let's get to know each other")
                Text("What is your name:")
                
                TextField("Name", text: $name)
                
                GeometryReader { proxy in
                    TabView {
                        
                        ForEach(0...3, id: \.self) { value in
                            
                            VStack {
                                
                                Spacer()
                                
                                HStack {
                                    Spacer()
                                    Text("Student")
                                    
                                    Spacer()
                                }
                                
                                Spacer()
                                
                            }.padding()
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                        }
                    }
                    .frame(width: proxy.size.width, height: proxy.size.height * 0.4)
                    .tabViewStyle(PageTabViewStyle())
                }
                
            }.navigationTitle("Welcome")
        }
    }
}

struct AppStartSetup_Previews: PreviewProvider {
    static var previews: some View {
        AppStartSetup()
    }
}
