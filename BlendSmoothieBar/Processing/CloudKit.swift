//
//  CloudKit.swift
//  BlendSmoothieBar
//
//  Created by Connor Espenshade on 6/6/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

import CloudKit
import UIKit
import Firebase

extension OrderMenuViewController {
    /**
     A function to test whether the user is connected and authenticated to CloudKit.
     - Parameter completion: A completion handler with a `Bool` indicating whether the test was successful.
     */
    func testCloudkit(completion: @escaping ((Bool) -> Void)) {
        let record = CKRecord(recordType: "Constants")
        record["string"] = "Test" as CKRecordValue
        let publicCloud = CKContainer.default().publicCloudDatabase
        publicCloud.save(record) { (record, error) in
            if let error = error as? CKError {
                let controller = error.handleAndAlert()
                DispatchQueue.main.async {
                    self.present(controller, animated: true, completion: nil)
                }
                completion(false)
            } else if error != nil {
                let controller = error!.alert()
                DispatchQueue.main.async {
                    self.present(controller, animated: true, completion: nil)
                }
                completion(false)
            } else {
                //Success
                completion(true)
                guard let id = record?.recordID else { completion(false); return }
                publicCloud.delete(withRecordID: id, completionHandler: { (recordid, error) in
                    if let error = error as? CKError {
                        let controller = error.handleAndAlert()
                        DispatchQueue.main.async {
                            self.present(controller, animated: true, completion: nil)
                        }
                    } else if error != nil {
                        let controller = error!.alert()
                        DispatchQueue.main.async {
                            self.present(controller, animated: true, completion: nil)
                        }
                    } 
                })
            }
        }
    }
    
    /**
     Checks the order for missing data in the `order.`
     - Parameter order: The `Order` object to check.
     - Parameter completion: A completion handler with a `Bool` indicating whether the order has all of the necessary data.
     */
    func verify(order: Order, completion: @escaping ((Bool) -> Void)) {
        if order.orderName != "" {
            if defaults.bool(forKey: "tutorial") {
                if defaults.string(forKey: "place") != nil || defaults.string(forKey: "place") != "" {
                    if defaults.bool(forKey: "tutorialtime") {
                        completion(true)
                    } else {
                        //First time user did not select pick-up time
                        
                        createUserErrorAlert(alertBody: "Please select a pick-up time. For future purchases, the closest time available will be auto-filled.")
                        
                        completion(false)
                    }
                } else {
                    //First time user did not select pick-up place
                    createUserErrorAlert(alertBody: "Please select a pick-up location. For future purchases, the location last chosen will be auto-filled.")
                    
                    completion(false)
                }
            } else {
                //First time user did not select item.
                createUserErrorAlert(alertBody: "Please select a flavor or item. Make sure to check this field every time.")
                completion(false)
            }
        } else {
            //User did not enter name
            createUserErrorAlert(alertBody: "Please enter your first name in the field above. This is so we know who to give the order to. This will save next order.")
            completion(false)
        }
    }
    
    /**
     Submits the order to CloudKit, where it is seen by the workers.
     - Parameter finalOrder: The final `Order` object to send to iCloud.
     - Parameter paid: A `Bool` indicating whether the user has pre-paid using Apple Pay or promised to pay in cash.
     - Parameter completion: A completion handler containing a success `Bool`, the `CKRecordID` of the order in case it needs to be deleted or accessed, and an optional `Error`.
     */
    func createOrder(finalOrder: Order, paid: Bool, completion: @escaping ((Bool, CKRecord.ID?, Error?) -> Void)) {
        
        let record = CKRecord(recordType: "Order")
        if let size = finalOrder.selectedSize {
            record["item"] = (finalOrder.baseProduct.name + ": " + size) as CKRecordValue
        } else {
            record["item"] = finalOrder.baseProduct.name as CKRecordValue
        }
        
        var modifiers: [String] = []
        for modifier in order.modifiers {
            modifiers.append(modifier.name)
        }
        
        
        record["pickUpLocation"] = (finalOrder.pickUpPlace ?? defaults.string(forKey: "place") ?? "Smoothie Bar") as CKRecordValue
        record["modifiers"] = modifiers as CKRecordValue
        record["payedFor"] = NSNumber.init(value: paid) as CKRecordValue
        self.order.paid = paid
        record["pickUpTime"] = finalOrder.pickUpTime as CKRecordValue
        record["name"] = finalOrder.orderName as CKRecordValue
        record["price"] = finalOrder.finalPrice.description as CKRecordValue
        
        let date = Date()
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        
        var digits = [Int]()
        
        let number = components.year! //2018
        digits.append(number)
        let number2 = components.month! //1
        
        if number2.digitCount == 1 {
            digits.append(0)
        }
        
        digits.append(number2)
        
        let number3 = components.day! //5
        
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
            record["notificationPayload"] = "New Order: \(finalOrder.baseProduct.name) for \((finalOrder.orderName)) with \(modifierString)" as CKRecordValue
        } else {
            record["notificationPayload"] = "New Order: \(finalOrder.baseProduct.name) for \((finalOrder.orderName))." as CKRecordValue
        }
        
        CKContainer.default().publicCloudDatabase.save(record) { (record, error) in
            if error != nil {
                if let error = error as? CKError {
                    let alert = error.handleAndAlert()
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    let alert = error!.alert()
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
                Analytics.logEvent("purchase-failed", parameters: [
                    "paymentMethod": paid ? "applePay" : "cash",
                    "product": self.order.baseProduct.name,
                    "price": self.order.finalPrice,
                    "error": error?.localizedDescription ?? "null"
                    ])
                
                completion(false, nil, error)
                
            } else {
                //GO BACK TO MENU, SHOW CONFIRMATION, YOU ARE DONE!
                Analytics.logEvent("purchase", parameters: [
                    "paymentMethod": paid ? "applePay" : "cash",
                    "product": self.order.baseProduct.name,
                    "price": self.order.finalPrice
                    ])
                completion(true, record!.recordID, nil)
                
            }
        }
        
    }
    
    func fetchAuthenticationKey(completion: @escaping ((String?, UIAlertController?) -> Void)) {
        
        let id = CKRecord.ID(recordName: "INSERT_CLOUDKIT_RECORD_ID")
        let currentCodeQuery = CKQuery(recordType: "Constants", predicate: NSPredicate(format: "recordID = %@", id))
        let database = CKContainer.default().publicCloudDatabase
        database.perform(currentCodeQuery, inZoneWith: nil) { (recordArray, error) in
            if error != nil {
                //Handle error
                if let error = error as? CKError {
                    //Handle CKError
                    let alert = error.handleAndAlert()
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                    completion(nil, alert)
                } else {
                    let alert2 = error!.alert()
                    DispatchQueue.main.async {
                        self.present(alert2, animated: true, completion: nil)
                    }
                    completion(nil, alert2)
                }
            } else {
                //NO ERROR
                guard let array = recordArray else {
                    
                    let alert2 = UIAlertController(title: "Error", message: "Something broke. Please try again.", preferredStyle: .alert)
                    alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        alert2.dismiss(animated: true, completion: nil)
                    }))
                    completion(nil, alert2)
                    return
                }
                
                for record in array {
                    if record.recordID == id {
                        completion(record["string"]! as? String, nil)
                    }
                }
            }
        }
        
    }
}

