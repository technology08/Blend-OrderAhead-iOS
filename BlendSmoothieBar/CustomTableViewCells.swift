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
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
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
        case "Drinks":
            return currentDrinks.count
        case "Ice Cream & Sweets":
            return currentIceCream.count
        case "Food":
            return currentFoods.count
        default:
            return 0
        }
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        guard let productType = product?.type else { return nil }
        
        switch productType {
        case "Smoothies":
            let string = currentSmoothies[row].name
            
            let attributedString = NSAttributedString(string: string!, attributes: [NSAttributedStringKey.foregroundColor : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
            
            return attributedString
        case "Drinks":
            let string = currentDrinks[row].name
            
            let attributedString = NSAttributedString(string: string!, attributes: [NSAttributedStringKey.foregroundColor : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
            
            return attributedString
        case "Ice Cream & Sweets":
            let string = currentIceCream[row].name
            
            let attributedString = NSAttributedString(string: string!, attributes: [NSAttributedStringKey.foregroundColor : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
            
            return attributedString
        case "Food":
            let string = currentFoods[row].name
            
            let attributedString = NSAttributedString(string: string!, attributes: [NSAttributedStringKey.foregroundColor : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
            
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
            case  "Drinks":
                returnedProduct = currentDrinks[row]
            case "Ice Cream & Sweets":
                returnedProduct = currentIceCream[row]
            case "Food":
                returnedProduct = currentFoods[row]
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
            case "Drinks":
                returnedProduct = currentDrinks[row]
            case "Ice Cream & Sweets":
                returnedProduct = currentIceCream[row]
            case "Food":
                returnedProduct = currentFoods[row]
            default:
                fatalError("User selected product: Does not fall in a category.")
            }
            
            delegate?.flavorSelected(productRow: returnedProduct, remainShowing: true)
        }
    }
    
}

class TimeCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var picker: UIPickerView!
    
    var delegate: ParameterReturnDelegate? = nil
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return times.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        
        let string = times[row]
        
        let attributedString = NSAttributedString(string: string, attributes: [NSAttributedStringKey.foregroundColor : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
        
        return attributedString
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if delegate != nil {
            
            
            delegate?.time(time: times[picker.selectedRow(inComponent: 0)], remainShowing: true)
        }
    }
    
    @IBAction func donePressed(_ sender: Any) {
        if delegate != nil {
            delegate?.time(time: times[picker.selectedRow(inComponent: 0)], remainShowing: false)
        }
    }
}

class NameCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    
    var delegate: ParameterReturnDelegate? = nil
    
    let userDefaults = UserDefaults.standard
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.attributedPlaceholder = NSAttributedString(string: "Tap here to enter your name...", attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
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
    var places = ["Smoothie Bar", "Coffee Bar"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        if row == 0 {
            return NSAttributedString(string: "Smoothie Bar", attributes: [.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
        } else if row == 1 {
            return NSAttributedString(string: "Coffee Bar", attributes: [.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
        } else {
            return nil
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if delegate != nil {
            delegate?.locationChanged(location: places[row], remainShowing: true)
        }
    }
    
    @IBAction func donePressed(_ sender: Any) {
        if delegate != nil {
            delegate?.locationChanged(location: places[picker.selectedRow(inComponent: 0)], remainShowing: false)
        }
        
    }
    
}
