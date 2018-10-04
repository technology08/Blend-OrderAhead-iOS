//
//  Extensions.swift
//  BlendSmoothieBar
//
//  Created by Connor Espenshade on 6/6/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

import Foundation

extension Date {
    
    public func round(precision: TimeInterval) -> Date {
        return round(precision: precision, rule: .toNearestOrAwayFromZero)
    }
    
    public func ceil(precision: TimeInterval) -> Date {
        return round(precision: precision, rule: .up)
    }
    
    public func floor(precision: TimeInterval) -> Date {
        return round(precision: precision, rule: .down)
    }
    
    private func round(precision: TimeInterval, rule: FloatingPointRoundingRule) -> Date {
        let seconds = (self.timeIntervalSinceReferenceDate / precision).rounded(rule) *  precision
        return Date(timeIntervalSinceReferenceDate: seconds)
    }
    
    init(hour: Int, minute: Int) {
        let date = Date()
        let calendar = Calendar.current
        let current = calendar.dateComponents([.era, .year, .month, .day, .timeZone], from: date)
        let components = DateComponents(calendar: calendar, timeZone: TimeZone.current, era: nil, year: current.year, month: current.month, day: current.day, hour: hour, minute: minute, second: nil, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
        self = components.date!
    }
}

public extension Int {
    /// returns number of digits in Int number
    public var digitCount: Int {
        get {
            return numberOfDigits(in: self)
        }
    }
    /// returns number of useful digits in Int number
    public var usefulDigitCount: Int {
        get {
            var count = 0
            for digitOrder in 0..<self.digitCount {
                /// get each order digit from self
                let digit = self % (Int(truncating: pow(10, digitOrder + 1) as NSDecimalNumber))
                    / Int(truncating: pow(10, digitOrder) as NSDecimalNumber)
                if isUseful(digit) { count += 1 }
            }
            return count
        }
    }
    // private recursive method for counting digits
    private func numberOfDigits(in number: Int) -> Int {
        if abs(number) < 10 {
            return 1
        } else {
            return 1 + numberOfDigits(in: number/10)
        }
    }
    // returns true if digit is useful in respect to self
    private func isUseful(_ digit: Int) -> Bool {
        return (digit != 0) && (self % digit == 0)
    }
}

let times = ["2:30 PM", "2:35 PM", "2:40 PM", "2:45 PM", "2:50 PM", "2:55 PM", "3:00 PM", "3:05 PM", "3:10 PM", "3:15 PM", "3:20 PM", "3:25 PM", "3:30 PM", "3:35 PM", "3:40 PM", "3:45 PM"]
