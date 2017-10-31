//
//  Product.swift
//  BlendSmoothieBar
//
//  Created by Connor Espenshade on 10/7/17.
//  Copyright © 2017 Connor Espenshade. All rights reserved.
//

import Foundation
import UIKit

struct Product {
    var name: String!
    var description: String?
    var modifiers: [Modifier] = []
    var image: UIImage?
    var price: Decimal!
    var type: ProductTypes!
    
    init(name: String, type: ProductTypes) {
        self.name = name
        self.type = type
    }
    
    init(name: String, price: Decimal, type: ProductTypes) {
        self.name = name
        self.type = type
        self.price = price
    }
    
    init(name: String, price: Decimal, modifiers: [Modifier], type: ProductTypes) {
        self.name = name
        self.price = price
        self.modifiers = modifiers
        self.type = type
    }
    
    init(name: String, description: String?, price: Decimal, modifiers: [Modifier], type: ProductTypes, image: UIImage?) {
        self.name = name
        self.description = description
        self.price = price
        self.modifiers = modifiers
        self.type = type
        self.image = image
    }
}

enum ProductTypes {
    case Smoothie
    case Shake
    case Food
}

var currentSmoothies: [Product] {
    /*
     Smoothies: (all $3)
     Strawberry
     Strawberry Lemonade
     Pineapple
     (modifiers – whipped cream $.50, protein $.50)
     
     Milk Shakes (all $3)
     Oreo
     Chocolate
     (modifiers – whipped cream $.50, protein $.50)
     
     Food Items:
     Waffle - $3.50
     (Modifier – powdered sugar, or whipped cream and chocolate – no charge for modifier)
     Jacked Waffle - $4 (comes with almond butter, sliced bananas, pecans, and honey)
     Ferrero Waffle - $4 (comes with Nutella, sliced bananas, and pecans)
     Jacked Toast - $3 (comes with almond butter, sliced bananas, pecans, and honey)
     */
    let smoothiemodifiers = [Modifier.init(name: "Whipped Cream", price: 0.5), Modifier.init(name: "Protein", price: 0.5)]
    let one = Product(name: "Strawberry", price: 3, modifiers: smoothiemodifiers, type: .Smoothie)
    let two = Product(name: "Strawberry Lemonade", price: 3, modifiers: smoothiemodifiers, type: .Smoothie)
    let three = Product(name: "Pineapple", price: 3, modifiers: smoothiemodifiers, type: .Smoothie)
    return [one, two, three]
}

var currentShakes: [Product] {
    
    let shakemodifiers = [Modifier.init(name: "Whipped Cream", price: 0.5), Modifier.init(name: "Protein", price: 0.5)]
    let four = Product(name: "Oreo", price: 3, modifiers: shakemodifiers, type: .Shake)
    let five = Product(name: "Chocolate", price: 3, modifiers: shakemodifiers, type: .Shake)
    
    return [four, five]
}

var currentFoods: [Product] {
    let six = Product(name: "Waffle", price: 3.5, modifiers: [Modifier(name: "Powdered Sugar", price: 0), Modifier(name: "Whipped Cream", price: 0), Modifier(name: "Chocolate", price: 0)], type: .Food)
    let seven = Product(name: "Jacked Waffle", description: "Almond Butter, Sliced Bananas, Pecans, and Honey", price: 4, modifiers: [Modifier(name: "Almond Butter", price: 0), Modifier(name: "Sliced Bananas", price: 0), Modifier(name: "Pecans", price: 0), Modifier(name: "Honey", price: 0)], type: .Food, image: nil)
    let eight = Product(name: "Ferrero Waffle", description: "Nutella, Sliced Bananas, and Pecans", price: 4, modifiers: [Modifier(name: "Nutella", price: 0), Modifier(name: "Sliced Bananas", price: 0), Modifier(name: "Pecans", price: 0)], type: .Food, image: nil)
    let nine = Product(name: "Jacked Toast", description: "Almond Butter, Sliced Bananas, Pecans, and Honey", price: 3, modifiers: [Modifier(name: "Almond Butter", price: 0), Modifier(name: "Sliced Bananas", price: 0), Modifier(name: "Pecans", price: 0), Modifier(name: "Honey", price: 0)], type: .Food, image: nil)
    return [six, seven, eight, nine]
}

struct Order {
    
    var baseProduct: Product!
    var finalPrice: Decimal!
    var modifiers: [Modifier] = []
    var pickUpTime: String!
    var orderName: String! = "No Name"
    var pickUpPlace: String?
    var payed: Bool!
    
    init() {
        
    }
    
}

struct Modifier {
    var price: Decimal!
    var name: String!
    
    init() {
        
    }
    
    init(name: String, price: Decimal) {
        self.name = name
        self.price = price
    }
}

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
}

let times = ["7:30 AM", "7:35 AM", "7:40 AM", "7:45 AM", "7:50 AM", "7:55 AM", "8:00 AM", "8:05 AM", "8:10 AM", "8:15 AM", "8:20 AM", "8:25 AM", "8:30 AM", "8:35 AM", "8:40 AM", "8:45 AM", "8:50 AM", "8:55 AM", "9:00 AM", "9:05 AM", "9:10 AM", "9:15 AM", "9:20 AM", "9:25 AM", "9:30 AM", "9:35 AM", "9:40 AM", "9:45 AM", "9:50 AM", "9:55 AM", "10:00 AM", "10:05 AM", "10:10 AM", "10:15 AM", "10:20 AM", "10:25 AM", "10:30 AM", "1:25 PM", "1:30 PM", "1:35 PM", "1:40 PM", "1:45 PM", "1:50 PM", "1:55 PM", "2:00 PM", "2:05 PM", "2:10 PM", "2:15 PM", "2:20 PM", "2:25 PM", "2:30 PM", "2:35 PM", "2:40 PM", "2:45 PM", "2:50 PM", "2:55 PM", "3:00 PM", "3:05 PM", "3:10 PM", "3:15 PM", "3:20 PM", "3:25 PM", "3:30 PM"]
