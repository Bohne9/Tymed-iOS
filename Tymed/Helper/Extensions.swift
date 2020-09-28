//
//  Extensions.swift
//  Tymed
//
//  Created by Jonah Schueller on 07.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit
import SwiftUI

//MARK: String
extension String {
    func levenshteinDistanceScore(to string: String, ignoreCase: Bool = true, trimWhiteSpacesAndNewLines: Bool = true) -> Double {

        var firstString = self
        var secondString = string

        if ignoreCase {
            firstString = firstString.lowercased()
            secondString = secondString.lowercased()
        }
        if trimWhiteSpacesAndNewLines {
            firstString = firstString.trimmingCharacters(in: .whitespacesAndNewlines)
            secondString = secondString.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        let empty = [Int](repeating:0, count: secondString.count)
        var last = [Int](0...secondString.count)

        for (i, tLett) in firstString.enumerated() {
            var cur = [i + 1] + empty
            for (j, sLett) in secondString.enumerated() {
                cur[j + 1] = tLett == sLett ? last[j] : Swift.min(last[j], last[j + 1], cur[j])+1
            }
            last = cur
        }

        // maximum string length between the two
        let lowestScore = max(firstString.count, secondString.count)

        if let validDistance = last.last {
            return  1 - (Double(validDistance) / Double(lowestScore))
        }

        return 0.0
    }
}

//MARK: Date
extension Date {
    
    func stringify(with format: String, relativeFormatting: Bool = true) -> String{
        
        let formatter = DateFormatter()
        
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.doesRelativeDateFormatting = relativeFormatting
        formatter.dateFormat = format
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        
        return formatter.string(from: self)
    }
    
    
    func stringifyTime(with format: DateFormatter.Style, relativeFormatting: Bool = true) -> String{
        
        let formatter = DateFormatter()
        
        formatter.doesRelativeDateFormatting = relativeFormatting
        formatter.timeStyle = format
        
        return formatter.string(from: self)
    }
    
    func stringify(with style: DateFormatter.Style, relativeFormatting: Bool = true) -> String{
        
        let formatter = DateFormatter()
        
        formatter.doesRelativeDateFormatting = relativeFormatting
        
        formatter.dateStyle = style
        
        return formatter.string(from: self)
    }
    
    func stringify(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style, relativeFormatting: Bool = true) -> String {
        let formatter = DateFormatter()
        
        formatter.doesRelativeDateFormatting = relativeFormatting
        
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        
        return formatter.string(from: self)
    }
    
    func timeToString() -> String {
        return stringifyTime(with: .short)
    }
    
    func dayToString() -> String {
        return stringify(with: "EEEE")
    }
    
    func dayToStringShort() -> String {
        return stringify(with: "E")
    }
    
    var startOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 1, to: sunday)
    }
    
    var endOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 7, to: sunday)
    }
    
    var startOfDay: Date {
        return Calendar(identifier: .gregorian).startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    var nextDay: Date {
        return (self + (3600 * 24)).startOfDay
    }
    
    var prevDay: Date {
        return (self - (3600 * 24)).startOfDay
    }
}

//MARK: Calendar
extension Calendar {

    func isDateBetween(date: Date, left: Date, right: Date) -> Bool {
        return left < date && date < right
    }

}


