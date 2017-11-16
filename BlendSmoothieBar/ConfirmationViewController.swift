//
//  ConfirmationViewController.swift
//  BlendSmoothieBar
//
//  Created by Connor Espenshade on 10/30/17.
//  Copyright © 2017 Connor Espenshade. All rights reserved.
//

import UIKit
import CloudKit

class ConfirmationViewController: UIViewController {

    @IBOutlet weak var orderName: UILabel!
    @IBOutlet weak var pickUpDate: UILabel!
    @IBOutlet weak var pickUpLocation: UILabel!
    @IBOutlet weak var amountDue: UILabel!
    
    var recordId: CKRecordID!
    var date: String?
    var order: Order!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let orderNameValue = order.orderName ?? "No Name"
        orderName.text = "Order Name: \(orderNameValue)"
        pickUpDate.text = getDate(pickUpTime: order.pickUpTime)
        pickUpLocation.text = "Pick Up at \(String(describing: (order.pickUpPlace ?? "Smoothie Bar") + (order.pickUpTime ?? "")))."
        if order.payed {
            amountDue.text = "Pre-Paid"
        } else {
            amountDue.text = "$\(order.finalPrice)"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /*
        if #available(iOS 10.0, *) {
            let sub = CKQuerySubscription(recordType: "Order", predicate: NSPredicate(format: "self contains %@", recordId), options: [.firesOnRecordDeletion])
        } else {
            // Fallback on earlier versions
        }
 */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDate(pickUpTime: String) -> String {
        let datething = Date()
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.month, .day, .year], from: datething)
        return "Pick Up on \(String(describing: components.month?.description)).\(String(describing: components.day?.description)).\(String(describing: components.year?.description)) at \(pickUpTime)"
    }

}
