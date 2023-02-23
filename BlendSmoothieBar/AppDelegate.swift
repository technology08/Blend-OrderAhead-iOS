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
import Firebase
import UserNotifications
import Siren

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //createMenuItems()
        //createLocations()
        //Stripe Setup
        
        STPPaymentConfiguration.shared.publishableKey = "INSERT_STRIPE_PUBLISHABLE_KEY"
        STPPaymentConfiguration.shared.appleMerchantIdentifier = "INSERT_APPLE_MERCHANT_ID"
        
        //AWS Setup
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "INSERT_AWS_KEY")
        let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider: credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        //UIApplication.shared.statusBarStyle = .lightContent
        
        FirebaseApp.configure()
        
        //Check App Store for new update
        let siren = Siren.shared
        siren.rulesManager = RulesManager(globalRules: Rules(promptFrequency: .immediately, forAlertType: .force), showAlertAfterCurrentVersionHasBeenReleasedForDays: 1)
        siren.wail()
        
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
        
        // Modifiers
        let extraWhippedCream = Modifier(name: "Whipped Cream", price: 0.5)
        let freeWhipped = Modifier(name: "No Whipped Cream", price: 0)
        let malt = Modifier(name: "Malt", price: 0.5)
        let oatmilk = Modifier(name: "Oatmilk", price: 0.25)
        
        // Size Modifires
        let largeSize = Modifier(name: "Large", price: 1)
        let mediumSize = Modifier(name: "Medium", price: 0.5)
        let smallSize = Modifier(name: "Small", price: 0)
        
        // Coffee Bar Flavors
        let mocha = Modifier(name: "Mocha", price: 0.5)
        let whiteMocha = Modifier(name: "White Mocha", price: 0.5)
        let vanilla = Modifier(name: "Vanilla", price: 0.5)
        let raspberry = Modifier(name: "Raspberry", price: 0.5)
        let caramel = Modifier(name: "Caramel", price: 0.5)
        let lavender = Modifier(name: "Lavender", price: 0.5)
        
        // Smoothie Bar Products
        let product17 = Product(name: "Strawberry", price: 5, modifiers: [extraWhippedCream], sizes: [smallSize], type: "Smoothies")
        let product3  = Product(name: "Vanilla Shake", price: 6, modifiers: [extraWhippedCream], sizes: [smallSize], type: "Ice Cream & Sweets")
        let product15 = Product(name: "Chocolate Shake", price: 6, modifiers: [extraWhippedCream, malt], sizes: [smallSize], type: "Ice Cream & Sweets")
        let product16 = Product(name: "Oreo Shake", price: 6, modifiers: [extraWhippedCream], sizes: [smallSize], type: "Ice Cream & Sweets")
        
        //Coffee Bar
        let espresso1 = Product(name: "Espresso", price: 2.75, sizes: [smallSize], type: "Espresso")
        let espresso2 = Product(name: "Cortado", price: 3.25, sizes: [smallSize], type: "Espresso")
        let espresso3 = Product(name: "Cappuccino", price: 3.5, sizes: [smallSize], type: "Espresso")
        let espresso4 = Product(name: "Brewed Coffee", price: 3, sizes: [smallSize], type: "Espresso")
//        let espresso5 = Product(name: "Cold Brew", price: 3.5, sizes: [Modifier(name: "Large", price: 0)], type: "Cold Brew")
        let espresso6 = Product(name: "Latte", price: 3.5, modifiers: [mocha, caramel, vanilla, raspberry, whiteMocha, lavender], sizes: [Modifier(name: "Medium", price: 0), Modifier(name: "Large", price: 0.5)], type: "Espresso")
