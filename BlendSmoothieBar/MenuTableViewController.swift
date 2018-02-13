//
//  MenuTableViewController.swift
//  BlendSmoothieBar
//
//  Created by Connor Espenshade on 10/9/17.
//  Copyright © 2017 Connor Espenshade. All rights reserved.
//

import UIKit
import CloudKit

class MenuTableViewController: UITableViewController {

    var selectedCategory: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        self.navigationItem.title = "Menu"
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        if #available(iOS 11.0, *) {
            return (self.view.frame.height - (self.view.safeAreaInsets.top + self.view.safeAreaInsets.bottom)) / CGFloat(tableView.numberOfRows(inSection: 0))
        } else {
            // Fallback on earlier versions
 
            //return (self.view.frame.height - (self.navigationController?.navigationBar.frame.height)!) / 4
            return self.tableView.frame.height / CGFloat(tableView.numberOfRows(inSection: 0))
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as! CategoryCell

        // Configure the cell...

        switch indexPath.row {
        case 0:
            cell.categoryImage.image = #imageLiteral(resourceName: "smoothie")
            cell.categoryLabel.text = "SMOOTHIES"
            cell.category = "Smoothies"
        case 1:
            cell.categoryLabel.text = "BEVERAGES"
            cell.category = "Drinks"
            cell.categoryImage.image = #imageLiteral(resourceName: "drink")
        case 2:
            cell.categoryImage.image = #imageLiteral(resourceName: "shake")
            cell.categoryLabel.text =   """
                                        ICE CREAM &
                                        SWEETS
                                        """
            cell.categoryLabel.numberOfLines = 2
            cell.categoryLabel.textAlignment = .center
            cell.category = "Ice Cream & Sweets"
        case 3:
            cell.categoryImage.image = #imageLiteral(resourceName: "waffle")
            cell.categoryLabel.text = "FOOD"
            cell.category = "Food"
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
            }
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    @IBAction func unwindToTable(sender: UIStoryboardSegue) {
        
    }
}

class CategoryCell: UITableViewCell {
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryImage: UIImageView!
    var category: String!
}
