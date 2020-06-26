//
//  Extensions.swift
//  Tymed
//
//  Created by Jonah Schueller on 07.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

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


extension Date {
    
    func stringify(with format: String) -> String{
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = format
        
        return formatter.string(from: self)
    }
    
    
    func stringifyTime(with format: DateFormatter.Style) -> String{
        
        let formatter = DateFormatter()
        
        formatter.timeStyle = format
        
        return formatter.string(from: self)
    }
    
    func stringify(with style: DateFormatter.Style) -> String{
        
        let formatter = DateFormatter()
        
        formatter.dateStyle = style
        
        return formatter.string(from: self)
    }
    
    func stringify(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        
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
}




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
    
    func constraintLeadingTo(anchor: NSLayoutXAxisAnchor, constant: CGFloat) {
        self.leadingAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
    }
    
    func constraintTrailingTo(anchor: NSLayoutXAxisAnchor, constant: CGFloat) {
        self.trailingAnchor.constraint(equalTo: anchor, constant: -constant).isActive = true
    }
    
    func constraintTopTo(anchor: NSLayoutYAxisAnchor, constant: CGFloat) {
        self.topAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
    }
    
    func constraintBottomTo(anchor: NSLayoutYAxisAnchor, constant: CGFloat) {
        self.bottomAnchor.constraint(equalTo: anchor, constant: -constant).isActive = true
    }
    
    func constraintCenterXTo(anchor: NSLayoutXAxisAnchor, constant: CGFloat) {
        self.centerXAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
    }
    
    func constraintCenterYTo(anchor: NSLayoutYAxisAnchor, constant: CGFloat) {
        self.centerYAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
    }
    
    func constraintLeadingToSuperview(constant: CGFloat) {
        guard let anchor = superview?.leadingAnchor else {
            return
        }
        
        self.constraintLeadingTo(anchor: anchor, constant: constant)
    }
    
    func constraintTrailingToSuperview(constant: CGFloat) {
        guard let anchor = superview?.trailingAnchor else {
            return
        }
        
        self.constraintTrailingTo(anchor: anchor, constant: constant)
    }
    
    func constraintTopToSuperview(constant: CGFloat) {
        guard let anchor = superview?.topAnchor else {
            return
        }
        
        self.constraintTopTo(anchor: anchor, constant: constant)
    }
    
    func constraintBottomToSuperview(constant: CGFloat) {
        guard let anchor = superview?.bottomAnchor else {
            return
        }
        
        self.constraintBottomTo(anchor: anchor, constant: constant)
    }
    
    func constraintCenterXToSuperview(constant: CGFloat) {
        guard let anchor = superview?.centerXAnchor else {
            return
        }
        
        self.constraintCenterXTo(anchor: anchor, constant: constant)
    }
    
    func constraintCenterYToSuperview(constant: CGFloat) {
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
    
    func constraintHorizontalToSuperview(leading: CGFloat, trailing: CGFloat) {
        constraintLeadingToSuperview(constant: leading)
        constraintTrailingToSuperview(constant: trailing)
    }
    
    func constraintVerticalToSuperview(top: CGFloat, bottom: CGFloat) {
        constraintTopToSuperview(constant: top)
        constraintBottomToSuperview(constant: bottom)
    }
    
    func constraintToSuperview(top: CGFloat, bottom: CGFloat, leading: CGFloat, trailing: CGFloat) {
        constraintTopToSuperview(constant: top)
        constraintBottomToSuperview(constant: bottom)
        constraintLeadingToSuperview(constant: leading)
        constraintTrailingToSuperview(constant: trailing)
    }
    
}


extension UIColor {
    
    convenience init? (_ subject: Subject?) {
        guard let color = subject?.color else {
            return nil
        }
        self.init(named: color)
    }
    
    convenience init? (_ lesson: Lesson?) {
        self.init(lesson?.subject)
    }
    
}
