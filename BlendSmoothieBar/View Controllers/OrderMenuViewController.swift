//
//  OrderMenuViewController.swift
//  BlendSmoothieBar
//
//  Created by Connor Espenshade on 10/10/17.
//  Copyright © 2017 Connor Espenshade. All rights reserved.
//

import UIKit
import CloudKit
import PassKit
import LocalAuthentication

class OrderMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ParameterReturnDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var productTypeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var parameterTableView: UITableView!
    
    let defaults = UserDefaults.standard
    var applePayButton: UIButton?
    var currentProductCategory: String = "Smoothie"
    var initalLoad = false
    var selectedBusiness: Business = .LeaningEagle
    public var selectedProduct: Product? {
        didSet {
            parameterTableView.beginUpdates()
            priceLabel.text = "$\(selectedProduct?.price ?? 3)"
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
    //@IBOutlet weak var cashButtonBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Apple Pay Variables
    
    var supportedNetworks: [PKPaymentNetwork] {
        if #available(iOS 10.1, *) {
            return [.visa, .masterCard, .amex, .discover, .JCB]
        } else {
            // Fallback on earlier versions
            return [.visa, .masterCard, .amex, .discover]
        }
    }    
    var applepaysucceeded = false
    var applepayalert: UIAlertController?
    
    // MARK: - UIViewController Setup Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        parameterTableView.delegate = self
        //parameterTableView.contentInset = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 15)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
        
        /*self.tableViewHeightConstraint.constant = self.parameterTableView.contentSize.height*/
        
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
        self.navigationController?.navigationBar.isTranslucent = true
        self.tabBarController?.tabBar.isTranslucent = true
        switch selectedBusiness {
        case .Blend:
            self.tabBarController?.tabBar.barTintColor = #colorLiteral(red: 0.3294117647, green: 0.3411764706, blue: 0.4117647059, alpha: 1)
            self.tabBarController?.tabBar.tintColor = UIColor.white            
        case .LeaningEagle:
            if #available(iOS 13, *) {
                switch traitCollection.userInterfaceStyle {
                case .light, .unspecified:
                    self.tabBarController?.tabBar.barTintColor = UIColor.white
                    self.tabBarController?.tabBar.tintColor = UIColor.black
                    self.navigationController?.navigationBar.barTintColor = UIColor.white
                    self.navigationController?.navigationBar.tintColor = UIColor.black
                case .dark:
                    self.tabBarController?.tabBar.barTintColor = UIColor.black
                    self.tabBarController?.tabBar.tintColor = UIColor.white
                    self.navigationController?.navigationBar.barTintColor = UIColor.black
                    self.navigationController?.navigationBar.tintColor = UIColor.white
                }
            }
            /*
            self.tabBarController?.tabBar.barTintColor = UIColor.white
            self.tabBarController?.tabBar.tintColor = UIColor.black*/
        }
        
        switch currentProductCategory {
        case "Smoothies":
            productTypeLabel.text = "Smoothie"
            order.baseProduct = currentSmoothies.first
            order.finalPrice = currentSmoothies.first?.price
            visualEffectView.effect = UIBlurEffect(style: .dark)
            backgroundImageView.image = #imageLiteral(resourceName: "smoothie")
        case "Ice Cream & Sweets":
            productTypeLabel.text = "Ice Cream & Sweets"
            order.baseProduct = currentIceCream.first
            order.finalPrice = currentIceCream.first?.price
            visualEffectView.effect = UIBlurEffect(style: .dark)
            backgroundImageView.image = #imageLiteral(resourceName: "shake")
        case "Espresso":
            productTypeLabel.text = "Espresso"
            order.baseProduct = currentEspresso.first
            order.finalPrice  = currentEspresso.first?.price
            visualEffectView.effect = UIBlurEffect(style: .dark)
            backgroundImageView.image = #imageLiteral(resourceName: "espresso")
        case "Tea":
            productTypeLabel.text = "Tea"
            order.baseProduct = currentTea.first
            order.finalPrice  = currentTea.first?.price
            visualEffectView.effect = UIBlurEffect(style: .dark)
            backgroundImageView.image = #imageLiteral(resourceName: "tea")
        case "Cold Brew":
            productTypeLabel.text = "Cold Brew"
            order.baseProduct = currentCold.first
            order.finalPrice  = currentCold.first?.price
            visualEffectView.effect = UIBlurEffect(style: .light)
            backgroundImageView.image = #imageLiteral(resourceName: "coffee_drinks")
        case "Non-Coffee":
            productTypeLabel.text = "Non-Caffeinated"
            order.baseProduct = currentNonCoffee.first
            order.finalPrice  = currentNonCoffee.first?.price
            if #available(iOS 10.0, *) {
                visualEffectView.effect = UIBlurEffect(style: .light)
            } else {
                // Fallback on earlier versions
            }
            backgroundImageView.image = #imageLiteral(resourceName: "soda")
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
            parameterTableView.beginUpdates()
            parameterTableView.endUpdates()
            /*
             if locationShown == false {
             parameterTableView.beginUpdates()
             parameterTableView.endUpdates()
             parameterTableView.reloadData()
             } else {
             
             parameterTableView.reloadData()
             }
             */
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
        let sizesShown = (order.baseProduct.sizes.count > 1) ? true : false
        if order.baseProduct != nil {
            if sizesShown {
                return order.baseProduct.modifiers.count + 8
            } else {
                return order.baseProduct.modifiers.count + 7
            }
        } else {
            return 7
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if order.baseProduct.sizes.count > 1 {
            if indexPath.row == 1 {
                switch index1Shown {
                case true:
                    return 150
                case false:
                    return 0
                }
            } else if indexPath.row == (order.baseProduct.modifiers.count + (((selectedProduct?.sizes.count ?? 1) > 1) ? 6 : 5)) {
                switch timePickerShown {
                case true:
                    return 150
                case false:
                    return 0
                }
            } else if indexPath.row == (order.baseProduct.modifiers.count + (((selectedProduct?.sizes.count ?? 1) > 1) ? 8 : 7)) {
                switch locationShown {
                case true:
                    return 150
                case false:
                    return 0
                }
                
            } else {
                return 44
            }
        } else {
            if indexPath.row == 1 {
                switch index1Shown {
                case true:
                    return 150
                case false:
                    return 0
                }
            } else if indexPath.row == (order.baseProduct.modifiers.count + (((selectedProduct?.sizes.count ?? 1) > 1) ? 5 : 4)) {
                switch timePickerShown {
                case true:
                    return 150
                case false:
                    return 0
                }
            } else if indexPath.row == (order.baseProduct.modifiers.count + (((selectedProduct?.sizes.count ?? 1) > 1) ? 7 : 6)) {
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
    }
    
    var selectedTimeIndex: Int = 0
    var initalized = false
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let product = order.baseProduct else { return tableView.dequeueReusableCell(withIdentifier: "parameterCell")! }
        let sizesShown = (product.sizes.count > 1) ? true : false
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "parameterCell") as! MenuParameterCell
            switch product.type {
            case "Smoothies":
                cell.parameterNameLabel.text = "Flavor"
            case "Ice Cream & Sweets":
                cell.parameterNameLabel.text = "Flavor"
            default /*INCLUDES FOOD*/:
                cell.parameterNameLabel.text = "Item"
            }
            
            if !defaults.bool(forKey: "tutorial") {
                switch product.type {
                case "Smoothies":
                    cell.parameterValueLabel.text = "Tap to Choose Flavor"
                    cell.parameterValueLabel.adjustsFontSizeToFitWidth = true
                    cell.parameterValueLabel.minimumScaleFactor = 0.3
                case "Ice Cream & Sweets":
                    cell.parameterValueLabel.text = "Tap to Choose Flavor"
                    cell.parameterValueLabel.adjustsFontSizeToFitWidth = true
                    cell.parameterValueLabel.minimumScaleFactor = 0.3
                default /*INCLUDES FOOD*/:
                    cell.parameterValueLabel.text = "Tap to Choose Item"
                    cell.parameterValueLabel.adjustsFontSizeToFitWidth = true
                    cell.parameterValueLabel.minimumScaleFactor = 0.3
                }
            } else {
                cell.parameterValueLabel.text = order.baseProduct.name
                cell.parameterValueLabel.adjustsFontSizeToFitWidth = true
                cell.parameterValueLabel.minimumScaleFactor = 0.3
            }
            
            
            return cell
        } else if indexPath.row == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "pickerCell") as! FlavorPickerTableViewCell
            
            cell.product = order.baseProduct
            cell.delegate = self
            
            return cell
            
        } else if indexPath.row == 2 && sizesShown {
            // Display sizes cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "sizeCell") as! SizeSegmentedCell
            
            var names: [String] = []
            var prices: [Decimal] = []
            
            for size in product.sizes {
                names.append(size.name)
                prices.append(size.price)
            }
            cell.configure(delegate: self, sizeNames: names, sizePrices: prices, theme: self.selectedBusiness)
            
            if self.order.sizeUpgradePrice == nil {
                self.order.selectedSize = product.sizes.first!.name
                
                
            }
            
            return cell
        } else if indexPath.row > (sizesShown ? 2 : 1) && indexPath.row <= product.modifiers.count + (sizesShown ? 2 : 1) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "modifierCell") as! MenuModifierCell
            
            let modifier = product.modifiers[indexPath.row - (sizesShown ? 3 : 2)]
            
            var modifierText = modifier.name
            
            if modifier.price != 0 {
                modifierText?.append(": $\(modifier.price!)")
            }
            
            cell.modifierNameLabel.text = modifierText
            cell.modifier = modifier
            cell.delegate = self
            
            return cell
            
        } else {
            
            var number = (indexPath.row - (order.baseProduct.modifiers.count)) - 1 //+ 1
            if sizesShown { number -= 1}
            switch number {
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell") as! NameCell
                
                //ADJUST TO USER PREFERENCES
                cell.textField.text = defaults.string(forKey: "name")
                cell.textField.adjustsFontSizeToFitWidth = true
                cell.textField.minimumFontSize = 15
                self.order.orderName = defaults.string(forKey: "name") ?? ""
                cell.delegate = self
                
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "parameterCell") as! MenuParameterCell
                
                cell.parameterNameLabel.text = "Delivery Time"
                //ADD TO ADJUST TO TIME OF DAY
                if defaults.string(forKey: "tutorialtime") == nil || defaults.string(forKey: "tutorialtime") == "" {
                    cell.parameterValueLabel.text = "Tap to Choose Time"
                    cell.parameterValueLabel.adjustsFontSizeToFitWidth = true
                    cell.parameterValueLabel.minimumScaleFactor = 0.3
                } else {
                    
                        // 8:00 AM - 3:05 PM
                        if order.pickUpTime == nil {
                            let date = Date()
                            let newDate = date.ceil(precision: 300)
                            let calendar = Calendar.current
                            let time = calendar.dateComponents([.hour, .minute], from: newDate)
                            
                            if time.hour! > 15 ||
                                (time.hour! == 15 && time.minute! > 5) {
                                // If time is past 3:05, go to next day at 7:30 AM
                                order.pickUpTime = "7:30 AM"
                            } else if time.hour! < 7 ||
                                (time.hour! == 7 && time.minute! < 30) {
                                // If time is before 7:30, go to 7:30 AM
                                order.pickUpTime = "7:30 AM"
                            } else if time.hour! < 13 {
                                // Within operating hours, set default to ASAP
                                let newHour = time.hour!
                                let pickUpTime  = "\(newHour):\(time.minute!) AM"
                                order.pickUpTime = pickUpTime
                                if let index = coffeeBarTimes.firstIndex(of: pickUpTime) {
                                    selectedTimeIndex = index
                                }
                            } else {
                                let newHour = time.hour! - 12
                                let pickUpTime  = "\(newHour):\(time.minute!) PM"
                                order.pickUpTime = pickUpTime
                                if let index = coffeeBarTimes.firstIndex(of: pickUpTime) {
                                    selectedTimeIndex = index
                                }
                            }
                        }
                        cell.parameterValueLabel.text = order.pickUpTime ?? "7:30 AM"
                    
                }
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "timeCell") as! TimeCell
                
                cell.delegate = self
                cell.business = self.selectedBusiness
                
                if !initalized {
                    cell.picker.selectRow(selectedTimeIndex, inComponent: 0, animated: true)
                    initalized = true
                }
                
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "parameterCell") as! MenuParameterCell
                
                cell.parameterNameLabel.text = "Delivery Location"
                
                if defaults.string(forKey: "tutorialplace") == nil || defaults.string(forKey: "tutorialplace") == "" {
                    cell.parameterValueLabel.text = "Tap to Choose Location"
                    cell.parameterValueLabel.adjustsFontSizeToFitWidth = true
                    cell.parameterValueLabel.minimumScaleFactor = 0.3
                } else {
                        cell.parameterValueLabel.text = order.pickUpPlace ?? "Coffee Bar"
                        self.order.pickUpPlace = order.pickUpPlace ?? "Coffee Bar"
                }
                
                return cell
            case 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell") as! LocationPickerCell
                cell.delegate = self
                cell.business = self.selectedBusiness
                return cell
            default:
                print("PROBLEM!")
                return tableView.dequeueReusableCell(withIdentifier: "parameterCell")!
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if order.baseProduct.sizes.count > 1 {
            if indexPath.row == 0 {
                switch index1Shown {
                case true:
                    index1Shown = false
                case false:
                    index1Shown = true
                }
            } else if indexPath.row == (order.baseProduct.modifiers.count + 4) {
                switch timePickerShown {
                case true:
                    timePickerShown = false
                    tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                case false:
                    timePickerShown = true
                }
            }
            else if indexPath.row == (order.baseProduct.modifiers.count + 6) {
                switch locationShown {
                case true:
                    locationShown = false
                    tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                case false:
                    locationShown = true
                }
            }
            
            if indexPath.row > 1 && indexPath.row <= order.modifiers.count + 1 {
                tableView.deselectRow(at: indexPath, animated: false)
            } else {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        } else {
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
            switch locationShown {
            case true:
                locationShown = false
                tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            case false:
                locationShown = true
            }
        }
        
        if indexPath.row > 1 && indexPath.row <= order.modifiers.count + 1 {
            tableView.deselectRow(at: indexPath, animated: false)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
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
        
        defaults.set(value, forKey: "\(order.baseProduct.type)\(modifier.name)")
    }
    
    func flavorSelected(productRow: Product, remainShowing: Bool) {
        order.baseProduct = productRow
        //Price stuff
        var modifierPrices:Decimal = 0.0
        for mod in order.modifiers {
            modifierPrices += mod.price
        }
        
        if !defaults.bool(forKey: "tutorial") {
            defaults.set(true, forKey: "tutorial")
        }
        
        order.finalPrice = order.baseProduct.price + modifierPrices
        
        if !remainShowing {
            index1Shown = false
            /*
             parameterTableView.beginUpdates()
             parameterTableView.endUpdates()
             */
        } else {
            parameterTableView.reloadData()
        }
    }
    
    func time(time: String, remainShowing: Bool) {
        order.pickUpTime = time
        //timePickerShown = remainShowing
        if !defaults.bool(forKey: "tutorialtime") {
            defaults.set(true, forKey: "tutorialtime")
        }
        if !remainShowing {
            parameterTableView.beginUpdates()
            timePickerShown = false
            parameterTableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
            parameterTableView.endUpdates()
        } else {
            parameterTableView.reloadData()
        }
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
        
        if !defaults.bool(forKey: "tutorialplace") {
                   defaults.set(true, forKey: "tutorialplace")
        }
        
        if !remainShowing {
            parameterTableView.beginUpdates()
            locationShown = false
            //parameterTableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
            parameterTableView.endUpdates()
        } else {
            parameterTableView.reloadData()
        }
        
        if location != "Coffee Bar" {
            self.cashButton.isEnabled = false
            DispatchQueue.main.async {
                self.cashButton.backgroundColor = UIColor.darkGray
                self.cashButton.titleLabel!.textColor = UIColor.gray
            }
        } else {
            self.cashButton.isEnabled = true
            DispatchQueue.main.async {
                self.cashButton.backgroundColor = #colorLiteral(red: 0, green: 0.7529411765, blue: 0, alpha: 1)
                self.cashButton.titleLabel!.textColor = UIColor.white
            }
        }
        
    }
    
    func sizeChanged(size: String, price: Decimal) {
        
        self.order.selectedSize = size
        self.order.finalPrice! -= self.order.sizeUpgradePrice ?? 0
        
        if price == 0 {
            self.order.sizeUpgradePrice = nil
        } else {
            self.order.sizeUpgradePrice = price
            self.order.finalPrice! += price
        }
        
    }
    
    // MARK: - Other Payment Methods
    
    @IBAction func cashButtonPressed(_ sender: Any) {
        verify(order: self.order) { (accurate) in
            if accurate {
                if !self.defaults.bool(forKey: "authCodeEntered") {
                    
                    let alert = UIAlertController(title: "Student ID Required", message: "To enable the cash button, please enter your first and last name, along with a code posted by the smoothie bar. This only happens the first time to make sure you are a student.", preferredStyle: .alert)
                    alert.addTextField(configurationHandler: { (field) in
                        field.placeholder = "First Name"
                        field.text = self.order.orderName
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
                        
                        self.fetchAuthenticationKey(completion: { (key, errorAlert) in
                            guard errorAlert == nil else {
                                self.present(errorAlert!, animated: true, completion: nil)
                                return
                            }
                            
                            DispatchQueue.main.async {
                                if alert.textFields![2].text == key {
                                    //SUCCESSFULLY AUTH
                                    
                                    self.defaults.set(true, forKey: "authCodeEntered")
                                    //self.authenticate(completion: { (auth) in
                                    let auth = true
                                    if auth {
                                        self.createOrder(finalOrder: self.order, paid: false) { (success, record, error) in
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
                                                    self.createOrder(finalOrder: self.order, paid: false, completion: { (bool, record, error) in
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
                                    //})
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
                        })
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Nevermind", style: .default, handler: { (action) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    
                    let alert = UIAlertController(title: "Place Order?", message: "Are you sure you want to place your order?", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                        //self.authenticate(completion: { (auth) in
                        let auth = true
                        if auth {
                            self.createOrder(finalOrder: self.order, paid: false) { (success, record, error) in
                                if success {
                                    DispatchQueue.main.async {
                                        self.performSegue(withIdentifier: "toConfirmation", sender: nil)
                                    }
                                    
                                } else {
                                    if let error = error as? CKError {
                                        //HANDLE
                                        let alert = error.handleAndAlert()
                                        self.present(alert, animated: true, completion: nil)
                                    } else if error != nil {
                                        let alert = error!.alert()
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                }
                            }
                            alert.dismiss(animated: true, completion: nil)
                        }
                        //})
                    }))
                    alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
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
    
}

var locations = ["Coffee Bar"]