//MARK: UIView
extension UIView {
    
    
    func constraint(height: CGFloat) {
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    
    func constraint(width: CGFloat) {
        self.widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    
    func constraint(width: CGFloat, height: CGFloat) {
        constraint(width: width)
        constraint(height: height)
    }
    
    func constraintHeightTo(anchor: NSLayoutDimension) {
        self.heightAnchor.constraint(equalTo: anchor).isActive = true
    }
    
    func constraintWidthTo(anchor: NSLayoutDimension) {
        self.widthAnchor.constraint(equalTo: anchor).isActive = true
    }
    
    func constraintLeadingTo(anchor: NSLayoutXAxisAnchor, constant: CGFloat = 0) {
        self.leadingAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
    }
    
    func constraintTrailingTo(anchor: NSLayoutXAxisAnchor, constant: CGFloat = 0) {
        self.trailingAnchor.constraint(equalTo: anchor, constant: -constant).isActive = true
    }
    
    func constraintTopTo(anchor: NSLayoutYAxisAnchor, constant: CGFloat = 0) {
        self.topAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
    }
    
    func constraintBottomTo(anchor: NSLayoutYAxisAnchor, constant: CGFloat = 0) {
        self.bottomAnchor.constraint(equalTo: anchor, constant: -constant).isActive = true
    }
    
    func constraintCenterXTo(anchor: NSLayoutXAxisAnchor, constant: CGFloat = 0) {
        self.centerXAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
    }
    
    func constraintCenterYTo(anchor: NSLayoutYAxisAnchor, constant: CGFloat = 0) {
        self.centerYAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
    }
    
    func constraintLeadingToSuperview(constant: CGFloat = 0) {
        guard let anchor = superview?.leadingAnchor else {
            return
        }
        
        self.constraintLeadingTo(anchor: anchor, constant: constant)
    }
    
    func constraintTrailingToSuperview(constant: CGFloat = 0) {
        guard let anchor = superview?.trailingAnchor else {
            return
        }
        
        self.constraintTrailingTo(anchor: anchor, constant: constant)
    }
    
    func constraintTopToSuperview(constant: CGFloat = 0) {
        guard let anchor = superview?.topAnchor else {
            return
        }
        
        self.constraintTopTo(anchor: anchor, constant: constant)
    }
    
    func constraintBottomToSuperview(constant: CGFloat = 0) {
        guard let anchor = superview?.bottomAnchor else {
            return
        }
        
        self.constraintBottomTo(anchor: anchor, constant: constant)
    }
    
    func constraintCenterXToSuperview(constant: CGFloat = 0) {
        guard let anchor = superview?.centerXAnchor else {
            return
        }
        
        self.constraintCenterXTo(anchor: anchor, constant: constant)
    }
    
    func constraintCenterYToSuperview(constant: CGFloat = 0) {
        guard let anchor = superview?.centerYAnchor else {
            return
        }
        
        self.constraintCenterYTo(anchor: anchor, constant: constant)
    }
    
    func constraintHeightToSuperview() {
        guard let anchor = superview?.heightAnchor else {
            return
        }
        
        self.constraintHeightTo(anchor: anchor)
    }
    
    func constraintWidthToSuperview() {
        guard let anchor = superview?.widthAnchor else {
            return
        }
        
        self.constraintWidthTo(anchor: anchor)
    }
    
    func constraintHorizontalToSuperview(leading: CGFloat = 0, trailing: CGFloat = 0) {
        constraintLeadingToSuperview(constant: leading)
        constraintTrailingToSuperview(constant: trailing)
    }
    
    func constraintVerticalToSuperview(top: CGFloat = 0, bottom: CGFloat = 0) {
        constraintTopToSuperview(constant: top)
        constraintBottomToSuperview(constant: bottom)
    }
    
    func constraintToSuperview(top: CGFloat = 0, bottom: CGFloat = 0, leading: CGFloat = 0, trailing: CGFloat = 0) {
        constraintTopToSuperview(constant: top)
        constraintBottomToSuperview(constant: bottom)
        constraintLeadingToSuperview(constant: leading)
        constraintTrailingToSuperview(constant: trailing)
    }
    
}

extension Color {
    
    static let appColor = Color(.appColor)
    static let appColorLight = Color(.appColorLight)
    
    init(_ event: CalendarEvent) {
        self.init(event.color ?? .appColor)
    }
    
}

//MARK: UIColor
extension UIColor {
    
    static let appColorLight = UIColor(named: "app-color-light")!
    static let appColor = UIColor(named: "app-color")!
    static let appGreen = UIColor(named: "green")!
    static let appBlue = UIColor(named: "blue")!
    static let appRed = UIColor(named: "red")!
    static let appOrange = UIColor(named: "orange")!
    
    convenience init? (_ subject: Subject?) {
        guard let color = subject?.color else {
            return nil
        }
        self.init(named: color)
    }
    
    convenience init? (_ lesson: Lesson?) {
        self.init(lesson?.subject)
    }
    
    convenience init? (_ timetable: Timetable) {
        self.init(named: timetable.color)
    }
    
    convenience init? (_ event: Event) {
        guard let timetable = event.timetable else {
            return nil
        }
        self.init(timetable)
    }
    
    convenience init? (_ calendarEvent: CalendarEvent) {
        if let lesson = calendarEvent.asLesson {
            self.init(lesson)
        } else if let event = calendarEvent.asEvent {
            self.init(event)
        }else {
            return nil
        }
    }
}


//MARK: TimeInterval
extension TimeInterval {

    static func seconds(_ value: TimeInterval) -> TimeInterval {
        return value
    }
    
    static func minute(_ value: Int) -> TimeInterval {
        return TimeInterval(value * 60)
    }
    
    static func hour(_ value: Int) -> TimeInterval {
        return minute(value) * 60
    }
    
    static func day(_ value: Int) -> TimeInterval {
        return hour(value) * 24
    }

}


//MARK: Binding
extension Binding {
    init(_ source: Binding<Value?>, _ defaultValue: Value) {
        self.init(get: {
            // ensure the source doesn't contain nil
            if source.wrappedValue == nil {
                source.wrappedValue = defaultValue
            }
            return source.wrappedValue ?? defaultValue
        }, set: {
            source.wrappedValue = $0
        })
    }
    
    init<T>(isNotNil source: Binding<T?>, defaultValue: T) where Value == Bool {
        self.init(get: { source.wrappedValue != nil },
                  set: { source.wrappedValue = $0 ? defaultValue : nil })
    }
    
    init(_ source: Binding<Value?>, replacingNilWith nilValue: Value) where Value: Equatable {
        self.init(
            get: { source.wrappedValue ?? nilValue },
            set: { newValue in
                if newValue == nilValue {
                    source.wrappedValue = nil
                }
                else {
                    source.wrappedValue = newValue
                }
        })
    }
    
}
