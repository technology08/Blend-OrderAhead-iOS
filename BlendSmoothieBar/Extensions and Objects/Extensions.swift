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

let times = ["7:30 AM", "7:35 AM", "7:40 AM", "7:45 AM", "7:50 AM", "7:55 AM", "8:00 AM", "8:05 AM", "8:10 AM", "8:15 AM", "8:20 AM", "8:25 AM", "8:30 AM", "8:35 AM", "8:40 AM", "8:45 AM", "8:50 AM", "8:55 AM", "9:00 AM", "9:05 AM", "9:10 AM", "9:15 AM", "9:20 AM", "9:25 AM", "9:30 AM", "9:35 AM", "9:40 AM", "9:45 AM", "9:50 AM", "9:55 AM", "10:00 AM", "10:05 AM", "10:10 AM", "10:15 AM", "10:20 AM", "10:25 AM", "10:30 AM", "1:25 PM", "1:30 PM", "1:35 PM", "1:40 PM", "1:45 PM", "1:50 PM", "1:55 PM", "2:00 PM", "2:05 PM", "2:10 PM", "2:15 PM", "2:20 PM", "2:25 PM", "2:30 PM", "2:35 PM", "2:40 PM", "2:45 PM", "2:50 PM", "2:55 PM", "3:00 PM", "3:05 PM", "3:10 PM", "3:15 PM", "3:20 PM", "3:25 PM", "3:30 PM"]

let dates = [Date.init(hour: 7, minute: 30), Date.init(hour: 7, minute: 35), Date.init(hour: 7, minute: 45), Date.init(hour: 7, minute: 50), Date.init(hour: 7, minute: 55), Date.init(hour: 8, minute: 00), Date.init(hour: 8, minute: 05), Date.init(hour: 8, minute: 10)]
