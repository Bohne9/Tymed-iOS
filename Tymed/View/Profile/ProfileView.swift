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
                
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60, alignment: .center)
                    VStack {
                        TextField("Username", text: $username)
                            .font(.system(size: 22, weight: .semibold))
                        
                        Spacer()
                        
                        TextField("Email", text: $email)
                            .font(.system(size: 18, weight: .semibold))
                    }.padding(20)
                }.frame(height: 100)
                
            }
            
            Section {
                NavigationLink(
                    destination: Text("Settings"),
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
                    VStack(alignment: .center) {
                        Image(uiImage: #imageLiteral(resourceName: "logo"))
                            .resizable()
                            .frame(width: 60, height:  60)
                            
                        Text("Tymed")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    Spacer()
                }
                .padding(4)
                .background(Color(.systemBackground))
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            
        }.listStyle(InsetGroupedListStyle())
        .navigationTitle("Profile")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
