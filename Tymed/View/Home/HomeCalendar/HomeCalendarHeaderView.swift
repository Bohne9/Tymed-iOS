//
//  HomeCalendarHeaderView.swift
//  Tymed
//
//  Created by Jonah Schueller on 10.10.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

struct HomeCalendarHeaderView: View {
    
    @State
    var showCalendarAdd = false
    
    var body: some View {
        HStack {
            Text("Calendar")
                .font(.system(size: 24, weight: .semibold))

            Spacer()
            
            Button {
                showCalendarAdd.toggle()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 25, weight: .semibold))
            }.sheet(isPresented: $showCalendarAdd, content: {
                Text("Add calendar")
            })

        }
    }
}

struct HomeCalendarHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HomeCalendarHeaderView()
    }
}
