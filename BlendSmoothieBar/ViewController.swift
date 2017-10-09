//
//  ViewController.swift
//  BlendSmoothieBar
//
//  Created by Connor Espenshade on 10/7/17.
//  Copyright © 2017 Connor Espenshade. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var currentSmoothie = 0
    var currentShake = 0
    var currentFoodItem = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return currentSmoothies.count
        case 1:
            return currentShakes.count
        case 2:
            return currentFoods.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*
         if indexPath.row % 2 == 0 {
         //EVEN
         let cell = tableView.dequeueReusableCell(withIdentifier: "blank")
         return cell!
         } else {
         */
        //ODD
        switch indexPath.section {
        case 0:
            
            let smoothie = currentSmoothies[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "namePriceCell") as! namePriceCell
            cell.productNameLabel.text = smoothie.name
            cell.productPriceLabel.text = "$\(smoothie.price!)"
            cell.product = smoothie
            currentSmoothie += 1
            cell.contentView.frame = UIEdgeInsetsInsetRect(cell.contentView.frame, UIEdgeInsetsMake(10, 0, 10, 0))
            return cell
            
        case 1:
            
            let shake = currentShakes[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "namePriceCell") as! namePriceCell
            cell.productNameLabel.text = shake.name
            cell.productPriceLabel.text = "$\(shake.price!)"
            cell.product = shake
            currentShake += 1
            return cell
            
            
        case 2:
            
            let food = currentFoods[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "namePriceDescriptionCell") as! namePriceDescriptionCell
            cell.productNameLabel.text = food.name
            cell.productPriceLabel.text = "$\(food.price!)"
            cell.productDescriptionLabel.text = food.description
            cell.product = food
            currentFoodItem += 1
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "blank")
            return cell!
        }
        //}
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = Bundle.main.loadNibNamed("MenuTableHeader", owner: self, options: nil)?.first as! MenuTableHeader
        switch section {
        case 0 :
            header.sectionName.text = "Smoothies"
        case 1:
            header.sectionName.text = "Shakes"
        case 2:
            header.sectionName.text = "Food"
        default:
            header.sectionName.text = ""
        }
        return header
    }
    
}

class fullProductCell: UITableViewCell {
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    var product: Product?
}

class namePriceImageCell: UITableViewCell {
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    var product: Product?
}

class namePriceCell: UITableViewCell {
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    var product: Product?
}

class namePriceDescriptionCell: UITableViewCell {
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    var product: Product?
}

class blank: UITableViewCell {
    
}
