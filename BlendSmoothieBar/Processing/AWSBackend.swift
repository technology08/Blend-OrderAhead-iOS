//
//  AWS Backend.swift
//  BlendSmoothieBar
//
//  Created by Connor Espenshade on 6/6/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

import Stripe
import PassKit
import AWSLambda
import Firebase

extension OrderMenuViewController {
    // MARK: - Backend Function
    /**
     Sends Stripe token to AWS Lambda backend.
     - Parameter token: The token from the successful Apple Pay transaction.
     - Parameter amount: The $ amount in Int form. $xx.xx becomes $xxxx.
     - Parameter completion: The completion handler with a status and optional Alert Controller containing an error.
 */
    func sendToBackendResult(token: STPToken, amount: Int, completion: @escaping ((PKPaymentAuthorizationStatus, UIAlertController?) -> Void)) {
        
        let lambdaInvoker = AWSLambdaInvoker.default()
        let jsonObject: [String: Any] = ["tokenId": token.tokenId, "amount": amount]
        
        let _ = lambdaInvoker.invokeFunction("CreateStripe", jsonObject: jsonObject).continueWith { (task) -> Any? in
            
            if let error = task.error as NSError? {
                if error.domain == AWSLambdaInvokerErrorDomain && AWSLambdaInvokerErrorType.functionError == AWSLambdaInvokerErrorType(rawValue: error.code) {
                    print("Function error: \(error.userInfo[AWSLambdaInvokerFunctionErrorKey] ?? "Unknown")")
                    fatalError("Function error: \(error.userInfo[AWSLambdaInvokerFunctionErrorKey] ?? "Unknown")")
                    //completion(.failure)
                } else {
                    print("Error: \(error)")
                    fatalError("Error: \(error.localizedDescription)")
                    //completion(.failure)
                }
                
            } else if let response = task.result! as? String {
                //print(response)
                //SUCCESS
                if response == "Charge processed successfully!" {
                    
                    completion(.success, nil)
                    //API ERRORS
                } else if response == "StripeInvalidRequestError" {
                    
                    
                    let alert = self.createErrorAlert(alertBody: "The payment request was invalid. Please try again or pay in cash at pickup.", presentTryAgain: true)
                    
                    completion(.failure, alert)
                } else if response == "api_connection_error" || response == "StripeApiConnectionError" {
                    
                    //DispatchQueue.main.async {
                    let alert = self.createErrorAlert(alertBody: "Bad internet connection. Please check your internet settings and try again.", presentTryAgain: true)
                    //}
                    completion(.failure, alert)
                } else if response == "rate_limit_error" || response == "StripeRateLimitError" || response == "authentication_error" || response == "StripeAuthenticationError" {
                    
                    
                    let alert = self.createErrorAlert(alertBody: "Bad connection to server. Please try again.", presentTryAgain: true)
                    
                    
                    completion(.failure, alert)
                    //CARD ERRORS
                } else if response == "invalid_number" || response == "StripeInvalidNumber" || response == "incorrect_number" || response == "StripeIncorrectNumber" {
                    
                    // DispatchQueue.main.async {
                    let alert = self.createErrorAlert(alertBody: "Invalid credit card number.", presentTryAgain: false)
                    //}
                    
                    completion(.failure, alert)
                } else if response == "invalid_expiry_month" || response == "StripeExpiryMonth" || response == "invalid_expiry_year" || response == "StripeExpiryYear"{
                    
                    //DispatchQueue.main.async {
                    let alert = self.createErrorAlert(alertBody: "Invalid expiration date.", presentTryAgain: false)
                    //}
                    
                    completion(.failure, alert)
                } else if response == "invalid_cvc" || response == "StripeInvalidCvc" || response == "incorrect_cvc" || response == "StripeIncorrectCvc"{
                    
                    //DispatchQueue.main.async {
                    let alert = self.createErrorAlert(alertBody: "Invalid security code.", presentTryAgain: false)
                    //}
                    
                    completion(.failure, alert)
                } else if response == "card_declined" || response == "StripeCardDecline" {
                    
                    //DispatchQueue.main.async {
                    let alert = self.createErrorAlert(alertBody: "The credit card used was declined by the issuer.", presentTryAgain: true)
                    //}
                    
                    completion(.failure, alert)
                } else if response == "expired_card" || response == "StripeExpiredCard" {
                    
                    //DispatchQueue.main.async {
                    let alert = self.createErrorAlert(alertBody: "The credit card used is expired.", presentTryAgain: false)
                    //}
                    
                    completion(.failure, alert)
                } else if response == "processing_error" || response == "StripeProcessingError" {
                    
                    //DispatchQueue.main.async {
                    let alert = self.createErrorAlert(alertBody: "There was an error during processing.", presentTryAgain: true)
                    //}
                    
                    completion(.failure, alert)
                } else {
                    //DispatchQueue.main.async {
                    let alert = self.createErrorAlert(alertBody: "Unknown error was \(response).", presentTryAgain: true)
                    //}
                    
                    Analytics.logEvent("stripe_processor_error", parameters: ["error": response])
                    
                    completion(.failure, alert)
                }
                
            } else {
                print("No response")
                completion(.failure, nil)
            }
            return nil
        }
    }
}
