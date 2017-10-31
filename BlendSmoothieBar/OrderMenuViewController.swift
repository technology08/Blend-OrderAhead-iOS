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

class OrderMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ParameterReturnDelegate, PKPaymentAuthorizationViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    @IBOutlet weak var productTypeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var parameterTableView: UITableView!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    let defaults = UserDefaults.standard
    var applePayButton: UIButton?
    var currentProductCategory: ProductTypes = .Smoothie
    public var selectedProduct: Product? {
        didSet {
            parameterTableView.beginUpdates()
            priceLabel.text = "$\(selectedProduct?.price! ?? 3)"
            parameterTableView.endUpdates()
            parameterTableView.reloadData()
        }
    }
    
    var order = Order() {
        didSet {
            //parameterTableView.reloadData()
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
    
    // MARK: - UIViewController Setup Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        parameterTableView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
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
    
    // MARK: - Picker Cells Booleans
    
    var index1Shown = false {
        didSet {
            parameterTableView.beginUpdates()
            parameterTableView.endUpdates()
            parameterTableView.reloadData()
        }
    }
    
    var locationShown = false {
        didSet {
            if locationShown == false {
                
                parameterTableView.beginUpdates()
                parameterTableView.endUpdates()
                parameterTableView.reloadData()
                
            } else {
                
                parameterTableView.beginUpdates()
                parameterTableView.endUpdates()
                parameterTableView.scrollToRow(at: IndexPath.init(row: order.baseProduct.modifiers.count + 5, section: 0), at: .top, animated: true)
                parameterTableView.reloadData()
            }
        }
    }
    
    var timePickerShown = false {
        didSet {
            if timePickerShown == false {
                
                parameterTableView.beginUpdates()
                parameterTableView.endUpdates()
                parameterTableView.reloadData()
                
            } else {
                
                parameterTableView.beginUpdates()
                parameterTableView.endUpdates()
                parameterTableView.scrollToRow(at: IndexPath.init(row: order.baseProduct.modifiers.count + 3, section: 0), at: .top, animated: true)
                parameterTableView.reloadData()
            }
        }
    }
    
    // MARK: - UITableViewDelegate Methods
    
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
            return order.baseProduct.modifiers.count + 7
        } else {
            return 7
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            
            switch index1Shown {
            case true:
                //UIView.animate(withDuration: 0.75, delay: 0, options: [.curveEaseOut], animations: {
                return 150
                
            //}, completion: nil)
            case false:
                //UIView.animate(withDuration: 0.75, delay: 0, options: [.curveEaseOut], animations: {
                return 0
                //}, completion: nil)
            }
            
        } else if indexPath.row == (order.baseProduct.modifiers.count + 4) {
            switch timePickerShown {
            case true:
                return 150
            case false:
                return 0
            }
        } else if indexPath.row == (order.baseProduct.modifiers.count + 6) {
            switch locationShown {
            case true:
                return 150
            case false:
                return 0
            }
            
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let product = order.baseProduct else { return tableView.dequeueReusableCell(withIdentifier: "parameterCell")! }
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "parameterCell") as! MenuParameterCell
            
            switch product.type! {
            case .Smoothie:
                cell.parameterNameLabel.text = "Flavor"
            case .Shake:
                cell.parameterNameLabel.text = "Flavor"
            case .Food:
                cell.parameterNameLabel.text = "Item"
            }
            
            cell.parameterValueLabel.text = order.baseProduct.name
            
            return cell
        } else if indexPath.row == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "pickerCell") as! FlavorPickerTableViewCell
            
            cell.product = order.baseProduct
            cell.delegate = self
            
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
            
            let number = (indexPath.row - (order.baseProduct.modifiers.count)) - 1 //+ 1
            
            switch number {
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell") as! NameCell
                
                //ADJUST TO USER PREFERENCES
                cell.textField.text = defaults.string(forKey: "name")
                cell.delegate = self
                
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "parameterCell") as! MenuParameterCell
                
                cell.parameterNameLabel.text = "Pick-Up Time"
                //ADD TO ADJUST TO TIME OF DAY
                
                if order.pickUpTime == nil {
                    let date = Date()
                    let newDate = date.ceil(precision: 300)
                    let calendar = Calendar.current
                    let hour = calendar.dateComponents([.hour, .minute], from: newDate)
                    
                    if (((hour.hour! == 10 && hour.minute! >= 30) || (hour.hour! > 10))) && ((hour.hour == 13 && hour.minute! <= 25) || (hour.hour! <= 13)) {
                        //GO TO 1:25
                        order.pickUpTime = "1:25 PM"
                    } else if (hour.hour! == 10 && hour.minute! <= 30) || hour.hour! < 10 {
                        
                        order.pickUpTime = "\(hour.hour!):\(hour.minute!) AM"
                        
                    } else if (hour.hour! == 13 && hour.minute! > 25) || hour.hour! > 14 {
                        
                        let newHour = hour.hour! - 12
                        order.pickUpTime = "\(newHour):\(hour.minute!) PM"
                        
                    } else {
                        order.pickUpTime = "7:30 AM"
                    }
                }
                cell.parameterValueLabel.text = order.pickUpTime ?? "7:45 AM"
                
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "timeCell") as! TimeCell
                
                cell.delegate = self
                
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "parameterCell") as! MenuParameterCell
                
                cell.parameterNameLabel.text = "Pick-Up Location"
                //ADJUST TO USER PREFERENCES
                cell.parameterValueLabel.text = order.pickUpPlace ?? defaults.string(forKey: "place") ?? "Smoothie Bar"
                
                return cell
            case 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell") as! LocationPickerCell
                cell.delegate = self
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
        } else if indexPath.row == (order.baseProduct.modifiers.count + 3) {
            switch timePickerShown {
            case true:
                timePickerShown = false
                tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            case false:
                timePickerShown = true
            }
        }
        else if indexPath.row == (order.baseProduct.modifiers.count + 5) {
            print("tap")
            switch locationShown {
            case true:
                locationShown = false
                tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            case false:
                locationShown = true
            }
        }
        
        print(indexPath.row)
        
        if indexPath.row > 1 && indexPath.row <= order.modifiers.count + 1 {
            tableView.deselectRow(at: indexPath, animated: false)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        
    }
    
    // MARK: - Custom Table View Cells Delegate Method
    
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
        
        defaults.set(value, forKey: "\(order.baseProduct.type!)\(modifier.name)")
    }
    
    func flavorSelected(productRow: Product, remainShowing: Bool) {
        order.baseProduct = productRow
        index1Shown = remainShowing
        //parameterTableView.reloadData()
    }
    
    func time(time: String, remainShowing: Bool) {
        order.pickUpTime = time
        //timePickerShown = remainShowing
        parameterTableView.beginUpdates()
        if !remainShowing {
            timePickerShown = false
            parameterTableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        }
        parameterTableView.endUpdates()
        parameterTableView.reloadData()
    }
    
    func nameEntered(name: String) {
        parameterTableView.beginUpdates()
        order.orderName = name
        defaults.set(name, forKey: "name")
        parameterTableView.endUpdates()
        parameterTableView.reloadData()
    }
    
    func locationChanged(location: String, remainShowing: Bool) {
        parameterTableView.beginUpdates()
        if !remainShowing {
            timePickerShown = false
            parameterTableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        }
        defaults.set(location, forKey: "place")
        parameterTableView.endUpdates()
        parameterTableView.reloadData()
    }
    
    // MARK: - Other Payment Methods
    
    @IBAction func cashButtonPressed(_ sender: Any) {
        
        createOrder(finalOrder: self.order, payed: false) { (success, error) in
            if success {
                self.performSegue(withIdentifier: "toConfirmation", sender: nil)
            } else {
                if let error = error as? CKError {
                    //HANDLE
                    print(error)
                } else if error != nil {
                    print(error)
                } else {
                    
                }
            }
        }
        
    }
    // MARK: - Apple Pay Delegate Methods
    
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
                    
                    self.createOrder(finalOrder: self.order, payed: true, completion: { (success, error) in
                        
                        completion(status)
                        if success {
                            if success {
                                self.performSegue(withIdentifier: "toConfirmation", sender: nil)
                            } else {
                                if let error = error as? CKError {
                                    //HANDLE
                                    print(error)
                                } else if error != nil {
                                    print(error)
                                } else {
                                    
                                }
                            }
                            
                            
                        }
                    })
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
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toConfirmation" {
            if let destination = segue.destination as? ConfirmationViewController {
                destination.order = self.order
            }
        }
    }
    
    
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
    
    // MARK: - CloudKit
    
    func createOrder(finalOrder: Order, payed: Bool, completion: @escaping ((Bool, Error?) -> Void)) {
        
        let record = CKRecord(recordType: "Order")
        record["item"] = finalOrder.baseProduct.name + " " + String(describing: order.baseProduct.type!) as CKRecordValue
        //record["pickuptime"] = order.pickuptime as? CKRecordValue
        //record["name"] = order.ordername as? CKRecordValue
        var modifiers: [String] = []
        for modifier in order.modifiers {
            modifiers.append(modifier.name)
        }
        //record["pickUpLocation"] = order.pickuplocation as? CKRecordValue
        record["modifiers"] = modifiers as CKRecordValue
        record["payedFor"] = NSNumber.init(value: payed) as CKRecordValue
        record["pickUpTime"] = finalOrder.pickUpTime as CKRecordValue
        record["name"] = finalOrder.orderName as CKRecordValue
        record["price"] = finalOrder.finalPrice.description as CKRecordValue
        
        CKContainer.default().publicCloudDatabase.save(record) { (record, error) in
            if error != nil {
                self.orderCounter += 1
                
                print(error!)
                completion(false, error)
                
            } else {
                //GO BACK TO MENU, SHOW CONFIRMATION, YOU ARE DONE!
                print("SUCCESS")
                completion(true, nil)
                
            }
        }
        
    }
}
