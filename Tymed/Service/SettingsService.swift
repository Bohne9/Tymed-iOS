//
//  SettingService.swift
//  Tymed
//
//  Created by Jonah Schueller on 28.07.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import Foundation


class SettingsService {
    
    enum SettingsServiceKeys: String {
        case taskAutoArchiveDelay = "taskAutoArchiveDelay"
        
        
    }
    
    
    static let shared = SettingsService()

    internal init() {
        
    }

    // User defaults
    let defaults = UserDefaults.standard
    
    var taskAutoArchivingDelay: TimeInterval? {
        get { return timeInterval(.taskAutoArchiveDelay) }
        set {
            set(newValue, key: .taskAutoArchiveDelay)
            BackgroundRoutineService.standard.archiveExpiredTasks()
        }
    }
    
    //MARK: UserDefault Getter
    func string(_ key: SettingsServiceKeys) -> String? {
        return defaults.string(forKey: key.rawValue)
    }
    
    func timeInterval(_ key: SettingsServiceKeys) -> TimeInterval? {
        return defaults.object(forKey: key.rawValue) as? TimeInterval
    }
    
    
    //MARK: UserDefault Setter
    
    func set(_ value: Any?, key: SettingsServiceKeys) {
        defaults.set(value, forKey: key.rawValue)
    }
    
    func set(_ value: TimeInterval?, key: SettingsServiceKeys) {
        set(value as Any, key: key)
    }
    
}
