//
//  PrivacyPolicy.swift
//  Tymed
//
//  Created by Jonah Schueller on 26.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

struct PrivacyPolicy: View {
    
    @ObservedObject
    var setupModel: AppSetupModel
    
    @Environment(\.presentationMode)
    var presentationMode
    
    @State
    var acceptPrivacy = false
    
    @State
    var email = ""
    
    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                
                VStack(spacing: 20) {
                    VStack(spacing: 15) {
                        
                        Image(systemName: "lock.fill")
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundColor(Color(.systemBlue))
                        
                        Text("Privacy Matters!")
                            .font(.system(size: 28, weight: .bold))
                        
                        Text("Your data belongs to you. Read about our privacy policy and terms & conditions.")
                            .lineLimit(2)
                            .font(.system(size: 13, weight: .regular))
                        
                        HStack {
                            Text("Privacy Policy")
                                .font(.system(size: 13, weight: .regular))
                                .underline()
                                .foregroundColor(Color(.systemBlue))
                            
                            Text("Terms & Cond.")
                                .font(.system(size: 13, weight: .regular))
                                .underline()
                                .foregroundColor(Color(.systemBlue))
                        }
                        
                        HStack {
                            Image(systemName: acceptPrivacy ? "checkmark.square.fill" : "square")
                                .foregroundColor(.blue)
                                .font(.system(size: 15, weight: .semibold))
                            Text("I read and accept the privacy policy and terms & conditions")
                                .font(.system(size: 12, weight: .regular))
                        }.onTapGesture(count: 1, perform: {
                            acceptPrivacy.toggle()
                        })
                        
                    }.padding(.bottom)
                    
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 35, weight: .semibold))
                        .foregroundColor(Color(.systemBlue))
                    
                    Text("Stay up to date!")
                        .font(.system(size: 28, weight: .bold))
                    
                    Text("We hate spammers too. May we ask for your email to keep you updated with important news.")
                        .font(.system(size: 13, weight: .regular))
                    
                    
                    TextField("Email", text: $setupModel.email)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .font(.system(size: 18, weight: .semibold))
                        .cornerRadius(8)
                    
                    Text("Later")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color(.systemBlue))
                        .onTapGesture(perform: {
                            scrollView.scrollTo("contiueBtn")
                        })
                        .padding(.bottom, 50)
                    
                    Spacer()
                    
                    Button(action: {
                        
                        setupModel.setup()
                        presentationMode.wrappedValue.dismiss()
                        
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
                    .disabled(!acceptPrivacy)
                    .id("contiueBtn")
                }.padding()
            }.navigationTitle("Welcome")
                
        }
    }
}
