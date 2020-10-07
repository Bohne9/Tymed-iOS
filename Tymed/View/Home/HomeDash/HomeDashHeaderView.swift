//
//  HomeDashHeader.swift
//  Tymed
//
//  Created by Jonah Schueller on 28.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

struct HomeDashHeaderView: View {
    
    @EnvironmentObject
    var homeViewModel: HomeViewModel
    
    @State
    var showTaskAddView = false
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Text("Hello,\n")
                    .font(.system(size: 24, weight: .semibold))
                +
                    Text("\(SettingsService.shared.username)")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(Color(.tertiaryLabel))
                
                Spacer()
                
                Button {
                    showTaskAddView.toggle()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 25, weight: .semibold))
                        .foregroundColor(.appColor)
                }.sheet(isPresented: $showTaskAddView, onDismiss: {
                    homeViewModel.reload()
                }, content: {
                    EventAddView()
                }).padding(.trailing)

                
                Button {
                    
                } label: {
                    if let img = SettingsService.shared.profilePicture {
                        Text("Image")
                    } else {
                        Image(systemName: "person.crop.square")
                            .font(.system(size: 25, weight: .regular))
                            .foregroundColor(Color(.secondaryLabel))
                    }
                }
            }
            
            
        }
    }
}

struct HomeDashHeader_Previews: PreviewProvider {
    static var previews: some View {
        HomeDashHeaderView()
    }
}
