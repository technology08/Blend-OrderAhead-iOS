//
//  Apple Pay.swift
//  BlendSmoothieBar
//
//  Created by Connor Espenshade on 6/6/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

import PassKit
import Stripe
import CloudKit

extension OrderMenuViewController: PKPaymentAuthorizationViewControllerDelegate {
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
        
        if applepaysucceeded {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toConfirmation", sender: nil)
            }
        } else if let alert = applepayalert {
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        
        STPAPIClient.shared.createToken(with: payment) { (token: STPToken?, error: Error?) in
            if error == nil {
                guard let token = token else {
                    completion(PKPaymentAuthorizationStatus.failure)
                    return
                }
                guard let orderprice = self.order.finalPrice else {
                    completion(PKPaymentAuthorizationStatus.failure)
                    return
                }
                
                let secondprice = orderprice * 100
                let stripeprice = NSDecimalNumber(decimal: secondprice).intValue
                self.sendToBackendResult(token: token, amount: stripeprice, completion: { (success1, alert)  -> Void in
                    if success1 == PKPaymentAuthorizationStatus.success {
                        self.createOrder(finalOrder: self.order, paid: true) { (success, record, error) in
                            
                            if success {
                                if success {
                                    self.applepaysucceeded = true
                                    completion(.success)
                                } else {
                                    
                                    if let error = error as? CKError {
                                        //HANDLE
                                        let error = error.handleAndAlert()
                                        self.present(error, animated: true, completion: nil)
                                        completion(.failure)
                                    } else if error != nil {
                                        let error = error!.alert()
                                        self.present(error, animated: true, completion: nil)
                                        completion(.failure)
                                    }
                                }
                            }
                        }
                    } else {
                        
                        guard let alert = alert else { completion(success1); return }
                        self.applepayalert = alert
                        completion(success1)
                    }
                    
                    
                })
            } else {
                print(error!)
            }
        }
        
        
    }
    
    @objc func applePayButtonPressed() {
        //if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: supportedNetworks) {
        verify(order: self.order) { (verified) in
            if verified {
                self.testCloudkit(completion: { (testSucceeded) in
                    if testSucceeded {
                        let request = PKPaymentRequest()
                        request.merchantIdentifier = "INSERT_APPLE_MERCHANT_ID"
                        request.countryCode = "US"
                        request.currencyCode = "USD"
                        request.supportedNetworks = self.supportedNetworks
                        request.merchantCapabilities = .capability3DS //CHECK WITH STRIPE
                        
                        let baseItem = PKPaymentSummaryItem(label: "\(self.order.baseProduct.name)", amount: NSDecimalNumber(decimal: self.order.baseProduct.price))
                        
                        request.paymentSummaryItems = [baseItem]
                        
                        if let sizePrice = self.order.sizeUpgradePrice {
                            let paymentitem = PKPaymentSummaryItem(label: self.order.selectedSize!, amount: NSDecimalNumber(decimal: sizePrice))
                            request.paymentSummaryItems.append(paymentitem)
                        }
                        
                        for modifier in self.order.modifiers {
                            let paymentitem = PKPaymentSummaryItem(label: modifier.name!, amount: NSDecimalNumber(decimal: modifier.price!))
                            request.paymentSummaryItems.append(paymentitem)
                        }
                        
                        let finalitem = PKPaymentSummaryItem(label: "BLEND SMOOTHIE BAR", amount: NSDecimalNumber(decimal: self.order.finalPrice!))
                        request.paymentSummaryItems.append(finalitem)
                        
                        let vc = PKPaymentAuthorizationViewController(paymentRequest: request)
                        vc?.delegate = self
                        DispatchQueue.main.async {
                            self.present(vc!, animated: true, completion: nil)
                        }
                        
                        /*} else {
                         //CHECK COPYRIGHT
                         let alert = UIAlertController(title: "Apple Pay Error", message: "No supported cards. Only Visa, Mastercard, American Express, and Discover cards are valid.", preferredStyle: .alert)
                         alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (action) in
                         alert.dismiss(animated: true, completion: nil)
                         }))
                         self.present(alert, animated: true, completion: nil)
                         }*/
                    }
                })
                
            }
        }
    }
}
