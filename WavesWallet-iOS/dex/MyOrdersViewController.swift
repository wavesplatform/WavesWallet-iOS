//
//  MyOrdersViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 22.08.17.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit

let kNotifDidCreateOrder = "kNotifDidCreateOrder"

class MyOrderCell : UITableViewCell {
    
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelType: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var labelAmount: UILabel!
    @IBOutlet weak var labelSum: UILabel!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var buttonDelete: UIButton!

    let dateFormatter = DateFormatter()

    override func awakeFromNib() {
        buttonDelete.tintColor = UIColor(netHex: 0x808080)
    }
    
    func setupCell(_ item: NSDictionary) {
        
        let timeStamp = item["timestamp"] as! Int64 / 1000
        let date = Date(timeIntervalSince1970: Double(timeStamp))
        
        dateFormatter.dateFormat = "dd.MM.yy"
        labelDate.text = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "HH:mm:ss"
        labelTime.text = dateFormatter.string(from: date)
        print(date)
        
        if item["type"] as? String == "sell" {
            labelType.text = "Sell"
            labelType.textColor = LastTraderCell.sellColor()
        }
        else {
            labelType.text = "Buy"
            labelType.textColor = LastTraderCell.buyColor()
        }
        
        labelPrice.textColor = labelType.textColor

        /*
        amount = 100000000;
        assetPair =         {
            amountAsset = WAVES;
            priceAsset = Fmg13HEHJHuZYbtJq8Da8wifJENq8uBxDuWoP9pVe2Qe;
        };
        filled = 0;
        id = ESLFAsJEnzRzCHUdD2ZiVAyPqLfA66cy6hE2ueEwKR56;
        price = 100000000;
        */
        
        if item["status"] as? String == "Accepted" {
            labelStatus.text = "Open"
            labelStatus.textColor = LastTraderCell.buyColor()
        }
        else if item["status"] as? String == "PartiallyFilled" {
            labelStatus.text = "Partial"
            labelStatus.textColor = LastTraderCell.buyColor()

        }
        else if item["status"] as? String == "Cancelled" {
            labelStatus.text = "Cancelled"
            labelStatus.textColor = LastTraderCell.sellColor()

        }
        else if item["status"] as? String == "Filled" {
            labelStatus.text = "Filled"
            labelStatus.textColor = LastTraderCell.sellColor()
        }
    }
}

class MyOrdersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var amountAsset: String!
    var priceAsset: String!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var myOrders : NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.register(UINib.init(nibName: MyOrderHeaderView.getIdentifier(), bundle: nil), forHeaderFooterViewReuseIdentifier: MyOrderHeaderView.getIdentifier())
    
        loadInfo()
        NotificationCenter.default.addObserver(self, selector: #selector(loadInfo), name: Notification.Name(rawValue: kNotifDidCreateOrder), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadInfo () {
        NetworkManager.getMyOrders(amountAsset: amountAsset, priceAsset: priceAsset) { (items, erorMessage) in
            self.activityIndicatorView.stopAnimating()
            if items != nil {
                self.myOrders = (items?.sortedArray(using: [NSSortDescriptor.init(key: "timestamp", ascending: false)]) as? NSArray)!
                self.tableView.reloadData()
            }
        }
    }
    
    func deleteTapped(sender: UIButton) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if myOrders.count == 0 {
            return 0
        }
        
        return 45
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if myOrders.count == 0 {
            return nil
        }
        
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: MyOrderHeaderView.getIdentifier())
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myOrders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyOrderCell", for: indexPath) as! MyOrderCell
        
        if cell.buttonDelete.allTargets.count == 0 {
            cell.buttonDelete.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        }
        
        cell.buttonDelete.tag = indexPath.row
        
        cell.setupCell(myOrders[indexPath.row] as! NSDictionary)
        
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = LastTraderCell.darkBgColor()
        }
        else {
            cell.backgroundColor = LastTraderCell.lightBgColor()
        }
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
