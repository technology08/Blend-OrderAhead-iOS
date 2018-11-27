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
        
        siren.alertType = .force
        
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
        Siren.shared.checkVersion(checkType: .daily)
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
        let freeWhipped = Modifier(name: "Whipped Cream", price: 0)
        let malt = Modifier(name: "Malt", price: 0.5)
        
        // Sizes
        let largeSizeReallyExpensive = Modifier(name: "Large", price: 1.5)
        let mediumSizeExpensive = Modifier(name: "Medium", price: 1)
        let largeSizeExpensive  = Modifier(name: "Large", price: 1)
        let mediumSizeCheap     = Modifier(name: "Medium", price: 0.25)
        let largeSizeCheap      = Modifier(name: "Large",  price: 0.5)
        let small = Modifier(name: "Small", price: 0)
        
        // Coffee Bar Flavors
        let mocha = Modifier(name: "Mocha", price: 0.5)
        let vanilla = Modifier(name: "Vanilla", price: 0.5)
        let raspberry = Modifier(name: "Raspberry", price: 0.5)
        let caramel = Modifier(name: "Caramel", price: 0.5)
        
        // Smoothie Bar Products
        let product17 = Product(name: "Strawberry", price: 3, modifiers: [modifier, secondmodifier], sizes: [small, largeSizeExpensive], type: "Smoothies")
        let product2  = Product(name: "Pineapple",  price: 3, modifiers: [modifier, secondmodifier], sizes: [small, largeSizeExpensive], type: "Smoothies")
        let product3  = Product(name: "Strawberry Lemonade", price: 3, modifiers: [secondmodifier], sizes: [small, largeSizeExpensive], type: "Smoothies")
        let product15 = Product(name: "Chocolate Shake", price: 3, modifiers: [secondmodifier, malt], sizes: [small, largeSizeExpensive], type: "Ice Cream & Sweets")
        let product16 = Product(name: "Oreo Shake", price: 3, modifiers: [secondmodifier], sizes: [small, largeSizeExpensive], type: "Ice Cream & Sweets")
        
        //Coffee Bar
        let espresso1 = Product(name: "Espresso", price: 1.5, sizes: [small], type: "Espresso")
        let espresso2 = Product(name: "Cortado", price: 2.0, sizes: [small], type: "Espresso")
        let espresso3 = Product(name: "Cappuccino", price: 2.25, sizes: [small], type: "Espresso")
        let espresso4 = Product(name: "Brewed Coffee", price: 1.50, sizes: [small, mediumSizeCheap, largeSizeCheap], type: "Espresso")
        let espresso5 = Product(name: "Cold Brew", price: 2.25, sizes: [small, mediumSizeCheap], type: "Cold Brew")
        let espresso6 = Product(name: "Latte", price: 2.50, modifiers: [mocha, vanilla, raspberry, caramel], sizes: [small, largeSizeCheap], type: "Espresso")
        let hotChocolate = Product(name: "Hot Chocolate", price: 2.00, sizes: [small, mediumSizeExpensive, largeSizeReallyExpensive], type: "Non-Coffee")
        let italianSoda = Product(name: "Raspberry Italian Soda", price: 3, modifiers: [freeWhipped], sizes: [small, largeSizeCheap], type: "Non-Coffee")
        
        let array = [product17, product2, product3, product15, product16, italianSoda, espresso1, espresso2, espresso3, espresso4, espresso5, espresso6, hotChocolate]
        
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

