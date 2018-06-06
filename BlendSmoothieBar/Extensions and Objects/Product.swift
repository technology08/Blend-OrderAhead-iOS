//
//  Product.swift
//  BlendSmoothieBar
//
//  Created by Connor Espenshade on 10/7/17.
//  Copyright © 2017 Connor Espenshade. All rights reserved.
//

import CloudKit
import UIKit

struct Product: Codable {
    var name: String = ""
    var modifiers: [Modifier] = []
    var price: Decimal = 0
    var type: String = "Smoothies"
    
    init(name: String, type: String) {
        self.name = name
        self.type = type
    }
    
    init(name: String, price: Decimal, type: String) {
        self.name = name
        self.type = type
        self.price = price
    }
    
    init(name: String, price: Decimal, modifiers: [Modifier], type: String) {
        self.name = name
        self.price = price
        self.modifiers = modifiers
        self.type = type
    }
}

struct ModifierArray: Codable {
    var array: [Modifier]!
    
    init(array: [Modifier]) {
        self.array = array
    }
}

struct Order {
    
    var baseProduct: Product!
    var finalPrice: Decimal!
    var modifiers: [Modifier] = []
    var pickUpTime: String!
    var orderName = "No Name"
    var pickUpPlace: String? 
    var specialInstructions: String?
    var payed: Bool = false
    var sortDate = Int()
    
    init() {
        
    }
    
}

struct Modifier:Codable {
    var price: Decimal!
    var name: String!
    
    init() {
        
    }
    
    init(name: String, price: Decimal) {
        self.name = name
        self.price = price
    }
}

var currentSmoothies: [Product] = []/*{
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
    let one = Product(name: "Strawberry", price: 3, modifiers: smoothiemodifiers, type: "Smoothie")
    let two = Product(name: "Strawberry Lemonade", price: 3, modifiers: smoothiemodifiers, type: "Smoothie")
    let three = Product(name: "Pineapple", price: 3, modifiers: smoothiemodifiers, type: "Smoothie")
    return [one, two, three]
}*/
var currentDrinks: [Product] = []
var currentIceCream: [Product] = []/*{
    
    let shakemodifiers = [Modifier.init(name: "Whipped Cream", price: 0.5), Modifier.init(name: "Protein", price: 0.5)]
    let four = Product(name: "Oreo", price: 3, modifiers: shakemodifiers, type: "Ice Cream & Sweets")
    let five = Product(name: "Chocolate", price: 3, modifiers: shakemodifiers, type: "Ice Cream & Sweets")
    
    return [four, five]
}*/

var currentFoods: [Product] = [] /*{
    let six = Product(name: "Waffle", price: 3.5, modifiers: [Modifier(name: "Powdered Sugar", price: 0), Modifier(name: "Whipped Cream", price: 0), Modifier(name: "Chocolate", price: 0)], type: "Food")
    return [six]
}*/
