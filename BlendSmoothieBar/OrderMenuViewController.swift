//
//  OrderMenuViewController.swift
//  BlendSmoothieBar
//
//  Created by Connor Espenshade on 10/10/17.
//  Copyright © 2017 Connor Espenshade. All rights reserved.
//

import UIKit
import PassKit
import CloudKit
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
    public var selectedProduct: Product? {
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
        
        if order.baseProduct != nil {
            return order.baseProduct.modifiers.count + 4
        } else {
            return 4
        }
    }
    
    var index1Shown = false {
        didSet {
            parameterTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            
            switch index1Shown {
            case true:
                //UIView.animate(withDuration: 0.75, delay: 0, options: [.curveEaseOut], animations: {
                    return 200
                //}, completion: nil)
            case false:
                //UIView.animate(withDuration: 0.75, delay: 0, options: [.curveEaseOut], animations: {
                    return 0
                //}, completion: nil)
            }
            
            
        } else {
            return 44
        }
        return 44
    }
    
    func showPicker(tableView: UITableView) {
        tableView.beginUpdates()
        tableView.endUpdates()
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let product = order.baseProduct else { return tableView.dequeueReusableCell(withIdentifier: "parameterCell")! }
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "parameterCell") as! MenuParameterCell
            
            cell.parameterNameLabel.text = "Flavor"
            cell.parameterValueLabel.text = order.baseProduct.name
            
            return cell
        } else if indexPath.row == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "pickerCell") as! FlavorPickerTableViewCell
            
            cell.product = order.baseProduct
            
            return cell
        
        } else if indexPath.row > 1 && indexPath.row <= product.modifiers.count + 1{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "modifierCell") as! MenuModifierCell
            
            let modifier = product.modifiers[indexPath.row - 2]
            
            var modifierText = modifier.name
            
            if modifier.price != 0 {
                modifierText?.append(": $\(modifier.price!)")
            }
            
            cell.modifierNameLabel.text = modifierText
            cell.modifier = modifier
            cell.delegate = self
            
            if order.baseProduct.name == "Ferrero Waffle" || order.baseProduct.name == "Jacked Waffle" || order.baseProduct.name == "Jacked Toast" {
                cell.modifierSwitch.setOn(true, animated: false)
            }
            
            return cell
            
        } else {
            
            let number = (indexPath.row - (product.modifiers.count)) + 1
            
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
        
        if indexPath.row == 0 {
            
            switch index1Shown {
            case true:
                index1Shown = false
            case false:
                index1Shown = true
            }
        }
        
        if indexPath.row > 1 && indexPath.row <= order.baseProduct.modifiers.count + 1 {
            tableView.deselectRow(at: indexPath, animated: false)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func modifierValueDidChange(modifier: Modifier, value: Bool) {
        switch value {
        case true:
            order.modifiers.append(modifier)
            order.finalPrice = order.finalPrice + modifier.price
        case false:
            if let index2 = order.modifiers.index(where: { (modifier) -> Bool in
                return true
            }) {
                order.modifiers.remove(at: index2)
            }
            
            order.finalPrice = order.finalPrice - modifier.price
            
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        
        STPAPIClient.shared().createToken(with: payment) { (token: STPToken?, error: Error?) in
            if error == nil {
                guard let token = token else {
                    completion(PKPaymentAuthorizationStatus.failure)
                    
                    print("Failure to create token")
                    
                    return
                }
                guard let orderprice = self.order.finalPrice else {
                    completion(PKPaymentAuthorizationStatus.failure)
                    print("Failure to find order price")
                    return
                }
                
                let secondprice = orderprice * 100
                let stripeprice = NSDecimalNumber(decimal: secondprice).intValue
                
                self.sendToBackendResult(token: token, amount: stripeprice, completion: { (status) -> Void in
                    
                    //CALL CLOUDKIT AND CHECK FOR COMPLETION, AS WELL AS SHOW CONFIRMATION IF APPLICABLE
                    completion(status)
                    
                })
                
            } else {
                print(error!)
            }
        }
        
    }
    
    @objc func applePayButtonPressed() {
        //if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: supportedNetworks) {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "INSERT_APPLE_MERCHANT_ID"
        request.countryCode = "US"
        request.currencyCode = "USD"
        request.supportedNetworks = supportedNetworks
        request.merchantCapabilities = .capability3DS //CHECK WITH STRIPE
        
        let baseItem = PKPaymentSummaryItem(label: "\(order.baseProduct.name!) \(order.baseProduct.type!)", amount: NSDecimalNumber(decimal: order.baseProduct.price))
        
        request.paymentSummaryItems = [baseItem]
        
        for modifier in order.modifiers {
            let paymentitem = PKPaymentSummaryItem(label: modifier.name!, amount: NSDecimalNumber(decimal: modifier.price!))
            request.paymentSummaryItems.append(paymentitem)
        }
        
        let finalitem = PKPaymentSummaryItem(label: "BLEND SMOOTHIE BAR", amount: NSDecimalNumber(decimal: order.finalPrice!))
        request.paymentSummaryItems.append(finalitem)
        
        let vc = PKPaymentAuthorizationViewController(paymentRequest: request)
        vc?.delegate = self
        present(vc!, animated: true, completion: nil)
        /*} else {
         //CHECK COPYRIGHT
         let alert = UIAlertController(title: "Apple Pay Error", message: "No supported cards. Only Visa, Mastercard, American Express, and Discover cards are valid.", preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (action) in
         alert.dismiss(animated: true, completion: nil)
         }))
         self.present(alert, animated: true, completion: nil)
         }*/
        
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
    
    func sendToBackendResult(token: STPToken, amount: Int, completion: @escaping ((PKPaymentAuthorizationStatus) -> Void)) {
        
        let lambdaInvoker = AWSLambdaInvoker.default()
        let jsonObject: [String: Any] = ["tokenId": token.tokenId, "amount": amount]
        
        print("About to invoke lambda.")
        
        let _ = lambdaInvoker.invokeFunction("CreateStripe", jsonObject: jsonObject).continueWith { (task) -> Any? in
            
            if let error = task.error as NSError? {
                if error.domain == AWSLambdaInvokerErrorDomain && AWSLambdaInvokerErrorType.functionError == AWSLambdaInvokerErrorType(rawValue: error.code) {
                    print("Function error: \(error.userInfo[AWSLambdaInvokerFunctionErrorKey] ?? "Unknown")")
                    completion(.failure)
                } else {
                    print("Error: \(error)")
                    completion(.failure)
                }
                
            } else if let response = task.result! as? String {
                
                //SUCCESS
                if response == "Charge processed successfully!" {
                    
                    completion(.success)
                    //API ERRORS
                } else if response == "StripeInvalidRequestError" {
                    
                    DispatchQueue.main.async {
                        self.createErrorAlert(alertBody: "The payment request was invalid. Please try again or pay in cash at pickup.", presentTryAgain: true)
                    }
                    completion(.failure)
                } else if response == "api_connection_error" || response == "StripeApiConnectionError" {
                    
                    DispatchQueue.main.async {
                        self.createErrorAlert(alertBody: "Bad internet connection. Please check your internet settings and try again.", presentTryAgain: true)
                    }
                    completion(.failure)
                } else if response == "rate_limit_error" || response == "StripeRateLimitError" || response == "authentication_error" || response == "StripeAuthenticationError" {
                    
                    DispatchQueue.main.async {
                        self.createErrorAlert(alertBody: "Bad connection to server. Please try again.", presentTryAgain: true)
                    }
                    
                    completion(.failure)
                    //CARD ERRORS
                } else if response == "invalid_number" || response == "StripeInvalidNumber" || response == "incorrect_number" || response == "StripeIncorrectNumber" {
                    
                    DispatchQueue.main.async {
                        self.createErrorAlert(alertBody: "Invalid credit card number.", presentTryAgain: false)
                    }
                    
                    completion(.failure)
                } else if response == "invalid_expiry_month" || response == "StripeExpiryMonth" || response == "invalid_expiry_year" || response == "StripeExpiryYear"{
                    
                    DispatchQueue.main.async {
                        self.createErrorAlert(alertBody: "Invalid expiration date.", presentTryAgain: false)
                    }
                    
                    completion(.failure)
                } else if response == "invalid_cvc" || response == "StripeInvalidCvc" || response == "incorrect_cvc" || response == "StripeIncorrectCvc"{
                    
                    DispatchQueue.main.async {
                        self.createErrorAlert(alertBody: "Invalid security code.", presentTryAgain: false)
                    }
                    
                    completion(.failure)
                } else if response == "card_declined" || response == "StripeCardDecline" {
                    
                    DispatchQueue.main.async {
                        self.createErrorAlert(alertBody: "The credit card used was declined by the issuer.", presentTryAgain: true)
                    }
                    
                    completion(.failure)
                } else if response == "expired_card" || response == "StripeExpiredCard" {
                    
                    DispatchQueue.main.async {
                        self.createErrorAlert(alertBody: "The credit card used is expired.", presentTryAgain: false)
                    }
                    
                    completion(.failure)
                } else if response == "processing_error" || response == "StripeProcessingError" {
                    
                    DispatchQueue.main.async {
                        self.createErrorAlert(alertBody: "There was an error during processing.", presentTryAgain: true)
                    }
                    
                    completion(.failure)
                } else {
                    DispatchQueue.main.async {
                        self.createErrorAlert(alertBody: "Unknown error was \(response).", presentTryAgain: true)
                    }
                    
                    completion(.failure)
                }
                
            } else {
                print("No response")
                completion(.failure)
            }
            return nil
        }
    }
    
    func createErrorAlert(alertBody: String, presentTryAgain: Bool) {
        let alert = UIAlertController(title: "Error", message: alertBody, preferredStyle: .alert)
        if presentTryAgain {
            alert.addAction(UIAlertAction(title: "Try Again", style: .cancel, handler: { (action) in
                self.applePayButtonPressed()
            }))
        }
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    var orderCounter = 0
    
    func createOrder(order: Order, payed: Bool, completion: @escaping ((Bool) -> Void)) {
        
        let record = CKRecord(recordType: "Order")
        record["item"] = order.baseProduct.name + " " + String(describing: order.baseProduct.type) as CKRecordValue
        //record["pickuptime"] = order.pickuptime as? CKRecordValue
        //record["name"] = order.ordername as? CKRecordValue
        var modifiers: [String] = []
        for modifier in order.modifiers {
            modifiers.append(modifier.name)
        }
        //record["pickUpLocation"] = order.pickuplocation as? CKRecordValue
        record["modifiers"] = modifiers as CKRecordValue
        record["payedFor"] = NSNumber.init(value: payed) as CKRecordValue
        
        CKContainer.default().publicCloudDatabase.save(record) { (record, error) in
            if error != nil {
                self.orderCounter += 1
                if self.orderCounter < 2 {
                    self.createOrder(order: self.order, payed: payed, completion: { (succeeded) -> Void in
                        completion(succeeded)
                    })
                } else {
                    completion(false)
                }
            } else {
                //GO BACK TO MENU, SHOW CONFIRMATION, YOU ARE DONE!
                
                completion(true)
                
            }
        }
        
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
    var modifier: Modifier!
    
    @IBAction func switchChanged(_ sender: Any) {
        
        if (delegate != nil) {
            delegate?.modifierValueDidChange(modifier: self.modifier, value: modifierSwitch.isOn)
        }
        
    }
    
}

protocol ModifierSwitchDelegate {
    func modifierValueDidChange(modifier: Modifier, value: Bool)
}

class FlavorPickerTableViewCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var picker: UIPickerView!
    
    var product: Product? {
        didSet {
            picker.reloadAllComponents()
        }
    }
    
    var delegate: FlavorPickerCellDelegate? = nil

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
        case .Smoothie:
            return currentSmoothies.count
        case .Shake:
            return currentShakes.count
        case .Food:
            return currentFoods.count
        default:
            return 0
        }
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        guard let productType = product?.type else { return nil }
        
        switch productType {
        case .Smoothie:
            let string = currentSmoothies[row].name
            
            let attributedString = NSAttributedString(string: string!, attributes: [NSAttributedStringKey.foregroundColor : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
            
            return attributedString
        case .Shake:
            let string = currentShakes[row].name
            
            let attributedString = NSAttributedString(string: string!, attributes: [NSAttributedStringKey.foregroundColor : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
            
            return attributedString
        case .Food:
            let string = currentShakes[row].name
            
            let attributedString = NSAttributedString(string: string!, attributes: [NSAttributedStringKey.foregroundColor : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
            
            return attributedString
        }
       
    }
    @IBAction func donePressed(_ sender: Any) {
    
        if (delegate != nil) {
            delegate?.donePressed(product: picker.selectedRow(inComponent: 0))
        }
    
    }
    
}

protocol FlavorPickerCellDelegate {
    func donePressed(productRow: Int)
}
