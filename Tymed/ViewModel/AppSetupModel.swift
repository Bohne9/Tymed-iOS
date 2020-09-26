//
//  AppSetupModel.swift
//  Tymed
//
//  Created by Jonah Schueller on 26.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

class AppSetupModel: ObservableObject {
    
    @Published
    var name: String = ""
    
    @Published
    var preset: String = "School"
    
    @Published
    var email: String = ""
    
    
    func setup() {
        guard let preset = AppStartupPreset.preset(for: preset) else {
            return
        }
        
        preset.storePreset()
        
        SettingsService.shared.username = name
        SettingsService.shared.email = email
        SettingsService.shared.didRunAppSetup = true
        
        TimetableService.shared.save()
    }
    
}
