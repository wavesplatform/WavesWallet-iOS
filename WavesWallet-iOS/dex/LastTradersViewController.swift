//
//  LastTradersViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 05.07.17.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit

class LastTraderCell: UITableViewCell {
    
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var labelAmount: UILabel!
    @IBOutlet weak var labelSum: UILabel!

    class func darkBgColor() -> UIColor {
        return UIColor(red: 240, green: 240, blue: 240)//(netHex: 0x363941)
    }
    
    class func lightBgColor() -> UIColor {
        return UIColor.white//(netHex: 0x3f424a)
    }
    
    class func sellColor() -> UIColor {
        return UIColor(netHex: 0xc7626f)
    }
    
    class func buyColor() -> UIColor {
        return UIColor(netHex: 0x48976e)
    }
}

class LastTradersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var priceAsset : String!
    var amountAsset : String!
    
    var isLoading: Bool = false
    
    var lastTraders : NSArray = []
    
    let dateFormatter = DateFormatter()
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateFormat = "HH:mm:ss"
    
        tableView.register(UINib.init(nibName: LastTraderHeaderView.getIdentifier(), bundle: nil), forHeaderFooterViewReuseIdentifier: LastTraderHeaderView.getIdentifier())
    }

    func controllerWillAppear() {
        
        if isLoading {
            return
        }
        
        isLoading = true
        
        NetworkManager.getLastTraders(amountAsset: amountAsset, priceAsset: priceAsset) { (items, errorMessage) in
            
            self.isLoading = false
            self.activityIndicatorView.stopAnimating()
            
            if items != nil {
                self.lastTraders = items!
                self.tableView.reloadData()
            }
        }

    }
    
    //MARK: UITableView
    

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return LastTraderHeaderView.viewHeight()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: LastTraderHeaderView.getIdentifier())
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lastTraders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LastTraderCell", for: indexPath) as! LastTraderCell
       
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = LastTraderCell.darkBgColor()
        }
        else {
            cell.backgroundColor = LastTraderCell.lightBgColor()
        }
        
        let item = lastTraders[indexPath.row] as! NSDictionary

        let amount = Double((item["amount"] as! String))!
        let price = Double((item["price"] as! String))!
        let sum = amount * price
        
        cell.labelAmount.text = String(format: "%0.3f", amount)
        cell.labelPrice.text = String(format: "%0.8f", price)
        cell.labelSum.text = String(format: "%0.6f", sum)
        
        if item["type"] as? String == "sell" {
            cell.labelPrice.textColor = LastTraderCell.sellColor()
        }
        else {
            cell.labelPrice.textColor = LastTraderCell.buyColor()
        }
        
        let timestamp = item["timestamp"] as! Double
        let date = Date(timeIntervalSince1970: timestamp / 1000)
        cell.labelTime.text = dateFormatter.string(from: date)
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
