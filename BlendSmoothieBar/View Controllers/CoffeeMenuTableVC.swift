//
//  CoffeeMenuTableVC.swift
//  BlendSmoothieBar
//
//  Created by Connor Espenshade on 10/17/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

import UIKit

class CoffeeMenuTableViewController: UITableViewController {
    var selectedCategory: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Leaning Eagle"
        self.tableView.separatorColor = UIColor.clear
        
        if let tabTitles = self.tabBarController?.tabBar.items {
            tabTitles[0].title = "Leaning Eagle"
            tabTitles[1].title = "Blend Smoothie Bar"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .default
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.tabBarController?.tabBar.tintColor = UIColor.black //#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 4
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
            cell.categoryImage.image = #imageLiteral(resourceName: "espresso")
            cell.categoryLabel.text = "ESPRESSO"
            cell.category = "Espresso"
        case 1:
            cell.categoryImage.image = #imageLiteral(resourceName: "tea")
            cell.categoryLabel.text = "TEA"
            cell.category = "Tea"
        case 2:
            cell.categoryImage.image = #imageLiteral(resourceName: "coffee_drinks")
            cell.categoryLabel.text = "COLD BREW"
            cell.category = "Cold Brew"
        case 3:
            cell.categoryImage.image = #imageLiteral(resourceName: "soda")
            cell.categoryLabel.text = "NON-COFFEE"
            cell.category = "Non-Coffee"
        default:
            fatalError()
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cellCategory = (tableView.cellForRow(at: indexPath) as! CategoryCell).category
        selectedCategory = cellCategory
        performSegue(withIdentifier: "toMenuOrderCoffee", sender: self)
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toMenuOrderCoffee" {
            if let destination = segue.destination as? OrderMenuViewController {
                destination.currentProductCategory = selectedCategory
                destination.selectedBusiness = .LeaningEagle
            }
        }
    }
    
    @IBAction func unwindToCoffeeTable(sender: UIStoryboardSegue) {
        
    }
}
