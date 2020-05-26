//
//  Extensions.swift
//  Tymed
//
//  Created by Jonah Schueller on 07.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import Foundation

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
