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
import LocalAuthentication

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
    var currentProductCategory: String = "Smoothie"
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
            
            DispatchQueue.main.async {
                self.priceLabel.text = "$\(self.order.finalPrice ?? 3)"
            }
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
            //cashButtonLeadingConstraint.constant = 8
            //cashButtonBottomConstraint.constant = 8
            cashButton.layer.cornerRadius = 5
            
            let leadingConstraint = applePayButton?.leadingAnchor.constraint(equalTo: cashButton.trailingAnchor, constant: 8)
            let trailingConstraint = applePayButton?.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -8)
            //            let bottomConstraint = applePayButton?.bottomAnchor.constraint(equalTo: addMoreItemsButton.topAnchor, constant: -8)
            var bottomConstraint: NSLayoutConstraint!
            if #available(iOS 11.0, *) {
                bottomConstraint = applePayButton?.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
            } else {
                // Fallback on earlier versions
                bottomConstraint = applePayButton?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -8)
            }
            let equalWidths = applePayButton?.widthAnchor.constraint(equalTo: cashButton.widthAnchor)
            let height = applePayButton?.heightAnchor.constraint(equalToConstant: 44)
            
            NSLayoutConstraint.activate([leadingConstraint!, trailingConstraint!, bottomConstraint, equalWidths!, height!])
            
        } else {
            //Extend cash button full width
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch currentProductCategory {
        case "Smoothies":
            productTypeLabel.text = "Smoothie"
            order.baseProduct = currentSmoothies.first
            order.finalPrice = currentSmoothies.first?.price
            visualEffectView.effect = UIBlurEffect(style: .dark)
            backgroundImageView.image = #imageLiteral(resourceName: "smoothie")
        case "Drinks":
            productTypeLabel.text = "Drinks"
            order.baseProduct = currentDrinks.first
            order.finalPrice = currentDrinks.first?.price
            visualEffectView.effect = UIBlurEffect(style: .dark)
            backgroundImageView.image = #imageLiteral(resourceName: "smoothie")
        case "Ice Cream & Sweets":
            productTypeLabel.text = "Ice Cream & Sweets"
            order.baseProduct = currentIceCream.first
            order.finalPrice = currentIceCream.first?.price
            visualEffectView.effect = UIBlurEffect(style: .dark)
            backgroundImageView.image = #imageLiteral(resourceName: "shake")
        case "Food":
            productTypeLabel.text = "Food"
            order.baseProduct = currentFoods.first
            order.finalPrice = currentFoods.first?.price
            visualEffectView.effect = UIBlurEffect(style: .dark)
            backgroundImageView.image = #imageLiteral(resourceName: "waffle")
        default:
            productTypeLabel.text = "Smoothie"
            order.baseProduct = currentSmoothies.first
            order.finalPrice = currentSmoothies.first?.price
            visualEffectView.effect = UIBlurEffect(style: .dark)
            backgroundImageView.image = #imageLiteral(resourceName: "smoothie")
        }
        
    }
    
    // MARK: - Picker Cells Booleans
    
    var index1Shown = false {
        didSet {

            if locationShown == false {
                parameterTableView.beginUpdates()
                parameterTableView.endUpdates()
                parameterTableView.reloadData()
            } else {
                parameterTableView.beginUpdates()
                parameterTableView.endUpdates()
                parameterTableView.reloadData()
            }
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
                return 150
            case false:
                return 0
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
            case "Smoothies":
                cell.parameterNameLabel.text = "Flavor"
            case "Ice Cream & Sweets":
                cell.parameterNameLabel.text = "Flavor"
            default /*INCLUDES FOOD*/:
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
                self.order.orderName = defaults.string(forKey: "name")
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
                    } else if hour.hour! > 16 || (hour.hour! > 15 && hour.minute! > 30) {
                        //GO TO 7:30
                        
                        order.pickUpTime = "7:30 AM"
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
                self.order.pickUpPlace = order.pickUpPlace ?? defaults.string(forKey: "place") ?? "Smoothie Bar"
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
        //Price stuff
        var modifierPrices:Decimal = 0.0
        for mod in order.modifiers {
            modifierPrices += mod.price
        }
        
        order.finalPrice = order.baseProduct.price + modifierPrices
        
        if remainShowing {
            parameterTableView.reloadData()
            index1Shown = false
        }
        //parameterTableView.reloadData()
    }
    
    func time(time: String, remainShowing: Bool) {
        order.pickUpTime = time
        //timePickerShown = remainShowing
        
        if !remainShowing {
            parameterTableView.beginUpdates()
            timePickerShown = false
            parameterTableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
            parameterTableView.endUpdates()
        }
        
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
        self.order.pickUpPlace = location
        
        if !remainShowing {
            parameterTableView.beginUpdates()
            locationShown = false
            parameterTableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
            parameterTableView.endUpdates()
        }
        defaults.set(location, forKey: "place")
        
        parameterTableView.reloadData()
    }
    
    // MARK: - Other Payment Methods
    
    @IBAction func cashButtonPressed(_ sender: Any) {
        
        
        if !self.defaults.bool(forKey: "authCodeEntered") {
            
            let alert = UIAlertController(title: "Student ID Required", message: "To enable the cash button, please enter your first and last name, along with a code posted by the smoothie bar. This only happens the first time to make sure you are a student.", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (field) in
                field.placeholder = "First Name"
                field.text = self.order.orderName ?? ""
                field.clearButtonMode = .whileEditing
                field.clearsOnBeginEditing = true
            })
            alert.addTextField(configurationHandler: { (field) in
                field.placeholder = "Last Name"
                field.clearButtonMode = .whileEditing
                field.clearsOnBeginEditing = true
            })
            alert.addTextField(configurationHandler: { (field) in
                field.placeholder = "Code"
                field.clearButtonMode = .whileEditing
                field.clearsOnBeginEditing = true
            })
            
            alert.addAction(UIAlertAction(title: "Enter", style: .cancel, handler: { (action) in
                
                let id = CKRecordID(recordName: "INSERT_CLOUDKIT_RECORD_ID")
                let currentCodeQuery = CKQuery(recordType: "Constants", predicate: NSPredicate(format: "recordID = %@", id))
                let database = CKContainer.default().publicCloudDatabase
                database.perform(currentCodeQuery, inZoneWith: nil, completionHandler: { (recordArray, error) in
                    
                    alert.dismiss(animated: true, completion: nil)
                    if error != nil {
                        //Handle error
                        if let error = error as? CKError {
                            //Handle CKError
                            print(error)
                            if error.localizedDescription == "Couldn't send a valid signature" {
                                let alert2 = UIAlertController(title: "Sign into iCloud", message: "This phone needs to have an iCloud account used with it in order to send orders to the server. Please sign in inside the Settings app and turn on iCloud Drive.", preferredStyle: .alert)
                                alert2.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
                                    alert2.dismiss(animated: true, completion: nil)
                                }))
                                self.present(alert2, animated: true, completion: nil)
                            } else {
                                let alert2 = UIAlertController(title: "Error", message: "Problem with server. Please try again.", preferredStyle: .alert)
                                alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                    alert2.dismiss(animated: true, completion: nil)
                                }))
                                self.present(alert2, animated: true, completion: nil)
                            }
                        } else {
                            let alert2 = UIAlertController(title: "Error", message: "Something broke. Please try again.", preferredStyle: .alert)
                            alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                alert2.dismiss(animated: true, completion: nil)
                            }))
                            self.present(alert2, animated: true, completion: nil)
                        }
                    } else {
                        //NO ERROR
                        guard let array = recordArray else {
                            
                            let alert2 = UIAlertController(title: "Error", message: "Something broke. Please try again.", preferredStyle: .alert)
                            alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                alert2.dismiss(animated: true, completion: nil)
                            }))
                            self.present(alert2, animated: true, completion: nil)
                            return
                        }
                        for record in array {
                            if record.recordID == id {
                                DispatchQueue.main.async {
                                    if alert.textFields![2].text == (record["string"] as? String) {
                                        //SUCCESSFULLY AUTH
                                        
                                        self.defaults.set(true, forKey: "authCodeEntered")
                                        self.authenticate(completion: { (auth) in
                                            if auth {
                                                self.createOrder(finalOrder: self.order, payed: false) { (success, error) in
                                                    if success {
                                                        self.performSegue(withIdentifier: "toConfirmation", sender: nil)
                                                    } else {
                                                        //if let error = error as? CKError {
                                                        //HANDLE
                                                        let alert2 = UIAlertController(title: "Error", message: "The code you entered is correct, but there was an error creating the order. Please try again. You were not charged.", preferredStyle: .alert)
                                                        alert2.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action) in
                                                            alert2.dismiss(animated: true, completion: nil)
                                                        }))
                                                        alert2.addAction(UIAlertAction(title: "Try again", style: .destructive, handler: { (action) in
                                                            self.createOrder(finalOrder: self.order, payed: false, completion: { (bool, error) in
                                                                //NOTHING
                                                            })
                                                        }))
                                                        self.present(alert2, animated: true, completion: nil)
                                                        //} else if error != nil {
                                                        //    print(error)
                                                        //} else {
                                                        
                                                        // }
                                                        
                                                    }
                                                }
                                            }
                                        })
                                        return
                                    } else {
                                        //FAILED AUTH
                                        
                                        let alert2 = UIAlertController(title: "Incorrect Code", message: "The code you entered is wrong. Please try again.", preferredStyle: .alert)
                                        alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                            alert2.dismiss(animated: true, completion: nil)
                                        }))
                                        self.present(alert2, animated: true, completion: nil)
                                        return
                                    }
                                }
                            }
                            
                        }
                    }
                })
                
            }))
            
            alert.addAction(UIAlertAction(title: "Nevermind", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            
            let alert = UIAlertController(title: "Place Order?", message: "Are you sure you want to place your order?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                self.authenticate(completion: { (auth) in
                    if auth {
                        self.createOrder(finalOrder: self.order, payed: false) { (success, error) in
                            if success {
                                self.performSegue(withIdentifier: "toConfirmation", sender: nil)
                            } else {
                                if let error = error as? CKError {
                                    //HANDLE
                                    print(error)
                                    fatalError("CKError is as follows: \(String(describing:(error)))")
                                } else if error != nil {
                                    print(error!)
                                    fatalError("Error is as follows: \(String(describing: error))")
                                } else {
                                    
                                }
                            }
                        }
                        alert.dismiss(animated: true, completion: nil)
                    }
                })
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
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
                                    print(error!)
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
            if let destination = segue.destination as? UINavigationController {
                if let destination2 = destination.viewControllers.first as? ConfirmationViewController {
                    destination2.order = self.order
                }
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
        record["item"] = (finalOrder.baseProduct.name + " " + finalOrder.baseProduct.type.description) as CKRecordValue
        
        var modifiers: [String] = []
        for modifier in order.modifiers {
            modifiers.append(modifier.name)
        }
        record["pickUpLocation"] = (finalOrder.pickUpPlace ?? "Smoothie Bar") as CKRecordValue
        record["modifiers"] = modifiers as CKRecordValue
        record["payedFor"] = NSNumber.init(value: payed) as CKRecordValue
        self.order.payed = payed
        record["pickUpTime"] = finalOrder.pickUpTime as CKRecordValue
        record["name"] = finalOrder.orderName as CKRecordValue
        record["price"] = finalOrder.finalPrice.description as CKRecordValue
        
        let date = Date()
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        
        var digits = [Int]()
        
        let number = components.year!
        digits.append(number)
        let number2 = components.month!
        
        if number2.digitCount == 1 {
            digits.append(0)
        }
        
        digits.append(number2)
        
        let number3 = components.day!
        
        if number3.digitCount == 1 {
            digits.append(0)
        }
        
        digits.append(number3)
        
        let pickuptime = self.order.pickUpTime
        let characters = pickuptime?.components(separatedBy: " ")
        let furtherseperated = characters?.first?.components(separatedBy: ":")
        var hour = Int()
        
        if (pickuptime?.starts(with: "10"))! {
            hour = 10
        } else {
            hour = Int((furtherseperated?.first)!)!
            if ((pickuptime?.starts(with: "1"))! || (pickuptime?.starts(with: "2"))! || (pickuptime?.starts(with: "3"))!) {
                hour += 12
            }
        }
        digits.append(hour)
        
        let minute = Int(furtherseperated![1])
        
        if (furtherseperated?[1].starts(with: "0"))! {
            digits.append(0)
        }
        
        digits.append(minute!)
        let value = Int(digits.map(String.init).joined())
        
        record["sortDate"] = value! as CKRecordValue
        
        var modifierString = ""
        
        for item in modifiers {
            if item == modifiers.last {
                modifierString.append("\(item).")
            } else {
                modifierString.append("\(item), ")
            }
            
        }
        
        if modifierString != "" {
            record["notificationPayload"] = "New Order: \(finalOrder.baseProduct.name + " " + finalOrder.baseProduct.type.description) for \((finalOrder.orderName)!) with \(modifierString)" as CKRecordValue
        } else {
            record["notificationPayload"] = "New Order: \(finalOrder.baseProduct.name + " " + finalOrder.baseProduct.type.description) for \((finalOrder.orderName)!)." as CKRecordValue
        }
        
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
    @IBAction func addSpecialItems(_ sender: Any) {
        
        let alert = UIAlertController(title: "Add Special Instructions", message: "", preferredStyle: .alert)
        alert.addTextField { (field) in
            field.text = self.order.specialInstructions ?? ""
            field.placeholder = "Add instructions here..."
        }
        
        let action2 = UIAlertAction(title: "Dismiss", style: .default) { (action) in
            alert.dismiss(animated: true, completion: {
                alert.dismiss(animated: true, completion: {
                    
                })
            })
        }
        
        let action = UIAlertAction(title: "OK", style: .cancel) { (action) in
            let text = alert.textFields?.first?.text
            self.order.specialInstructions = text
            alert.dismiss(animated: true, completion: {
                
            })
        }
        alert.addAction(action2)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func authenticate(completion: @escaping ((Bool) -> Void)) {
        let context:LAContext = LAContext()
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Please use biometrics in order to verify your identity before purchase.", reply: { (authenticated, error) in
                
                if let error = error as? LAError {
                    switch error.errorCode {
                   
                    case LAError.passcodeNotSet.rawValue:
                        completion(true)
                  
                    default:
                        completion(false)
                    }
                } else {
                    completion(authenticated)
                }
            })
        }
    }
}