//        let espresso7 = Product(name: "Chemex", price: 6, modifiers: [], sizes: [small], type: "Espresso")
//        let espresso8 = Product(name: "Pour Over", price: 4, modifiers: [], sizes: [small], type: "Espresso")
        let hotChocolate = Product(name: "Hot Chocolate", price: 3, sizes: [smallSize, mediumSize, largeSize], type: "Non-Coffee")
        
        let chai = Product(name: "Chai Latte", price: 3.5, modifiers: [oatmilk], sizes: [smallSize, mediumSize, largeSize], type: "Tea")
        let icedChai = Product(name: "Iced Chai", price: 4.5, modifiers: [oatmilk], type: "Tea")
        
        let lemonade = Product(name: "Lemonade", price: 3, modifiers: [], sizes: [smallSize], type: "Non-Coffee")
        let raspLemonade = Product(name: "Raspberry Lemonade", price: 3.5, modifiers: [], sizes: [smallSize], type: "Non-Coffee")
        let raspItalianSoda = Product(name: "Raspberry Italian Soda", price: 4, modifiers: [freeWhipped], sizes: [smallSize], type: "Non-Coffee")
        let vanillaItalianSoda = Product(name: "Vanilla Italian Soda", price: 4, modifiers: [freeWhipped], sizes: [smallSize], type: "Non-Coffee")
        let refresher = Product(name: "Strawberry Refresher", price: 3.75, modifiers: [Modifier(name: "Lemonade", price: 0.5)], type: "Non-Coffee")
        
        let icedLatte = Product(name: "Iced Latte", price: 4.5, modifiers: [mocha, caramel, vanilla, raspberry, whiteMocha, lavender], sizes: [smallSize], type: "Cold Brew")
        let macchiato = Product(name: "Macchiato", price: 4.5, modifiers: [mocha, caramel, vanilla, raspberry, whiteMocha, lavender], sizes: [smallSize], type: "Cold Brew")
        let frappe = Product(name: "Mocha Frappe", price: 4.5, modifiers: [], sizes: [smallSize], type: "Cold Brew")
        
        // SEASONAL
        
        let pumpkinLatte = Product(name: "Pumpkin Spice Latte", price: 5, type: "Espresso")
        let pumpkinMacchiato = Product(name: "Pumpkin Spice Macchiato", price: 5, type: "Espresso")
        let pumpkinColdFoam = Product(name: "Pumpkin Spice Cold Foam", price: 4.75, type: "Cold Brew")
        let pumpkinWhiteMocha = Product(name: "Pumpkin White Mocha", price: 5, type: "Espresso")
        let brownSugarLatte = Product(name: "Brown Sugar Latte", price: 5, type: "Espresso")
        let brownSugarMacchiato = Product(name: "Brown Sugar Macchiato", price: 5, type: "Espresso")
        let brownSugarColdFoam = Product(name: "Brown Sugar Cold Foam", price: 4.75, type: "Cold Brew")
        let cider = Product(name: "Apple Cider", price: 3, modifiers: [caramel], type: "Non-Coffee")
        let pumpkinChai = Product(name: "Pumpkin Spice Chai", price: 5, type: "Tea")
        let pumpkinMilkshake = Product(name: "Pumpkin Milkshake", price: 6.5, type: "Ice Cream & Sweets")
        
        let array = [product17, product3, product15, product16, espresso1, espresso2, espresso3, espresso4, espresso6, hotChocolate, lemonade, raspLemonade, raspItalianSoda, vanillaItalianSoda, icedLatte, macchiato, chai, frappe, icedChai, refresher,
            pumpkinLatte, pumpkinMacchiato, pumpkinColdFoam, pumpkinWhiteMocha, brownSugarLatte, brownSugarMacchiato, brownSugarColdFoam, cider, pumpkinChai, pumpkinMilkshake
        ]
        
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
    
    func createLocations() {
        CKContainer.default().publicCloudDatabase.perform(CKQuery(recordType: "Location", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil)), inZoneWith: nil, completionHandler: { (results:[CKRecord]?, error:Error?) in
            guard error == nil else { print(error!); return }
            guard let results = results else { return }
            for record in results {
                CKContainer.default().publicCloudDatabase.delete(withRecordID: record.recordID, completionHandler: { (record, error) in
                    
                })
            }
            
        })
        
        let deliveries = ["Library", "Savage Greenhouse", "Howarth W223", "Salkil N149", "Parker E206", "Turvey W227", "Carter W229", "Swedes E204", "Barron W228", "Gansle E108", "Ciarniello W125", "Ewen W127", "Student Services W122A", "Counselors", "Delanoy E112", "SOS Room"]
        
        for item in deliveries {
            let record = CKRecord(recordType: "Location")
            record["recordName"] = item as CKRecordValue
            CKContainer.default().publicCloudDatabase.save(record) { (record, error) in
                if error != nil {
                    print(error!)
                } else {
                    print("Added \(item)")
                }
            }
        }
    }
    /*
     func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any])  {
     // Print message ID.
     if let messageID = userInfo[gcmMessageIDKey] {
     print("Message ID: \(messageID)")
     }
     
     // Print full message.
     print(userInfo)
     }
     
     func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
     if let messageID = userInfo[gcmMessageIDKey] {
     print("Message ID: \(messageID)")
     }
     
     // Print full message.
     print(userInfo)
     
     completionHandler(UIBackgroundFetchResult.newData)
     }
     
     func setupFCM() {
     if #available(iOS 10.0, *) {
     // For iOS 10 display notification (sent via APNS)
     UNUserNotificationCenter.current().delegate = self
     
     let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
     UNUserNotificationCenter.current().requestAuthorization(
     options: authOptions,
     completionHandler: {_, _ in })
     } else {
     let settings: UIUserNotificationSettings =
     UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
     application.registerUserNotificationSettings(settings)
     }
     
     application.registerForRemoteNotifications()
     Messaging.messaging().delegate = self
     }
     */
}

