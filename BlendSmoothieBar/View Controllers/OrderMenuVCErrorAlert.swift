//
//  OrderMenuVCErrorAlert.swift
//  BlendSmoothieBar
//
//  Created by Connor Espenshade on 9/4/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

import UIKit

extension OrderMenuViewController {
    func createErrorAlert(alertBody: String, presentTryAgain: Bool)  -> UIAlertController {
        let alert = UIAlertController(title: "Error", message: alertBody, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        return alert
    }
    
    func createUserErrorAlert(alertBody: String) {
        let alert = UIAlertController(title: "Missing Field", message: alertBody, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
