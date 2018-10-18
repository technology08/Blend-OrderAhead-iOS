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

enum Business: Int {
    case Blend = 0
    case LeaningEagle = 1
}

var currentSmoothies: [Product] = []
var currentIceCream: [Product] = []
