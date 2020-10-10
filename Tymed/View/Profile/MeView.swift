//
//  MeView.swift
//  Tymed
//
//  Created by Jonah Schueller on 10.10.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

struct MeView: View {
    
    @AppStorage(SettingsService.SettingsServiceKeys.username.rawValue)
    var username: String?
    
    var body: some View {
        
        List {
            Section {
                TextField("Username", text: Binding($username, replacingNilWith: ""))
            }
        }.listStyle(InsetGroupedListStyle())
        .navigationTitle("Me")
        
    }
}

struct MeView_Previews: PreviewProvider {
    static var previews: some View {
        MeView()
    }
}
