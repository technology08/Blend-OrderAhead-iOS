//
//  BlendMenuTableViewController.swift
//  BlendSmoothieBar
//
//  Created by Connor Espenshade on 10/9/17.
//  Copyright © 2017 Connor Espenshade. All rights reserved.
//

import UIKit
import CloudKit

class BlendMenuTableViewController: UITableViewController {
    
    var selectedCategory: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Blend Smoothie Bar"
        self.tableView.separatorColor = UIColor.clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .lightContent
        self.tabBarController?.tabBar.barTintColor = #colorLiteral(red: 0.3294117647, green: 0.3411764706, blue: 0.4117647059, alpha: 1)
        self.tabBarController?.tabBar.tintColor = UIColor.white
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        if #available(iOS 11.0, *) {
            return (self.view.frame.height - (self.view.safeAreaInsets.top + self.view.safeAreaInsets.bottom)) / CGFloat(tableView.numberOfRows(inSection: 0))
        } else {
            // Fallback on earlier versions
            
            return self.tableView.frame.height / CGFloat(tableView.numberOfRows(inSection: 0))
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as! CategoryCell
        
        switch indexPath.row {
        case 0:
            cell.categoryImage.image = #imageLiteral(resourceName: "smoothie")
            cell.categoryLabel.text = "SMOOTHIES"
            cell.category = "Smoothies"
        case 1:
            cell.categoryImage.image = #imageLiteral(resourceName: "shake")
            cell.categoryLabel.text =   """
            ICE CREAM &
            SWEETS
            """
            cell.categoryLabel.numberOfLines = 2
            cell.categoryLabel.textAlignment = .center
            cell.category = "Ice Cream & Sweets"
        default:
            //Grab new categories from CloudKit?
            print("cellforrowat error category cell")
        }        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cellCategory = (tableView.cellForRow(at: indexPath) as! CategoryCell).category
        selectedCategory = cellCategory
        performSegue(withIdentifier: "toMenuOrder", sender: self)
    
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toMenuOrder" {
            if let destination = segue.destination as? OrderMenuViewController {
                destination.currentProductCategory = selectedCategory
                destination.selectedBusiness = .Blend
            }
        }
    }
    
    @IBAction func unwindToTable(sender: UIStoryboardSegue) {
        
    }
}

class CategoryCell: UITableViewCell {
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryImage: UIImageView!
    var category: String!
}
