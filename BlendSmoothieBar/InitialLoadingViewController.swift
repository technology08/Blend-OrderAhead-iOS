//
//  InitialLoadingViewController.swift
//  BlendSmoothieBar
//
//  Created by Connor Espenshade on 1/9/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

import UIKit
import CloudKit

class InitialLoadingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        fetchMenuItems { (completion, items) in
            if completion {
                self.sortMenuItems(items: items)
                self.performSegue(withIdentifier: "toApp", sender: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            guard error == nil else { fatalError(error.debugDescription) }
            
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
    
    func sortMenuItems(items: [Product]) {
        currentSmoothies = []
        currentIceCream = []
        currentFoods = []
        currentDrinks = []
        for decoded in items {
            switch decoded.type {
            case "Smoothies":
                currentSmoothies.append(decoded)
            case "Drinks":
                currentDrinks.append(decoded)
            case "Ice Cream & Sweets":
                currentIceCream.append(decoded)
            case "Food":
                currentFoods.append(decoded)
            default:
                print("Encountered product which doesn't conform to category. Record name: \(decoded.name)")
            }
        }
    }
}
