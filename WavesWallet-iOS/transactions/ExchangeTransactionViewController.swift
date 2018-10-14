//
//  TransferTransactionViewController.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 25/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class ExchangeTransactionViewController: BaseTransactionDetailViewController {
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalNameLabel: UILabel!
    @IBOutlet weak var priceAssetNameLabel: UILabel!

    @IBOutlet weak var amountAssetLabel: UILabel!
    @IBOutlet weak var amountAssetNameLabel: UILabel!
    
    @IBOutlet weak var priceAssetLabel: UILabel!
    @IBOutlet weak var priceAssetNameLabel1: UILabel!
    
    var priceAsset: IssueTransaction!
    override func setupFields() {
        super.setupFields()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44

        
        directionLabel.text = self.basicTx.isInput ? "Buy" : "Sell"
        
        if let etx = tx as? ExchangeTransaction {
            let amountAssetDecimals = Int(basicTx.asset?.decimals ?? 8)
            amountAssetLabel.text = basicTx.assetId
            amountAssetLabel.isHidden = basicTx.assetId.isEmpty
            amountAssetNameLabel.text = basicTx.asset?.name ?? "WAVES"
            
            let realm = try! Realm()
            priceAsset = realm.object(ofType: IssueTransaction.self, forPrimaryKey: etx.priceAsset)
            
            priceAssetNameLabel.text = priceAsset?.name ?? "WAVES"
            priceAssetNameLabel1.text = priceAsset?.name ?? "WAVES"
            priceAssetLabel.text = priceAsset?.getAssetId()
            priceAssetLabel.isHidden = priceAsset?.getAssetId().isEmpty ?? true
            
            let priceAssetDecimals = Int(priceAsset?.decimals ?? 8)
            //totalNameLabel.text = self.basicTx.isInput ? "spent" : "received"
            
            priceLabel.text = MoneyUtil.getScaledText(etx.price, decimals: priceAssetDecimals, scale: 8 + priceAssetDecimals - amountAssetDecimals)
            
            let total = MoneyUtil.getScaledDecimal(etx.amount, amountAssetDecimals) * MoneyUtil.getScaledDecimal(etx.price, 8 + priceAssetDecimals - amountAssetDecimals)
            totalLabel.text = MoneyUtil.formatDecimals(total, decimals: priceAssetDecimals)            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 72
        } else if indexPath.row == 2{
            return basicTx.assetId.isEmpty ? 44.0 : 72.0
        } else if indexPath.row == 3 {
            return (priceAsset?.getAssetId().isEmpty ?? true) ? 44.0 : 72.0
        } else {
            return 44.0
        }
    }
    
}
