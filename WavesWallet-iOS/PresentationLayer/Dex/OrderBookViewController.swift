//
//  OrderBookViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 05.07.17.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit
import Alamofire


class OrderCell: UITableViewCell {
    
    @IBOutlet weak var labelBuy: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var labelSell: UILabel!

    
}

class OrderBookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CreateOrderViewControllerDelegate {

    var priceAsset : String!
    var amountAsset : String!
    var assetPair : AssetPair!
    var priceAssetDecimal: Int!
    var amountAssetDecimal: Int!
    var priceAssetName : String!
    var amountAssetName : String!

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var bids = [NSDictionary]()
    var asks = [NSDictionary]()
    
    var timer: Timer! = nil

    var orderRequest : DataRequest? = nil
    
    var hasFirstRequest = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        assetPair = AssetPair(amountAsset: amountAsset, priceAsset: priceAsset)
        
        NotificationCenter.default.addObserver(self, selector: #selector(controllerWillAppear), name: Notification.Name(rawValue: kNotifDidCreateOrder), object: nil)

        loadInfo {
            self.activityIndicator.stopAnimating()
            
            if self.asks.count > 0 && self.bids.count > 0 {
                self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 1), at: .middle, animated: false)
            }
            
            self.hasFirstRequest = true
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func clearTimer() {

        if timer != nil {
            timer.invalidate()
            timer = nil
        }

        orderRequest?.cancel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        clearTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {

        if hasFirstRequest {
            controllerWillAppear()
        }
    }
    
    @objc func controllerWillAppear() {
        //called when top tabs changed
        
        if timer == nil {
            loadInfo {
                
            }
        }
    }
    
    func controllerWillDissapear() {
        //called when top tabs changed

        clearTimer()
    }
    
    @objc func updateInfo() {
        loadInfo {
            
        }
    }

    func createOrderViewControllerDidCreateOrder() {
        
        if let parent = parent as? DexContainerViewController {
            parent.createOrderViewControllerDidCreateOrder()
        }
    }
    
    func loadInfo(complete: @escaping () -> Void)  {
        
        clearTimer()
        orderRequest = NetworkManager.getOrderBook(amountAsset: amountAsset, priceAsset: priceAsset) { (info, errorMessage) in
            
            if info != nil {
                
                self.bids.removeAll()
                self.asks.removeAll()
                
                if let _bids = info!["bids"] as? [NSDictionary] {
                    self.bids.append(contentsOf: _bids)
                    if let best = _bids[safe: 0] {
                        DataManager.shared.bestBid[self.assetPair.key] = (best["price"] as? Int64) ?? 0
                    }
                }
                
                if var _asks = info!["asks"] as? NSArray {
                    if let best = (_asks as! [NSDictionary])[safe: 0] {
                        DataManager.shared.bestAsk[self.assetPair.key] = (best["price"] as? Int64) ?? 0
                    }
                    _asks = _asks.sortedArray(using: [NSSortDescriptor.init(key: "price", ascending: false)]) as NSArray
                    self.asks.append(contentsOf: _asks as! [NSDictionary])
                }
                
                self.tableView.reloadData()
            }
            
            complete()
            self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateInfo), userInfo: nil, repeats: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
   
        let controller = storyboard?.instantiateViewController(withIdentifier: "CreateOrderViewController") as! CreateOrderViewController
        controller.delegate = self
        
        if indexPath.section == 0 {
            let item = asks[indexPath.row]
            controller.price = item["price"] as? Int64
            controller.amount = item["amount"] as? Int64
        }
        else {
            let item = bids[indexPath.row]
            controller.price = item["price"] as? Int64
            controller.amount = item["amount"] as? Int64
        }
        
        controller.priceAsset = priceAsset
        controller.amountAsset = amountAsset
        controller.priceAssetName = priceAssetName
        controller.amountAssetName = amountAssetName
        controller.priceAssetDecimal = priceAssetDecimal
        controller.amountAssetDecimal = amountAssetDecimal
        controller.orderType = indexPath.section == 0 ? .buy : .sell
        navigationController?.pushViewController(controller, animated: true)
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
                cell.labelSell.backgroundColor = AppColors.dexSellColor
            }
            else {
                cell.labelSell.backgroundColor = AppColors.dexLightSellColor
            }
        }
        else {
            
            let item = bids[indexPath.row]
            
            cell.labelPrice.text = MoneyUtil.getScaledText(item["price"] as! Int64, decimals: priceAssetDecimal, scale: 8 + priceAssetDecimal - amountAssetDecimal)
            cell.labelBuy.text = MoneyUtil.getScaledTextTrimZeros(item["amount"] as! Int64, decimals: amountAssetDecimal)
            
            cell.labelSell.text = ""
            cell.labelSell.backgroundColor = UIColor.clear
            
            if indexPath.row % 2 == 0 {
                cell.labelBuy.backgroundColor = AppColors.dexBuyColor
            }
            else {
                cell.labelBuy.backgroundColor = AppColors.dexLightBuyColor
            }
        }
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
