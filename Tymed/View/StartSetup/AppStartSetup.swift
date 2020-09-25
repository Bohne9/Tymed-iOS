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
    
    private let presetValues = [State(initialValue: true), State(initialValue: false), State(initialValue: false), State(initialValue: false)]
    
    private let presetImage = ["Tymed-School"]
    
    @State
    private var preset = "School"
    
    @State
    private var schoolValue = true
    
    @State
    private var universityValue = false

    @State
    private var productivityValue = false

    @State
    private var otherValue = false

    
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
                    Text(preset)
                        .foregroundColor(.blue)
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
                                    Image(presetImage[0])
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .padding(.top, 20)
                                        
                                    RadioButton(value: presetBinding(for: value)) {
                                        withAnimation {
                                            setPreset(value: value)
                                        }
                                    }
                                    Spacer()
                                    
                                }
                                .padding(.bottom, 40)
                                .padding(.top)
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(12)
                                .padding(.horizontal)
                                .onTapGesture {
                                    withAnimation {
                                        setPreset(value: value)
                                    }
                                }
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
    
    private func presetBinding(for value: Int) -> Binding<Bool> {
        switch value {
        case 0:
            return $schoolValue
        case 1:
            return $universityValue
        case 2:
            return $productivityValue
        case 3:
            return $otherValue
        default:
            return $schoolValue
        }
    }
    
    private func setPreset(value: Int) {
        schoolValue = false
        universityValue = false
        productivityValue = false
        otherValue = false
        
        switch value {
        case 0:
            schoolValue.toggle()
        case 1:
            universityValue.toggle()
        case 2:
            productivityValue.toggle()
        case 3:
            otherValue.toggle()
        default:
            break
        }
        
        preset = presetTitles[value]
    }
}

struct AppStartSetup_Previews: PreviewProvider {
    static var previews: some View {
        AppStartSetup()
            .colorScheme(.dark)
    }
}
