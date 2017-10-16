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
    var modifierNames: [String]?
    var modifierPrices: [Decimal]?
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
    
    init(name: String, price: Decimal, modifierNames: [String], modifierPrices: [Decimal], type: ProductTypes) {
        self.name = name
        self.price = price
        self.modifierNames = modifierNames
        self.modifierPrices = modifierPrices
        self.type = type
    }
    
    init(name: String, description: String?, price: Decimal, modifierNames: [String], modifierPrices: [Decimal]?, type: ProductTypes, image: UIImage?) {
        self.name = name
        self.description = description
        self.price = price
        self.modifierNames = modifierNames
        self.modifierPrices = modifierPrices
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
    
    let one = Product(name: "Strawberry", price: 3, modifierNames: ["Whipped Cream", "Protein"], modifierPrices: [0.5, 0.5], type: .Smoothie)
    let two = Product(name: "Strawberry Lemonade", price: 3, modifierNames: ["Whipped Cream", "Protein"], modifierPrices: [0.5, 0.5], type: .Smoothie)
    let three = Product(name: "Pineapple", price: 3, modifierNames: ["Whipped Cream", "Protein"], modifierPrices: [0.5, 0.5], type: .Smoothie)
    return [one, two, three]
}

var currentShakes: [Product] {
    
    let four = Product(name: "Oreo", price: 3, modifierNames: ["Whipped Cream", "Protein"], modifierPrices: [0.5, 0.5], type: .Shake)
    let five = Product(name: "Chocolate", price: 3, modifierNames: ["Whipped Cream", "Protein"], modifierPrices: [0.5, 0.5], type: .Shake)
    
    return [four, five]
}

var currentFoods: [Product] {
    let six = Product(name: "Waffle", price: 3.5, modifierNames: ["Powdered Sugar", "Whipped Cream", "Chocolate"], modifierPrices: [0, 0, 0], type: .Food)
    let seven = Product(name: "Jacked Waffle", description: "Almond Butter, Sliced Bananas, Pecans, and Honey", price: 4, modifierNames: ["Almond Butter", "Sliced Bananas", "Pecans", "Honey"], modifierPrices: [0, 0, 0, 0], type: .Food, image: nil)
    let eight = Product(name: "Ferrero Waffle", description: "Nutella, Sliced Bananas, and Pecans", price: 4, modifierNames: ["Nutella", "Sliced Bananas", "Pecans"], modifierPrices: [0, 0, 0], type: .Food, image: nil)
    let nine = Product(name: "Jacked Toast", description: "Almond Butter, Sliced Bananas, Pecans, and Honey", price: 3, modifierNames: ["Almond Butter", "Sliced Bananas", "Pecans", "Honey"], modifierPrices: [0, 0, 0, 0], type: .Food, image: nil)
    return [six, seven, eight, nine]
}

struct Order {
    
    var baseProduct: Product!
    var finalPrice: Decimal!
    var modifiers: [String]?
    
    init() {
        
    }
    
}
