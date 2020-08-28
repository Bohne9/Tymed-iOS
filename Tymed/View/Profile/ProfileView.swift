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
    
    var body: some View {
        List {
            
            // Me
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
            }
            
            Section {
                HStack {
                    DetailCellDescriptor("Upgrade to Pro!", image: "star.fill", .clear)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                }.foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .background(Color(.systemOrange))
            
            Section {
                NavigationLink (destination: Text("Tell your friends")) {
                    DetailCellDescriptor("Tell your friends", image: "heart.fill", .systemPink)
                }
                
                NavigationLink (destination: Text("Tips & Help")) {
                    DetailCellDescriptor("Tips & Help", image: "lightbulb.fill", .systemOrange)
                }
            }
            
            Section {
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
                        Image(uiImage: #imageLiteral(resourceName: "logo"))
                            .resizable()
                            .frame(width: 60, height:  60)
                            
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

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
        }.colorScheme(.dark)
    }
}
