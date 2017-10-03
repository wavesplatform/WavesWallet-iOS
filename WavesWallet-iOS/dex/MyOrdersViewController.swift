//
//  MyOrdersViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 22.08.17.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit
import SVProgressHUD



class MyOrderCell : UITableViewCell {
    
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelType: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var labelAmount: UILabel!
    @IBOutlet weak var labelSum: UILabel!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var buttonDelete: UIButton!
    @IBOutlet weak var labelFilled: UILabel!

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
        
        labelFilled.textColor = labelStatus.textColor

        if item["status"] as? String == "Accepted" ||
            item["status"] as? String == "PartiallyFilled" {
            buttonDelete.setImage(nil, for: .normal)
            buttonDelete.setTitle("X", for: .normal)
        }
        else {
            buttonDelete.setImage(UIImage(named:"delete"), for: .normal)
            buttonDelete.setTitle(nil, for: .normal)
        }
    }
}

class MyOrdersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var amountAsset: String!
    var priceAsset: String!

    var amountAssetDecimal: Int!
    var priceAssetDecimal: Int!

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var myOrders : NSArray = []
    
    var isLoading = false
    
    let refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 0, width: 30, height: 30))

    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.register(UINib.init(nibName: MyOrderHeaderView.getIdentifier(), bundle: nil), forHeaderFooterViewReuseIdentifier: MyOrderHeaderView.getIdentifier())
    
        loadInfo()
        NotificationCenter.default.addObserver(self, selector: #selector(loadInfo), name: Notification.Name(rawValue: kNotifDidCreateOrder), object: nil)

        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func refresh() {
        controllerWillAppear()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadInfo () {
        
        isLoading = true
        NetworkManager.getMyOrders(amountAsset: amountAsset, priceAsset: priceAsset) { (items, erorMessage) in
            self.isLoading = false
            self.activityIndicatorView.stopAnimating()
            if items != nil {
                self.myOrders = items!.sortedArray(using: [NSSortDescriptor.init(key: "timestamp", ascending: false)]) as! NSArray
                self.tableView.reloadData()
            }
            
            self.refreshControl.endRefreshing()
            SVProgressHUD.dismiss()
        }
    }
    
    func controllerWillAppear() {
        
        if isLoading {
            return()
        }
        
        loadInfo()
    }
    
    func deleteCancelTapped(sender: UIButton) {
        SVProgressHUD.show()
        
        WalletManager.getPrivateKey(complete: { (privateKey) in
          
            let item = self.myOrders[sender.tag] as! NSMutableDictionary
            
            let req = CancelOrderRequest(sender: WalletManager.currentWallet!.publicKeyAccount, orderId: item["id"] as! String)
            req.senderPrivateKey = privateKey
            
            if item["status"] as? String == "Filled" ||
                item["status"] as? String == "Cancelled" {
                
                NetworkManager.deleteOrder(amountAsset: self.amountAsset, priceAsset: self.priceAsset, request: req, complete: { (errorMessage) in

                    if errorMessage != nil {
                        SVProgressHUD.dismiss()
                        self.presentBasicAlertWithTitle(title: errorMessage!)
                    }
                    else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.loadInfo()
                        }
                    }
                })
            }
            else if item["status"] as? String == "Accepted" ||
                item["status"] as? String == "PartiallyFilled" {
         
                NetworkManager.cancelOrder(amountAsset: self.amountAsset, priceAsset: self.priceAsset, request: req, complete: { (errorMessage) in

                    sender.isEnabled = true
                    if errorMessage != nil {
                        SVProgressHUD.dismiss()
                        self.presentBasicAlertWithTitle(title: errorMessage!)
                    }
                    else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.loadInfo()
                        }
                    }
                })
            }
            
        }) { (errorMessage) in
            SVProgressHUD.dismiss()
            self.presentBasicAlertWithTitle(title: errorMessage)
        }
        
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
            cell.buttonDelete.addTarget(self, action: #selector(deleteCancelTapped), for: .touchUpInside)
        }
        
        cell.buttonDelete.tag = indexPath.row
        let item = myOrders[indexPath.row] as! NSDictionary
        cell.setupCell(item)
        
        cell.labelFilled.text = MoneyUtil.getScaledTextTrimZeros(item["filled"] as! Int64, decimals: self.amountAssetDecimal)
        let amount = item["amount"] as! Int64
        let price = item["price"] as! Int64
        let sum = MoneyUtil.getScaledDecimal(amount, amountAssetDecimal) * MoneyUtil.getScaledDecimal(price, 8 + self.priceAssetDecimal - self.amountAssetDecimal)
        cell.labelSum.text = MoneyUtil.formatDecimals(sum, decimals: self.priceAssetDecimal)

        cell.labelPrice.text = MoneyUtil.getScaledText(price, decimals: priceAssetDecimal, scale: 8 + priceAssetDecimal - amountAssetDecimal)
        cell.labelAmount.text = MoneyUtil.getScaledTextTrimZeros(amount, decimals: self.amountAssetDecimal)
        
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = LastTraderCell.lightBgColor()
        }
        else {
            cell.backgroundColor = LastTraderCell.darkBgColor()
        }
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
