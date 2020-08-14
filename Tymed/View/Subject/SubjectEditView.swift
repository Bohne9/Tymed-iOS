//
//  SubjectEditView.swift
//  Tymed
//
//  Created by Jonah Schueller on 14.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

struct SubjectEditView: View {
    
    @ObservedObject
    var subject: Subject
    
    var body: some View {
        List {
            
            Section {
                TextField("Name", text: $subject.name)
            }
            
        }.listStyle(InsetGroupedListStyle())
        .navigationTitle("Subject")
    }
}
