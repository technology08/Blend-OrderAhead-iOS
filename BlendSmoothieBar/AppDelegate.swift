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
        
        STPPaymentConfiguration.shared().publishableKey = "INSERT_STRIPE_PUBLISHABLE_KEY"
        STPPaymentConfiguration.shared().appleMerchantIdentifier = "INSERT_APPLE_MERCHANT_ID"
        
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
        
        let modifier = Modifier(name: "Protein", price: 0.5)
        let secondmodifier = Modifier(name: "Whipped Cream", price: 0.5)
        let freeWhipped = Modifier(name: "No Whipped Cream", price: 0)
        let malt = Modifier(name: "Malt", price: 0.5)
        
        let lemonadeMod = Modifier(name: "Lemonade", price: 0)
        let milkMod = Modifier(name: "Milk", price: 0)
        
        // Sizes
        let largeSizeReallyExpensive = Modifier(name: "Large", price: 1.5)
        let mediumSizeExpensive = Modifier(name: "Medium", price: 1)
        let small = Modifier(name: "Small", price: 0)
        
        // Coffee Bar Flavors
        let mocha = Modifier(name: "Mocha", price: 0.5)
        /*let vanilla = Modifier(name: "Vanilla", price: 0.5)
        let raspberry = Modifier(name: "Raspberry", price: 0.5)*/
        let caramel = Modifier(name: "Caramel", price: 0.5)
        
        // Smoothie Bar Products
        let product17 = Product(name: "Strawberry", price: 5, modifiers: [modifier, secondmodifier, lemonadeMod, milkMod], sizes: [small], type: "Smoothies")
        let product2  = Product(name: "Pineapple",  price: 5, modifiers: [modifier, secondmodifier, lemonadeMod, milkMod], sizes: [small], type: "Smoothies")
        let product3  = Product(name: "Vanilla Shake", price: 5, modifiers: [secondmodifier], sizes: [small], type: "Ice Cream & Sweets")
        let product15 = Product(name: "Chocolate Shake", price: 5, modifiers: [secondmodifier, malt], sizes: [small], type: "Ice Cream & Sweets")
        let product16 = Product(name: "Oreo Shake", price: 5, modifiers: [secondmodifier], sizes: [small], type: "Ice Cream & Sweets")
        
        //Coffee Bar
        let espresso1 = Product(name: "Espresso", price: 2.5, sizes: [small], type: "Espresso")
        let espresso2 = Product(name: "Cortado", price: 3.0, sizes: [small], type: "Espresso")
        let espresso3 = Product(name: "Cappuccino", price: 3.25, sizes: [small], type: "Espresso")
        let espresso4 = Product(name: "Brewed Coffee", price: 2, sizes: [small, Modifier(name: "Medium", price: 0.5), Modifier(name: "Large", price: 1)], type: "Espresso")
        let espresso5 = Product(name: "Cold Brew", price: 3.5, sizes: [Modifier(name: "Large", price: 0)], type: "Cold Brew")
        let espresso6 = Product(name: "Latte", price: 3.5, modifiers: [mocha, caramel], sizes: [Modifier(name: "Medium", price: 0), Modifier(name: "Large", price: 0.5)], type: "Espresso")
        let espresso7 = Product(name: "Chemex", price: 6, modifiers: [], sizes: [small], type: "Espresso")
        let espresso8 = Product(name: "Pour Over", price: 4, modifiers: [], sizes: [small], type: "Espresso")
        let hotChocolate = Product(name: "Hot Chocolate", price: 3, sizes: [small, mediumSizeExpensive, largeSizeReallyExpensive], type: "Non-Coffee")
        
        let teaSize = Modifier(name: "Medium", price: 0)
        let tea1 = Product(name: "Kombucha", price: 4.5, sizes: [teaSize], type: "Tea")
        let chai = Product(name: "Chai Tea Latte", price: 3, sizes: [small, mediumSizeExpensive, largeSizeReallyExpensive], type: "Tea")
        
        let lemonade = Product(name: "Lemonade", price: 3, modifiers: [], sizes: [small], type: "Non-Coffee")
        let raspLemonade = Product(name: "Raspberry Lemonade", price: 3.5, modifiers: [], sizes: [small], type: "Non-Coffee")
        let raspItalianSoda = Product(name: "Raspberry Italian Soda", price: 4, modifiers: [freeWhipped], sizes: [small], type: "Non-Coffee")
        let vanillaItalianSoda = Product(name: "Vanilla Italian Soda", price: 4, modifiers: [freeWhipped], sizes: [small], type: "Non-Coffee")
        let chocolateMilk = Product(name: "Chocolate Milk", price: 3, modifiers: [], sizes: [small], type: "Non-Coffee")
        let milk = Product(name: "Milk", price: 3, modifiers: [], sizes: [small], type: "Non-Coffee")
        
        let icedLatte = Product(name: "Iced Latte", price: 4.0, modifiers: [mocha, caramel], sizes: [small], type: "Cold Brew")
        let macchiato = Product(name: "Macchiato", price: 4.0, modifiers: [mocha, caramel], sizes: [small], type: "Cold Brew")
        
        let array = [product17, product2, product3, product15, product16, espresso1, espresso2, espresso3, espresso4, espresso5, espresso6, espresso7, espresso8, hotChocolate, tea1, lemonade, raspLemonade, raspItalianSoda, vanillaItalianSoda, chocolateMilk, milk, icedLatte, macchiato, chai]
        
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

