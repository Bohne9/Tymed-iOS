//
//  AppContentView.swift
//  Tymed
//
//  Created by Jonah Schueller on 28.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

@main
struct AppContentView: App {
    var body: some Scene {
        WindowGroup {        
            TabView {
                
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                            .font(.caption)
                    }
                
                CalendarView()
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                            .font(.system(size: 14, weight: .semibold))
                    }
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                            .font(.system(size: 14, weight: .semibold))
                    }
            }.environment(\.managedObjectContext, PersistanceService.shared.persistentContainer.viewContext)
        }
    }
}
