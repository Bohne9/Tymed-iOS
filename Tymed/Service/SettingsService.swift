//
//  SettingService.swift
//  Tymed
//
//  Created by Jonah Schueller on 28.07.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import Foundation

//MARK: SettingsService
class SettingsService {
    
    //MARK: SettingsServiceKeys
    enum SettingsServiceKeys: String {
        case taskAutoArchiveDelay = "taskAutoArchiveDelay"
        case notificationOffset = "notificationOffset"
        case username = "username"
        case appSetup = "appSetup"
        case email = "email"
        
    }
    
    //MARK: TaskAutoArchiveDefault
    struct TaskAutoArchiveDelay: Equatable, CaseIterable {
        
        typealias AllCases = [TaskAutoArchiveDelay]
        
        static func == (lhs: SettingsService.TaskAutoArchiveDelay, rhs: SettingsService.TaskAutoArchiveDelay) -> Bool {
            return lhs.delay == rhs.delay
        }
        
        static let immediately = TaskAutoArchiveDelay(0)
        static let hour = TaskAutoArchiveDelay(3600)
        static let day = TaskAutoArchiveDelay(86400)
        static let week = TaskAutoArchiveDelay(604800)
        
        static var allCases: [TaskAutoArchiveDelay] {
            return [
                immediately!,
                hour!,
                day!,
                week!
            ]
        }
        
        static func other(delay: Int?) -> TaskAutoArchiveDelay? {
            return TaskAutoArchiveDelay(delay)
        }
        
        static func other(delay: TimeInterval?) -> TaskAutoArchiveDelay? {
            return TaskAutoArchiveDelay(delay)
        }
        
        var delay: Int = 0
        
        var timeinterval: TimeInterval {
            return TimeInterval(delay)
        }
        
        internal init?(_ delay: Int?) {
            guard let delay = delay else {
                return nil
            }
            self.delay = delay
        }
        
        internal init?(_ delay: TimeInterval?) {
            guard let delay = delay else {
                self.init(0)
                return
            }
            self.init(Int(delay))
        }
        
        var title: String {
            switch self {
            default:
                if delay < 3600 {
                    return "After \(delay / 60) minutes"
                }else if delay < 3600 * 24 {
                    return "After \(delay / 3600) hours"
                }else {
                    return "After \(delay / 86400) days"
                }
            }
        }
    }
    
    //MARK: Variables
    
    static let shared = SettingsService()

    //MARK: init()
    internal init() {
    
    }

    // User defaults
    let defaults = UserDefaults.standard
    
    var notificationOffset: NotificationOffset? {
        get {
            guard let value = integer(.notificationOffset) else {
                return nil
            }
            return NotificationOffset(value: value)
        }
        set {
            set(newValue?.value, key: .notificationOffset)
        }
    }
    
    var taskAutoArchivingDelay: TaskAutoArchiveDelay? {
        get {
            return TaskAutoArchiveDelay.other(delay: integer(.taskAutoArchiveDelay))
        }
        set {
            set(newValue?.delay, key: .taskAutoArchiveDelay)
            BackgroundRoutineService.standard.archiveExpiredTasks()
        }
    }
    
    var didRunAppSetup: Bool {
        get {
            return bool(.appSetup) ?? false
        }
        set {
            set(newValue, key: .appSetup)
        }
    }
    var username: String {
        get {
            string(.username) ?? ""
        }
        set {
            set(newValue, key: .username)
        }
    }
    
    var email: String {
        get {
            string(.email) ?? ""
        }
        set {
            set(newValue, key: .email)
        }
    }
    
    //MARK: UserDefault Getter
    func string(_ key: SettingsServiceKeys) -> String? {
        return defaults.string(forKey: key.rawValue)
    }
    
    func integer(_ key: SettingsServiceKeys) -> Int? {
        return defaults.integer(forKey: key.rawValue)
    }
    
    func bool(_ key: SettingsServiceKeys) -> Bool? {
        return defaults.bool(forKey: key.rawValue)
    }
    
    func timeInterval(_ key: SettingsServiceKeys) -> TimeInterval? {
        return defaults.object(forKey: key.rawValue) as? TimeInterval
    }
    
    
    //MARK: UserDefault Setter
    
    func set(_ value: Any?, key: SettingsServiceKeys) {
        defaults.set(value, forKey: key.rawValue)
    }
    
    func set(_ value: Int?, key: SettingsServiceKeys) {
        defaults.set(value, forKey: key.rawValue)
    }
    
    func set(_ value: TimeInterval?, key: SettingsServiceKeys) {
        set(value as Any, key: key)
    }
    
}
