//
//  ProAccessBadge.swift
//  Tymed
//
//  Created by Jonah Schueller on 29.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

struct ProAccessBadge: View {
    
    @State
    private var showProAccessPreview = false
    
    var body: some View {
        Button(action: {
            showProAccessPreview.toggle()
        }, label: {
            HStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tymed")
                        Rectangle()
                            .frame(width: 65, height: 7.5)
                            .foregroundColor(Color(.white))
                    }
                        .font(.system(size: 18, weight: .heavy))
                    
                    Text("Pro")
                        .font(.system(size: 16, weight: .heavy))
                        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                        .background(Color(.white))
                        .cornerRadius(18)
                        .foregroundColor(Color(.systemBlue))
                 
                    Spacer()
                }.font(.system(size: 13, weight: .semibold))
                
                Spacer()
                
                Text("Learn more")
                    .font(.system(size: 14, weight: .semibold))
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
            }.foregroundColor(.white)
            .padding(20)
        })
        .sheet(isPresented: $showProAccessPreview, content: {
            ProAccesPreview()
        }).background(Color(.systemBlue))
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
}

struct ProAccessBadge_Previews: PreviewProvider {
    static var previews: some View {
        ProAccessBadge()
    }
}
