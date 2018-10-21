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
    var sizes: [Modifier] = []
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
    
    init(name: String, price: Decimal, modifiers: [Modifier], sizes: [Modifier], type: String) {
        self.name = name
        self.price = price
        self.modifiers = modifiers
        self.sizes = sizes
        self.type = type
    }
    
    init(name: String, price: Decimal, sizes: [Modifier], type: String) {
        self.name = name
        self.price = price
        self.sizes = sizes
        self.type = type
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
    var selectedSize: String? = nil
    var sizeUpgradePrice: Decimal?
    var payed: Bool = false
    var sortDate = Int()
    
    init() {
        
    }
    
}
/**
 Used for both sizes and modifiers.
*/
struct Modifier: Codable {
    var price: Decimal!
    var name: String!
    
    init() {
        
    }
    
    init(name: String, price: Decimal) {
        self.name = name
        self.price = price
    }
}

struct ModifierArray: Codable {
    var array: [Modifier]!
    
    init(array: [Modifier]) {
        self.array = array
    }
}

enum Business: Int {
    case Blend = 0
    case LeaningEagle = 1
}

var currentSmoothies: [Product] = []
var currentIceCream:  [Product] = []
var currentEspresso:  [Product] = []
var currentTea:       [Product] = []
var currentCold:      [Product] = []
var currentNonCoffee: [Product] = []
