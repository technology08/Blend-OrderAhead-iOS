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
    
    var ai: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.displayLoadingIndicator()
        fetchMenuItems { (completion, items) in
            if completion {
                self.sortMenuItems(items: items)
                self.stopLoadingIndicator()
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
            guard error == nil else {
                if let error = error as? CKError {
                    let erroralert = error.handleAndAlert(crash: true)
                    self.present(erroralert, animated: true, completion: nil)
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
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func sortMenuItems(items: [Product]) {
        currentSmoothies = []
        currentIceCream = []
        for decoded in items {
            switch decoded.type {
            case "Smoothies":
                currentSmoothies.append(decoded)
            case "Ice Cream & Sweets":
                currentIceCream.append(decoded)
            default:
                print("Encountered product which doesn't conform to category. Record name: \(decoded.name)")
            }
        }
    }
    
    func displayLoadingIndicator() {
        self.ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
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
