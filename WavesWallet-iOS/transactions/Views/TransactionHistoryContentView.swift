//
//  TransactionContentView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/23/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class TransactionHistoryContentView: UIView {

    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var labelValue: UILabel!
    
    @IBOutlet weak var bottomHeight: NSLayoutConstraint!
    @IBOutlet weak var addressHeight: NSLayoutConstraint!
    @IBOutlet weak var addressContainer: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if Platform.isIphoneX {
            bottomHeight.constant = 85
        }
    }
  
    func setup(_ item: NSDictionary) {
        var value = ""
        if let val = item["value"] as? Double {
            value = String(val)
        }
        else if let val = item["value"] as? Int {
            value = String(val)
        }
        
        let state = HistoryTransactionState(rawValue: item["state"] as! Int)!
        
        imageViewIcon.image = UIImage(named: HistoryTransactionImages[state.rawValue])
        labelValue.attributedText = DataManager.attributedBalanceText(text: value, font: labelValue.font)
        
        for view in addressContainer.subviews {
            view.removeFromSuperview()
        }
        
        if state == .massSend {
            let countAddresses = item["countAddresses"] as! Int
            
            var offset : CGFloat = 0
            for i in 0..<countAddresses {
                
                if i == 0 {
                    let view = TransactionHistoryAddressNameView.loadView() as! TransactionHistoryAddressNameView
                    view.frame.origin.y = offset
                    if i == countAddresses - 1 {
                        view.setupInfo(item)
                    }
                    addressContainer.addSubview(view)
                    offset += view.frame.size.height
                }
                else {
                    let view = TransactionMassSendView.loadView() as! TransactionMassSendView
                    view.frame.origin.y = offset
                    if i == countAddresses - 1 {
                        view.setupInfo(item)
                    }
                    addressContainer.addSubview(view)
                    offset += view.frame.size.height
                }
            }
            addressHeight.constant = offset
        }
        else {
            
            if state == .selfTranserred {
                
            }
            else if state == .tokenGeneration || state == .tokenReissue || state == .tokenBurning || state == .createdAlias {
                let view = TransactionHistoryAccountIDView.loadView() as! TransactionHistoryAccountIDView
                view.setupInfo(item)
                addressContainer.addSubview(view)
                addressHeight.constant = view.frame.size.height
            }
            else {
                if item["hasAddedAddress"] as? Bool == true {
                    let view = TransactionHistoryAddressNameView.loadView() as! TransactionHistoryAddressNameView
                    view.setupInfo(item)
                    addressContainer.addSubview(view)
                    addressHeight.constant = view.frame.size.height
                }
                else {
                    let view = TransactionHistoryAddressView.loadView() as! TransactionHistoryAddressView
                    view.setupInfo(item)
                    addressContainer.addSubview(view)
                    addressHeight.constant = view.frame.size.height
                }
            }
        }
    }
}
