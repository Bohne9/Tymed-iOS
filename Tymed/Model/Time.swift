//
//  Time.swift
//  Tymed
//
//  Created by Jonah Schueller on 10.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import CoreData

public class Time: NSObject, NSCoding {
    
    static public func <(_ t1: Time, _ t2: Time) -> Bool {
        if t1.hour < t2.hour {
            return true
        }else if t1.hour == t2.hour {
            return t1.minute < t2.minute
        }
        return false
    }
    
    static public func <=(_ t1: Time, _ t2: Time) -> Bool {
        if t1.hour < t2.hour {
            return true
        }else if t1.hour == t2.hour {
            return t1.minute <= t2.minute
        }
        return false
    }
    
    static public func ==(_ t1: Time, _ t2: Time) -> Bool {
        return t1.hour == t2.hour && t1.minute == t2.minute
    }
    
    static var zero: Time {
        return Time(hour: 0, minute: 0)
    }
    
    static var now: Time {
        return Time(from: Date())
    }
    
    static func between(_ t1: Time, _ t2: Time, t3: Time, allowEqual: Bool = true) -> Bool {
        if allowEqual {
            return t1 <= t2 && t2 <= t3
        }else {
            return t1 < t2 && t2 < t3
        }
    }
    
    var hour: Int = 0 {
        didSet {
            if hour < 0 || hour >= 24 {
                print("Error! Hour out of bounds")
                hour = 0
            }
        }
    }
    
    var minute: Int = 0
    
    var timeInterval: Int {
        get {
            hour * 60 + minute
        }
        set {
            self.hour = Int(newValue / 60)
            
            self.minute = newValue % 60
        }
    }
    
    var date: Date? {
        get {
            var d = DateComponents()
            d.hour = hour
            d.minute = minute
            return Calendar.current.date(from: d)
        }
    }
    
    func string() -> String? {
        return date?.timeToString()
    }
    
    init(hour: Int = 0, minute: Int = 0) {
        self.hour = hour % 24
        self.minute = minute % 60
    }
    
    init(timeInterval: Int) {
        super.init()
        self.timeInterval = timeInterval
    }
    
    convenience init(from date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        self.init(hour: components.hour ?? 0, minute: components.minute ?? 0)
    }
    
    
    
    public func encode(with coder: NSCoder) {
        coder.encode(NSNumber(value: hour), forKey: "hour")
        coder.encode(NSNumber(value: minute), forKey: "minute")
    }
    
    required public init?(coder: NSCoder) {
        self.hour = Int(truncating: coder.decodeObject(forKey: "hour") as! NSNumber)
        self.minute = Int(truncating: coder.decodeObject(forKey: "minute") as! NSNumber)
    }
    
//    override class func transformedValueClass() -> AnyClass {
//        return NSNumber.self
//    }
//
//    override func reverseTransformedValue(_ value: Any?) -> Any? {
//        guard let number = value as? NSNumber else {
//            return nil
//        }
//        return Time(timeInterval: number.intValue)
//    }
//
//    override func transformedValue(_ value: Any?) -> Any? {
//        return NSNumber(integerLiteral: timeInterval)
//    }
//
//    override class func allowsReverseTransformation() -> Bool {
//        return true
//    }
//
}
