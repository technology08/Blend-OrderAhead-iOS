//
//  InitialLoadingViewController.swift
//  BlendSmoothieBar
//
//  Created by Connor Espenshade on 1/9/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

import UIKit
import CloudKit
import Firebase

class InitialLoadingViewController: UIViewController {
    
    var ai: UIActivityIndicatorView?
    var processesCompleted = 0 {
        didSet {
            if processesCompleted > 1 {
                DispatchQueue.main.async {
                    self.stopLoadingIndicator()
                    self.performSegue(withIdentifier: "toApp", sender: nil)
                }                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.displayLoadingIndicator()
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = UIColor.systemBackground
        }
        sirenLatestVersionInstalled()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        switch traitCollection.userInterfaceStyle {
//        case .light, .unspecified:
//            self.backgroundColor = UIColor.white
//        }
    }
    
    func sirenLatestVersionInstalled() {
        fetchMenuItems { (completion, items) in
            if completion {
                self.sortMenuItems(items: items)
                self.processesCompleted += 1
            }
        }
        
        fetchLocations { (completion, items) in
            if completion {
                for place in items {
                    locations.append(place)
                }
                self.processesCompleted += 1
            }
        }
    }
    
    func sirenDidFailVersionCheck(error: Error) {
        print(error.localizedDescription)
        
        Analytics.logEvent("siren_version_check_crash", parameters: ["error": error.localizedDescription])
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func fetchMenuItems(completion: @escaping ((Bool, [Product]) -> Void)) {
        let database = CKContainer.default().publicCloudDatabase
        let query = CKQuery(recordType: "Item", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        database.perform(query, inZoneWith: nil, completionHandler: { (results:[CKRecord]?, error:Error?) in
            guard error == nil else {
                if let error = error as? CKError {
                    let erroralert = error.handleAndAlert(crash: true)
                    DispatchQueue.main.async {
                        self.present(erroralert, animated: true, completion: nil)
                    }
                    completion(false, [])
                    return
                }
                fatalError(error.debugDescription)
            }
            
            if let results = results {
                
                var items: [Product] = []
                for result in results {
                    if let data = result["product"] as? Data {
                        do {
                            let decoded = try JSONDecoder().decode(Product.self, from: data)
                            items.append(decoded)
                        } catch {
                            fatalError(error as! String)
                        }
                    }
                }
                
                completion(true, items)
            } else {
                //Create alert to turn on iCloud Drive
                
            }
            
        })
    }
    
    func fetchLocations(completion: @escaping ((Bool, [String]) -> Void)) {
        let database = CKContainer.default().publicCloudDatabase
        let query = CKQuery(recordType: "Location", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        database.perform(query, inZoneWith: nil, completionHandler: { (results:[CKRecord]?, error:Error?) in
            guard error == nil else {
                if let error = error as? CKError {
                    let erroralert = error.handleAndAlert(crash: true)
                    DispatchQueue.main.async {
                        self.present(erroralert, animated: true, completion: nil)
                    }
                    
                    completion(false, [])
                    return
                }
                fatalError(error.debugDescription)
            }
            
            if let results = results {
                
                var items: [String] = []
                for result in results {
                    if let string = result["recordName"] as? String {
                        items.append(string)
                    }
                }
                
                completion(true, items)
            } else {
                //Create alert to turn on iCloud Drive
                
            }
            
        })
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func sortMenuItems(items: [Product]) {
        currentSmoothies = []
        currentIceCream = []
        currentEspresso = []
        currentTea = []
        currentCold = []
        currentNonCoffee = []
        for decoded in items {
            switch decoded.type {
            case "Smoothies":
                currentSmoothies.append(decoded)
            case "Ice Cream & Sweets":
                currentIceCream.append(decoded)
            case "Espresso":
                currentEspresso.append(decoded)
            case "Tea":
                currentTea.append(decoded)
            case "Cold Brew":
                currentCold.append(decoded)
            case "Non-Coffee":
                currentNonCoffee.append(decoded)
            default:
                print("Encountered product which doesn't conform to category. Record name: \(decoded.name)")
            }
        }
    }
    
    func displayLoadingIndicator() {
        self.ai = UIActivityIndicatorView.init(style: .whiteLarge)
        if #available(iOS 13.0, *) {
            switch traitCollection.userInterfaceStyle {
            case .light, .unspecified:
                self.ai?.color = UIColor.black
            case .dark:
                self.ai?.color = UIColor.white
            @unknown default:
                self.ai?.color = UIColor.black
            }
        } else {
            self.ai?.color = UIColor.black
        }
        
        self.ai!.startAnimating()
        self.ai!.center = self.view.center
        
        DispatchQueue.main.async {
            self.view.addSubview(self.ai!)
        }
    }
    
    func stopLoadingIndicator() {
        DispatchQueue.main.async {
            guard let activity = self.ai else { return }
            activity.stopAnimating()
            activity.removeFromSuperview()
        }
    }
}

class TabBar: UITabBarController {}
