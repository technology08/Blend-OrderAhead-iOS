//
//  OrderMenuViewController.swift
//  BlendSmoothieBar
//
//  Created by Connor Espenshade on 10/10/17.
//  Copyright © 2017 Connor Espenshade. All rights reserved.
//

import UIKit

class OrderMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ModifierSwitchDelegate {
    
    @IBOutlet weak var productTypeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var parameterTableView: UITableView!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    var currentProductCategory: ProductTypes = .Smoothie
    var selectedProduct: Product? {
        didSet {
            parameterTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        parameterTableView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
        
        self.tableViewHeightConstraint.constant = self.parameterTableView.contentSize.height
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch currentProductCategory {
        case ProductTypes.Smoothie:
            productTypeLabel.text = "Smoothie"
            selectedProduct = currentSmoothies.first
        case ProductTypes.Shake:
            productTypeLabel.text = "Shake"
            selectedProduct = currentShakes.first
        case ProductTypes.Food:
            productTypeLabel.text = "Breakfast"
            selectedProduct = currentFoods.first
        }
    }
    
    func modifierValueDidChange(modifier: String, price: NSDecimalNumber, value: Bool) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*
         CELLS ARE:
         
         -Flavor (Item for food)
         -Pick-Up Time
         -Pick-Up Location
         -Name
         -Modifiers
         */
        
        if selectedProduct != nil && selectedProduct?.modifierNames != nil { return selectedProduct!.modifierNames!.count + 4} else { return 4 }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let product = selectedProduct else { return tableView.dequeueReusableCell(withIdentifier: "parameterCell")! }
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "parameterCell") as! MenuParameterCell
         
            cell.parameterNameLabel.text = "Flavor"
            cell.parameterValueLabel.text = selectedProduct?.name
            
            return cell
        } else if indexPath.row > 0 && indexPath.row <= (product.modifierNames?.count)! {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "modifierCell") as! MenuModifierCell
            
            guard let modifier = product.modifierNames![indexPath.row - 1] as? String else { return tableView.dequeueReusableCell(withIdentifier: "parameterCell")! }
            
            var modifierText = modifier
            if let productModifierPrice = product.modifierPrices![indexPath.row - 1] as? NSDecimalNumber {
                if productModifierPrice != 0 {
                    modifierText.append(": $\(productModifierPrice)")
                }
                cell.modifierPrice = productModifierPrice
            }
            
            cell.modifierNameLabel.text = modifierText
            cell.modifierName = modifier
            cell.delegate = self
            
            if selectedProduct?.name == "Ferrero Waffle" || selectedProduct?.name == "Jacked Waffle" || selectedProduct?.name == "Jacked Toast" {
                cell.modifierSwitch.setOn(true, animated: false)
            }
            
            return cell
            
        } else {
            var number = Int()
            if product.modifierNames?.count != nil {
                number = indexPath.row - (product.modifierNames?.count)!
            } else {
                number = indexPath.row
            }
            
            switch number {
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "parameterCell") as! MenuParameterCell
                
                cell.parameterNameLabel.text = "Pick-Up Time"
                //ADD TO ADJUST TO TIME OF DAY
                cell.parameterValueLabel.text = "7:45 AM"
                
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "parameterCell") as! MenuParameterCell
                
                cell.parameterNameLabel.text = "Pick-Up Location"
                //ADJUST TO USER PREFERENCES
                cell.parameterValueLabel.text = "Smoothie Bar"
                
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "parameterCell") as! MenuParameterCell
                
                cell.parameterNameLabel.text = "Name"
                //ADJUST TO USER PREFERENCES
                cell.parameterValueLabel.text = ""
                
                return cell
            default:
                print("PROBLEM!")
                return tableView.dequeueReusableCell(withIdentifier: "parameterCell")!
            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

class MenuParameterCell: UITableViewCell {
    
    @IBOutlet weak var parameterNameLabel: UILabel!
    @IBOutlet weak var parameterValueLabel: UILabel!
    
}

class MenuModifierCell: UITableViewCell {
    @IBOutlet weak var modifierNameLabel: UILabel!
    @IBOutlet weak var modifierSwitch: UISwitch!
    
    var delegate: ModifierSwitchDelegate? = nil
    var modifierName: String!
    var modifierPrice: NSDecimalNumber!
    
    @IBAction func switchChanged(_ sender: Any) {
        
        if (delegate != nil) {
            delegate?.modifierValueDidChange(modifier: self.modifierName, price: self.modifierPrice, value: modifierSwitch.isOn)
        }
        
    }
    
}

protocol ModifierSwitchDelegate {
    func modifierValueDidChange(modifier: String, price: NSDecimalNumber, value: Bool)
}
