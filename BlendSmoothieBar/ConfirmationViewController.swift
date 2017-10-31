//
//  ConfirmationViewController.swift
//  BlendSmoothieBar
//
//  Created by Connor Espenshade on 10/30/17.
//  Copyright © 2017 Connor Espenshade. All rights reserved.
//

import UIKit

class ConfirmationViewController: UIViewController {

    @IBOutlet weak var orderName: UILabel!
    @IBOutlet weak var pickUpDate: UILabel!
    @IBOutlet weak var pickUpLocation: UILabel!
    @IBOutlet weak var amountDue: UILabel!
    
    var date: String?
    var order: Order! {
        didSet {
            orderName.text = "Order Name: \(order.orderName)"
            pickUpDate.text = getDate(pickUpTime: order.pickUpTime)
            pickUpLocation.text = "Pick Up at \(String(describing: order.pickUpPlace ?? order.pickUpTime))"
            if order.payed {
                amountDue.text = "Pre-Paid"
            } else {
                amountDue.text = "$\(order.finalPrice)"
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
