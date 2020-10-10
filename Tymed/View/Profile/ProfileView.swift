//
//  ProfileView.swift
//  Tymed
//
//  Created by Jonah Schueller on 24.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
    
    @State
    private var username = ""
    
    @State
    private var email = ""
    
    
    @State
    private var showProAccessPreview = false
    
    var body: some View {
        NavigationView {
            
            List {
                
                // Me
                /*
                 Section {
                 
                 HStack(alignment: .top) {
                 Image(systemName: "person.circle.fill")
                 .resizable()
                 .frame(width: 60, height: 60, alignment: .center)
                 
                 VStack() {
                 TextField("Username", text: $username)
                 .font(.system(size: 20, weight: .semibold))
                 
                 TextField("Email", text: $email)
                 .font(.system(size: 16, weight: .semibold))
                 
                 Spacer()
                 }
                 Spacer()
                 }.padding(.vertical, 10)
                 } */
                
                
                
                Section {
                    ProAccessBadge()
                }
                
                Section {
                    NavigationLink (destination: Text("Tell your friends")) {
                        DetailCellDescriptor("Tell your friends", image: "heart.fill", .systemPink)
                    }
                    
                    NavigationLink (destination: FeedbackView()) {
                        DetailCellDescriptor("Feedback", image: "bubble.left.fill", .systemPurple)
                    }
                    
                    NavigationLink (destination: Text("Tips & Help")) {
                        DetailCellDescriptor("Tips & Help", image: "lightbulb.fill", .systemOrange)
                    }
                }
                
                Section {
                    NavigationLink(
                        destination: MeView()) {
                        DetailCellDescriptor("Me", image: "person.fill", .systemBlue)
                    }
                    
                    NavigationLink(
                        destination: SettingsView(),
                        label: {
                            DetailCellDescriptor("Settings", image: "gear", .systemGray)
                        })
                }
                
                Section {
                    NavigationLink(
                        destination: Text("Privacy Policy"),
                        label: {
                            DetailCellDescriptor("Privacy Policy", image: "hand.raised.fill", .systemBlue)
                        })
                    
                    NavigationLink(
                        destination: Text("Licence"),
                        label: {
                            DetailCellDescriptor("Licence", image: "doc.text.fill", .systemRed)
                        })
                    
                    NavigationLink(
                        destination: Text("Terms & Conditions"),
                        label: {
                            DetailCellDescriptor("Terms & Conditions", image: "checkmark.circle.fill", .systemGreen)
                        })
                    
                    NavigationLink(
                        destination: Text("About"),
                        label: {
                            DetailCellDescriptor("About", image: "person.fill", .systemOrange)
                        })
                }
                
                Section {
                    HStack {
                        Spacer()
                        //                    HStack(alignment: .center) {
                        Image("AppLogo-Dark")
                            .resizable()
                            .frame(width: 60, height:  60)
                            .cornerRadius(12)
                        
                        Text("Tymed")
                            .font(.system(size: 13, weight: .semibold))
                        //                    }
                        Spacer()
                    }
                    .padding(4)
                    .background(Color(.systemGroupedBackground))
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                
            }.listStyle(InsetGroupedListStyle())
            .navigationTitle("Profile")
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
        }.colorScheme(.dark)
    }
}
