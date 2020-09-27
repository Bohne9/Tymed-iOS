//
//  DayDebriefViewModel.swift
//  Tymed
//
//  Created by Jonah Schueller on 19.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

protocol DayDebriefDelegate {
    
    func numberOfEventsToday() -> Int
    
    func replacement(for placeholder: Placeholders) -> String
    
    func replace(placerholder: Placeholders, in string: String) -> String
    
}

extension DayDebriefDelegate {
    
    func replace(placerholder: Placeholders, in string: String) -> String {
        return string.replacingOccurrences(of: placerholder.rawValue, with: replacement(for: placerholder))
    }
    
}

enum Placeholders: String, CaseIterable {
    case name = "name"
    case gender = "gender"
    case totalEvents = "totalEvents"
}

class DayDebriefViewModel: ObservableObject {
    
    var delegate: DayDebriefDelegate
    
    init(_ delegate: DayDebriefDelegate) {
        self.delegate = delegate
    }
    
    //MARK: Greetings
    private let morningGreetings = [
        "Good Morning\(Placeholders.name), 👋\n",
        "Hi\(Placeholders.name), 👋\n",
        "Hello\(Placeholders.name), 👋\n",
        "Hey\(Placeholders.name), 👋\n"
    ]
    
    private let dayGreetings = [
        "Hi\(Placeholders.name), 👋\n",
        "Hello\(Placeholders.name), 👋\n",
        "Hey\(Placeholders.name), 👋\n"
    ]
    
    private let eveningGreetings = [
        "Good Evening\(Placeholders.name), 👋\n",
        "Hi\(Placeholders.name), 👋\n",
        "Hello\(Placeholders.name), 👋\n",
        "Hey\(Placeholders.name), 👋\n"
    ]
    
    //MARK: Busy Day
    private let busyDay = [
        "you got a busy day before. You got \(Placeholders.totalEvents) today.",
        "a lot of work today! \(Placeholders.totalEvents) today."
    ]
    
    //MARK: Normal day
    private let normalDay = [
        "you have \(Placeholders.totalEvents) today.",
        "\(Placeholders.totalEvents) are waiting today."
    ]
    
    //MARK: Relaxed Day
    private let relaxedDay = [
        "today is a relaxed day. You only got \(Placeholders.totalEvents) today."
    ]

    //MARK: Off Day
    private let offDay = [
        "Today is your off day! Get some rest.",
        "Great news! No events today."
    ]
    
    //MARK: nextEvent
    
    
    //MARK: Adoptions
    private let adoptions = [
        "\n\nHave a great day! 👍",
        "\n\nEnjoy your day! 😊"
    ]
    
    
//    "Good morning Jonah 🙋‍♂️,\nyou got a busy day before.\nYour day starts at 8 am with Math. You'll be done at 7 pm. \n\nHave a great day! 👍"
    
    var debrief: String {
        let debrief = generateDebrief()
        return replacePlaceholders(debrief)
    }
    
    private func generateDebrief() -> String {
        let now = Date()
        let greeting = self.greeting(for: now)
        
        let daySummary = self.daySummary(for: now)
        
        let adoption = self.adoption(for: now)
        
        return greeting + daySummary + adoption
    }
    
    private func replacePlaceholders(_ string: String) -> String {
        var value = string
        
        Placeholders.allCases.forEach { (placerholder) in
            value = delegate.replace(placerholder: placerholder, in: value)
        }
        
        return value
    }
    
    
    private func greeting(for date: Date) -> String {
        let time = Time(from: date)
        
        if time.hour < 10 {
            return morningGreetings.randomElement() ?? ""
        }else if time.hour < 19 {
            return dayGreetings.randomElement() ?? ""
        }else {
            return eveningGreetings.randomElement() ?? ""
        }
    }
    
    private func daySummary(for date: Date) -> String {
        let eventCount = delegate.numberOfEventsToday()
        
        if eventCount == 0 {
            return offDay.randomElement() ?? ""
        }else if eventCount < 3 {
            return relaxedDay.randomElement() ?? ""
        }else if eventCount < 6 {
            return normalDay.randomElement() ?? ""
        }else {
            return busyDay.randomElement() ?? ""
        }
        
    }
    
    private func adoption(for date: Date) -> String {
        return adoptions.randomElement() ?? ""
    }
    
}
