//
//  CloudKit.swift
//  BlendSmoothieBar
//
//  Created by Connor Espenshade on 6/6/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

import CloudKit
import Foundation

extension OrderMenuViewController {
    func testCloudkit(completion: @escaping ((Bool) -> Void)) {
        let record = CKRecord(recordType: "Constants")
        record["string"] = "Test" as CKRecordValue
        let publicCloud = CKContainer.default().publicCloudDatabase
        publicCloud.save(record) { (record, error) in
            if let error = error as? CKError {
                let controller = error.handleAndAlert()
                self.present(controller, animated: true, completion: nil)
                completion(false)
            } else if error != nil {
                let controller = error!.alert()
                self.present(controller, animated: true, completion: nil)
                completion(false)
            } else {
                //Success
                completion(true)
                guard let id = record?.recordID else { completion(false); return }
                publicCloud.delete(withRecordID: id, completionHandler: { (recordid, error) in
                    if let error = error as? CKError {
                        let controller = error.handleAndAlert()
                        self.present(controller, animated: true, completion: nil)
                    } else if error != nil {
                        let controller = error!.alert()
                        self.present(controller, animated: true, completion: nil)
                    } else {
                        
                    }
                })
            }
        }
    }
    
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
}

