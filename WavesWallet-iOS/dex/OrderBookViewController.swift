//
//  OrderBookViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 05.07.17.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit

class OrderCell: UITableViewCell {
    
    @IBOutlet weak var labelBuy: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var labelSell: UILabel!

    
}

class OrderBookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var priceAsset : String!
    var amountAsset : String!
    var priceAssetDecimal: Int!
    var amountAssetDecimal: Int!

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var bids = [NSDictionary]()
    var asks = [NSDictionary]()
    
    var isLoading: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadInfo {
            self.activityIndicator.stopAnimating()
            
            if self.asks.count > 0 && self.bids.count > 0 {
                self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 1), at: .middle, animated: false)
            }
        }
    }

    func controllerWillAppear() {
        
        if isLoading {
            return
        }
        
        loadInfo {
            
        }
    }
    
    
    func loadInfo(complete: @escaping (Void) -> Void)  {
        isLoading = true
    
        NetworkManager.getOrderBook(amountAsset: amountAsset, priceAsset: priceAsset) { (info, errorMessage) in
            
            self.isLoading = false
            
            if info != nil {
                
                self.bids.removeAll()
                self.asks.removeAll()
                
                if let _bids = info!["bids"] as? NSArray {
                    self.bids.append(contentsOf: _bids as! [NSDictionary])
                }
                
                if var _asks = info!["asks"] as? NSArray {
                    _asks = _asks.sortedArray(using: [NSSortDescriptor.init(key: "amount", ascending: false)]) as NSArray
                    self.asks.append(contentsOf: _asks as! [NSDictionary])
                }
                
                self.tableView.reloadData()
            }
            
            complete()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return asks.count
        }

        return bids.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath) as! OrderCell
        
        cell.labelSell.textColor = UIColor.white
        cell.labelBuy.textColor = UIColor.white
        cell.labelPrice.textColor = UIColor(netHex: 0x808080)
        
        if indexPath.row % 2 == 0 {
            cell.labelPrice.backgroundColor = UIColor(netHex: 0xe0e0e0)
        }
        else {
            cell.labelPrice.backgroundColor = UIColor(netHex: 0xf0f0f0)
        }
        
        if indexPath.section == 0 {
            
            let item = asks[indexPath.row]
             
            cell.labelPrice.text = MoneyUtil.getScaledText(item["price"] as! Int64, decimals: priceAssetDecimal, scale: 8 + priceAssetDecimal - amountAssetDecimal)
            cell.labelSell.text = MoneyUtil.getScaledTextTrimZeros(item["amount"] as! Int64, decimals: amountAssetDecimal)

            cell.labelBuy.text = ""
            cell.labelBuy.backgroundColor = UIColor.clear
            
            if indexPath.row % 2 == 0 {
                cell.labelSell.backgroundColor = UIColor(netHex: 0xe66a67)
            }
            else {
                cell.labelSell.backgroundColor = UIColor(netHex: 0xe97c79)
            }
        }
        else {
            
            let item = bids[indexPath.row]
            
            cell.labelPrice.text = MoneyUtil.getScaledText(item["price"] as! Int64, decimals: priceAssetDecimal, scale: 8 + priceAssetDecimal - amountAssetDecimal)
            cell.labelBuy.text = MoneyUtil.getScaledTextTrimZeros(item["amount"] as! Int64, decimals: amountAssetDecimal)
            
            cell.labelSell.text = ""
            cell.labelSell.backgroundColor = UIColor.clear
            
            if indexPath.row % 2 == 0 {
                cell.labelBuy.backgroundColor = UIColor(netHex: 0x58a763)
            }
            else {
                cell.labelBuy.backgroundColor = UIColor(netHex: 0x77bf82)
            }
        }
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
