//
//  FeedbackView.swift
//  Tymed
//
//  Created by Jonah Schueller on 01.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

struct FeedbackView: View {
    
    private var topics = [
        "Found a bug",
        "Request a new feature",
        "Other"
    ]
    
    @State
    private var topic: String = "Found a bug"
    
    var body: some View {
        List {
            Section {
                HStack {
                    DetailCellDescriptor("1. Select the topic", image: imageForTopic(topic), colorForTopic(topic))
                    Picker(topic, selection: $topic) {
                        ForEach(topics, id: \.self) { topic in
                            DetailCellDescriptor(topic, image: imageForTopic(topic)
                                                 , colorForTopic(topic))
                        }
                    }.pickerStyle(MenuPickerStyle())
                }
            }
        }.listStyle(InsetGroupedListStyle())
        .navigationTitle("Feedback")
    }
    
    
    private func imageForTopic(_ topic: String) -> String {
        switch topic {
        case "Found a bug":
            return "ant.fill"
        case "Request a new feature":
            return "star.fill"
        default:
            return "circle.fill"
        }
    }
    
    private func colorForTopic(_ topic: String) -> UIColor {
        switch topic {
        case "Found a bug":
            return .systemRed
        case "Request a new feature":
            return .systemGreen
        default:
            return .systemPurple
        }
    }
}

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView()
    }
}
