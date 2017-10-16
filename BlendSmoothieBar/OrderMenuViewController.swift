//
//  OrderMenuViewController.swift
//  BlendSmoothieBar
//
//  Created by Connor Espenshade on 10/10/17.
//  Copyright © 2017 Connor Espenshade. All rights reserved.
//

import UIKit
import PassKit
import Stripe
import AWSLambda

class OrderMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ModifierSwitchDelegate, PKPaymentAuthorizationViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    @IBOutlet weak var productTypeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var parameterTableView: UITableView!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    var applePayButton: UIButton?
    var currentProductCategory: ProductTypes = .Smoothie
    var selectedProduct: Product? {
        didSet {
            parameterTableView.reloadData()
            priceLabel.text = "$\(selectedProduct?.price! ?? 3)"
        }
    }
    
    var order = Order() {
        didSet {
            parameterTableView.reloadData()
            priceLabel.text = "$\(order.finalPrice ?? 3)"
        }
    }
    
    @IBOutlet var addMoreItemsButton: UIButton!
    @IBOutlet var cashButton: UIButton!
    @IBOutlet var cashButtonTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var cashButtonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var cashButtonBottomConstraint: NSLayoutConstraint!
    
    var supportedNetworks: [PKPaymentNetwork] {
        
        if #available(iOS 10.1, *) {
            return [.visa, .masterCard, .amex, .discover, .JCB]
        } else {
            // Fallback on earlier versions
            return [.visa, .masterCard, .amex, .discover]
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
        
        if PKPaymentAuthorizationViewController.canMakePayments() {
            if #available(iOS 10.0, *) {
                applePayButton = PKPaymentButton(paymentButtonType: .inStore, paymentButtonStyle: .white)
            } else {
                // Fallback on earlier versions
                applePayButton = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .white)
            }
            applePayButton?.addTarget(self, action: #selector(applePayButtonPressed), for: .touchUpInside)
            applePayButton?.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(applePayButton!)
            
            cashButtonTrailingConstraint.isActive = false
            cashButtonLeadingConstraint.constant = 8
            cashButtonBottomConstraint.constant = 8
            cashButton.layer.cornerRadius = 5

            let leadingConstraint = applePayButton?.leadingAnchor.constraint(equalTo: cashButton.trailingAnchor, constant: 8)
            let trailingConstraint = applePayButton?.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -8)
            let bottomConstraint = applePayButton?.bottomAnchor.constraint(equalTo: addMoreItemsButton.topAnchor, constant: -8)
            let equalWidths = applePayButton?.widthAnchor.constraint(equalTo: cashButton.widthAnchor)
            let height = applePayButton?.heightAnchor.constraint(equalToConstant: 44)
            
            NSLayoutConstraint.activate([leadingConstraint!, trailingConstraint!, bottomConstraint!, equalWidths!, height!])
            
        } else {
            //Extend cash button full width
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch currentProductCategory {
        case ProductTypes.Smoothie:
            productTypeLabel.text = "Smoothie"
            order.baseProduct = currentSmoothies.first
            order.finalPrice = currentSmoothies.first?.price
            visualEffectView.effect = UIBlurEffect(style: .dark)
            backgroundImageView.image = #imageLiteral(resourceName: "smoothie")
        case ProductTypes.Shake:
            productTypeLabel.text = "Shake"
            order.baseProduct = currentShakes.first
            order.finalPrice = currentShakes.first?.price
            visualEffectView.effect = UIBlurEffect(style: .dark)
            backgroundImageView.image = #imageLiteral(resourceName: "shake")
        case ProductTypes.Food:
            productTypeLabel.text = "Breakfast"
            order.baseProduct = currentFoods.first
            order.finalPrice = currentFoods.first?.price
            visualEffectView.effect = UIBlurEffect(style: .dark)
            backgroundImageView.image = #imageLiteral(resourceName: "waffle")
        }
        
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
        
        if order.baseProduct != nil && order.baseProduct.modifierNames != nil { return order.baseProduct.modifierNames!.count + 4} else { return 4 }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let product = order.baseProduct else { return tableView.dequeueReusableCell(withIdentifier: "parameterCell")! }
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "parameterCell") as! MenuParameterCell
         
            cell.parameterNameLabel.text = "Flavor"
            cell.parameterValueLabel.text = order.baseProduct.name
            
            return cell
        } else if indexPath.row > 0 && indexPath.row <= (product.modifierNames?.count)! {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "modifierCell") as! MenuModifierCell
            
            guard let modifier = product.modifierNames![indexPath.row - 1] as? String else { return tableView.dequeueReusableCell(withIdentifier: "parameterCell")! }
            
            var modifierText = modifier
            if let productModifierPrice = product.modifierPrices![indexPath.row - 1] as? Decimal {
                if productModifierPrice != 0 {
                    modifierText.append(": $\(productModifierPrice)")
                }
                cell.modifierPrice = productModifierPrice
            }
            
            cell.modifierNameLabel.text = modifierText
            cell.modifierName = modifier
            cell.delegate = self
            
            if order.baseProduct.name == "Ferrero Waffle" || order.baseProduct.name == "Jacked Waffle" || order.baseProduct.name == "Jacked Toast" {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func modifierValueDidChange(modifier: String, price: Decimal, value: Bool) {
        
        switch value {
        case true:
            order.modifiers?.append(modifier)
            order.finalPrice = order.finalPrice + price
        case false:
            if (order.modifiers?.contains(modifier))! {
                let index = order.modifiers?.index(of: modifier)
                order.modifiers?.remove(at: index!)
                order.finalPrice = order.finalPrice - price
            }
        }
        
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @available(iOS 9.0, *)
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        
        
    }
    
    @available(iOS 11.0, *)
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        
        STPAPIClient.shared().createToken(with: payment) { (token: STPToken?, error: Error?) in
            
            guard let token = token, error != nil else { return }
            
            
            
        }
        
    }
    
    @objc func applePayButtonPressed() {
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: supportedNetworks) {
            let request = PKPaymentRequest()
            request.merchantIdentifier = "INSERT_APPLE_MERCHANT_ID"
            request.countryCode = "US"
            request.currencyCode = "USD"
            request.supportedNetworks = supportedNetworks
            request.merchantCapabilities = .capability3DS //CHECK WITH STRIPE
            
            let item = PKPaymentSummaryItem(label: "\(order.baseProduct.name!) \(order.baseProduct.type)", amount: NSDecimalNumber(decimal: order.baseProduct.price))
            request.paymentSummaryItems = [item]
            
            let vc = PKPaymentAuthorizationViewController(paymentRequest: request)
            vc?.delegate = self
            present(vc!, animated: true, completion: nil)
        } else {
            //CHECK COPYRIGHT
            let alert = UIAlertController(title: "Apple Pay Error", message: "No supported cards. Only Visa, Mastercard, American Express, and Discover cards are valid.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
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
    
    // MARK: - Text Field/Text View Delegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.endEditing(true)
        textField.resignFirstResponder()
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    // MARK: - Backend Function
    
    func sendToBackend(token: STPToken, amount: Decimal) {
        let lambdaInvoker = AWSLambdaInvoker.default()
        let jsonObject: [String: Any] = ["tokenId": token.tokenId, "amount": amount]
        
        lambdaInvoker.invokeFunction("CreateStripe", jsonObject: jsonObject)
    }
    
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
    var modifierPrice: Decimal!
    
    @IBAction func switchChanged(_ sender: Any) {
        
        if (delegate != nil) {
            delegate?.modifierValueDidChange(modifier: self.modifierName, price: self.modifierPrice, value: modifierSwitch.isOn)
        }
        
    }
    
}

protocol ModifierSwitchDelegate {
    func modifierValueDidChange(modifier: String, price: Decimal, value: Bool)
}
