//
//  CustomTableViewCells.swift
//  BlendSmoothieBar
//
//  Created by Connor Espenshade on 10/30/17.
//  Copyright © 2017 Connor Espenshade. All rights reserved.
//

import UIKit

protocol ParameterReturnDelegate {
    func modifierValueDidChange(modifier: Modifier, value: Bool)
    func flavorSelected(productRow: Product, remainShowing: Bool)
    func time(time: String, remainShowing: Bool)
    func nameEntered(name: String)
    func locationChanged(location: String, remainShowing: Bool)
    func sizeChanged(size: String, price: Decimal)
}

class MenuParameterCell: UITableViewCell {
    
    @IBOutlet weak var parameterNameLabel: UILabel!
    @IBOutlet weak var parameterValueLabel: UILabel!
    
}

class MenuModifierCell: UITableViewCell {
    @IBOutlet weak var modifierNameLabel: UILabel!
    @IBOutlet weak var modifierSwitch: UISwitch!
    
    var delegate: ParameterReturnDelegate? = nil
    var modifier: Modifier!
    
    @IBAction func switchChanged(_ sender: Any) {
        
        if (delegate != nil) {
            delegate?.modifierValueDidChange(modifier: self.modifier, value: modifierSwitch.isOn)
        }
        
    }
    
}

class FlavorPickerTableViewCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var picker: UIPickerView!
    
    var product: Product? {
        didSet {
            picker.reloadAllComponents()
        }
    }
    
    var delegate: ParameterReturnDelegate? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let productType = product?.type else { return 0 }
        
        switch productType {
        case "Smoothies":
            return currentSmoothies.count
        case "Ice Cream & Sweets":
            return currentIceCream.count
        case "Espresso":
            return currentEspresso.count
        case "Tea":
            return currentTea.count
        case "Cold Brew":
            return currentCold.count
        case "Non-Coffee":
            return currentNonCoffee.count
        default:
            return 0
        }
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        guard let productType = product?.type else { return nil }
        
        switch productType {
        case "Smoothies":
            let string = currentSmoothies[row].name
            
            let attributedString = NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
            
            return attributedString
        case "Ice Cream & Sweets":
            let string = currentIceCream[row].name
            
            let attributedString = NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
            
            return attributedString
        case "Espresso":
            let string = currentEspresso[row].name
            
            let attributedString = NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
            
            return attributedString
        case "Tea":
            let string = currentTea[row].name
            
            let attributedString = NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
            
            return attributedString
        case "Cold Brew":
            let string = currentCold[row].name
            
            let attributedString = NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
            
            return attributedString
        case "Non-Coffee":
            let string = currentNonCoffee[row].name
            
            let attributedString = NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
            
            return attributedString
        default:
            return nil
        }
        
    }
    @IBAction func donePressed(_ sender: Any) {
        
        if (delegate != nil) {
            let row = picker.selectedRow(inComponent: 0)
            
            var returnedProduct: Product!
            
            guard let productType = product?.type else { return }
            
            switch productType {
            case "Smoothies":
                returnedProduct = currentSmoothies[row]
            case "Ice Cream & Sweets":
                returnedProduct = currentIceCream[row]
            case "Espresso":
                returnedProduct = currentEspresso[row]
            case "Tea":
                returnedProduct = currentTea[row]
            case "Cold Brew":
                returnedProduct = currentCold[row]
            case "Non-Coffee":
                returnedProduct = currentNonCoffee[row]
            default:
                fatalError("Return Product not a category")
            }
            
            delegate?.flavorSelected(productRow: returnedProduct, remainShowing: false)
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (delegate != nil) {
            let row = picker.selectedRow(inComponent: 0)
            
            var returnedProduct: Product!
            
            guard let productType = product?.type else { return }
            
            switch productType {
            case "Smoothies":
                returnedProduct = currentSmoothies[row]
            case "Ice Cream & Sweets":
                returnedProduct = currentIceCream[row]
            case "Espresso":
                returnedProduct = currentEspresso[row]
            case "Tea":
                returnedProduct = currentTea[row]
            case "Cold Brew":
                returnedProduct = currentCold[row]
            case "Non-Coffee":
                returnedProduct = currentNonCoffee[row]
            default:
                fatalError("User selected product: Does not fall in a category.")
            }
            
            delegate?.flavorSelected(productRow: returnedProduct, remainShowing: true)
        }
    }
    
}

class TimeCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var picker: UIPickerView!
    var business: Business = .Blend
    
    var delegate: ParameterReturnDelegate? = nil
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch business {
        case .Blend:
            return times.count
        case .LeaningEagle:
            return coffeeBarTimes.count
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        switch business {
        case .Blend:
            let string = times[row]
            
            let attributedString = NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
            
            return attributedString
        case .LeaningEagle:
            let string = coffeeBarTimes[row]
            
            let attributedString = NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
            
            return attributedString
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if delegate != nil {
            
            switch business {
            case .Blend:
                delegate?.time(time: times[picker.selectedRow(inComponent: 0)], remainShowing: true)
            case .LeaningEagle:
                delegate?.time(time: coffeeBarTimes[picker.selectedRow(inComponent: 0)], remainShowing: true)
            }
            
        }
    }
    
    @IBAction func donePressed(_ sender: Any) {
        if delegate != nil {
            switch business {
            case .Blend:
                delegate?.time(time: times[picker.selectedRow(inComponent: 0)], remainShowing: false)
            case .LeaningEagle:
                delegate?.time(time: coffeeBarTimes[picker.selectedRow(inComponent: 0)], remainShowing: false)
            }
        }
    }
}

class NameCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    
    var delegate: ParameterReturnDelegate? = nil
    
    let userDefaults = UserDefaults.standard
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.attributedPlaceholder = NSAttributedString(string: "Enter your name here...", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
        textField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        returnName()
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        returnName()
        textField.resignFirstResponder()
        return true
        
    }
    
    func returnName() {
        if delegate != nil {
            delegate?.nameEntered(name: self.textField.text!)
        }
    }
}

class LocationPickerCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var picker: UIPickerView!
    
    var delegate: ParameterReturnDelegate? = nil
    var business: Business = .Blend
    var places = ["Smoothie Bar", "Coffee Bar", "Library"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return places.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        switch business {
        case .Blend:
            if row == 0 {
                return NSAttributedString(string: "Smoothie Bar", attributes: [.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
            } else if row == 1 {
                return NSAttributedString(string: "Coffee Bar", attributes: [.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
            } else if row == 2 {
                return NSAttributedString(string: "Library", attributes: [.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
            } else {
                return nil
            }
        case .LeaningEagle:
            if row == 1 {
                return NSAttributedString(string: "Smoothie Bar", attributes: [.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
            } else if row == 0 {
                return NSAttributedString(string: "Coffee Bar", attributes: [.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
            } else if row == 2 {
                return NSAttributedString(string: "Library", attributes: [.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
            } else {
                return nil
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if delegate != nil {
            switch business {
            case .Blend:
                delegate?.locationChanged(location: places[row], remainShowing: true)
            case .LeaningEagle:
                switch row {
                case 0:
                    delegate?.locationChanged(location: "Coffee Bar", remainShowing: true)
                case 1:
                    delegate?.locationChanged(location: "Smoothie Bar", remainShowing: true)
                case 2:
                    delegate?.locationChanged(location: "Library", remainShowing: true)
                default:
                    delegate?.locationChanged(location: "Coffee Bar", remainShowing: true)
                }
            }
        }
    }
    
    @IBAction func donePressed(_ sender: Any) {
        if delegate != nil {
            switch business {
            case .Blend:
                delegate?.locationChanged(location: places[picker.selectedRow(inComponent: 0)], remainShowing: false)
            case .LeaningEagle:
                switch picker.selectedRow(inComponent: 0) {
                case 0:
                    delegate?.locationChanged(location: "Coffee Bar", remainShowing: false)
                case 1:
                    delegate?.locationChanged(location: "Smoothie Bar", remainShowing: false)
                case 2:
                    delegate?.locationChanged(location: "Library", remainShowing: false)
                default:
                    delegate?.locationChanged(location: "Coffee Bar", remainShowing: false)
                }
            }
        }
        
    }
    
}

class SizeSegmentedCell: UITableViewCell {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var delegate: ParameterReturnDelegate? = nil
    private var sizeNames: [String] = []
    private var sizePrices: [Decimal] = []
    
    public func configure(delegate: ParameterReturnDelegate, sizeNames: [String], sizePrices: [Decimal], theme: Business) {
        
        self.delegate = delegate
        self.sizeNames = sizeNames
        self.sizePrices = sizePrices
        
        let selectedSegment = segmentedControl.selectedSegmentIndex
        
        segmentedControl.removeAllSegments()
        for (index, size) in sizeNames.enumerated() {
            let price = sizePrices[index]
            if price > 0 {
                segmentedControl.insertSegment(withTitle: "\(size) + $\(price)", at: index, animated: false)
            } else {
                segmentedControl.insertSegment(withTitle: "\(size)", at: index, animated: false)
            }
        }
        
        if selectedSegment == -1 {
            // Index not selected
            segmentedControl.selectedSegmentIndex = 0
        } else {
            segmentedControl.selectedSegmentIndex = selectedSegment
        }
        segmentedControl.tintColor = UIColor.white
    }
    
    @IBAction func sizeChanged(_ sender: Any) {
        delegate?.sizeChanged(size: sizeNames[segmentedControl.selectedSegmentIndex], price: sizePrices[segmentedControl.selectedSegmentIndex])
    }
    
}
