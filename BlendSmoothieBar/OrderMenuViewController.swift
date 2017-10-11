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
    
    var category: ProductTypes!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
