//
//  DayTests.swift
//  TymedTests
//
//  Created by Jonah Schueller on 16.06.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import XCTest
@testable import Tymed

class DayTests: XCTestCase {


    func testRawValue() {
        
        let days: [Day] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        
        for i in 1...days.count {
            XCTAssertEqual(Day(rawValue: i), days[i - 1])
        }
    }
    
    func testDayLessThan() {
        
        XCTAssertTrue(Day.monday < Day.sunday)
        
        XCTAssertFalse(Day.sunday < Day.monday)
        
        
    }
    
}
