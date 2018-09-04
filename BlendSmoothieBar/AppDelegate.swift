//
//  AppDelegate.swift
//  BlendSmoothieBar
//
//  Created by Connor Espenshade on 10/7/17.
//  Copyright © 2017 Connor Espenshade. All rights reserved.
//

import UIKit
import AWSCore
import AWSCognito
import Stripe
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //createMenuItems()
        //Stripe Setup
        
        STPPaymentConfiguration.shared().publishableKey = "INSERT_STRIPE_PUBLISHABLE_KEY"
        STPPaymentConfiguration.shared().appleMerchantIdentifier = "INSERT_APPLE_MERCHANT_ID"
        
        //AWS Setup
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "INSERT_AWS_KEY")
        let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider: credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func createMenuItems() {
        CKContainer.default().publicCloudDatabase.perform(CKQuery(recordType: "Item", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil)), inZoneWith: nil, completionHandler: { (results:[CKRecord]?, error:Error?) in
            guard error == nil else { print(error!); return }
            guard let results = results else { return }
            for record in results {
                CKContainer.default().publicCloudDatabase.delete(withRecordID: record.recordID, completionHandler: { (record, error) in
                    
                })
            }
            
        })
        
        let modifier = Modifier(name: "Protein", price: 0.5)
        let secondmodifier = Modifier(name: "Whipped Cream", price: 0.5)
        let malt = Modifier(name: "Malt", price: 0.5)
        let largeSize = Modifier(name: "Make it a Large?", price: 1)
        //Encoder
        
        let product17 = Product(name: "Strawberry", price: 3, modifiers: [modifier, secondmodifier, largeSize], type: "Smoothies")
        let product2 = Product(name: "Pineapple", price: 3, modifiers: [modifier, secondmodifier, largeSize], type: "Smoothies")
        let product3 = Product(name: "Strawberry Lemonade", price: 3, modifiers: [secondmodifier, largeSize], type: "Smoothies")
        let product15 = Product(name: "Chocolate Shake", price: 3, modifiers: [secondmodifier, malt, largeSize], type: "Ice Cream & Sweets")
        let product16 = Product(name: "Oreo Shake", price: 3, modifiers: [secondmodifier, largeSize], type: "Ice Cream & Sweets")
        
        let array = [product17, product2, product3, product15, product16]
        
        for item in array {
            do {
                let encoded = try JSONEncoder().encode(item)
                let record = CKRecord(recordType: "Item")
                record["product"] = encoded as CKRecordValue
                record["name"] = item.name as CKRecordValue
                
                CKContainer.default().publicCloudDatabase.save(record) { (record, error) in
                    if error != nil {
                        print(error!)
                    } else {
                        print("Added \(item.name)")
                    }
                }
            } catch {
                print(error)
            }
        }
    }
 
}

