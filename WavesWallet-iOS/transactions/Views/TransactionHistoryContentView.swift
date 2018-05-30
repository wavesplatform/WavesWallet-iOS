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
    
    var massSentFullHeight: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if Platform.isIphoneX {
            bottomHeight.constant = 85
        }
    }
  
    func showAllAddresses() {
        
        let showAllView = addressContainer.subviews.first(where: {$0.isKind(of: TransactionHistoryShowAllView.classForCoder())})
        
        addressHeight.constant = massSentFullHeight
        UIView.animate(withDuration: 0.3, animations: {
            showAllView?.alpha = 0
            self.layoutIfNeeded()
        }) { (complete) in
            showAllView?.removeFromSuperview()
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
            massSentFullHeight = 0
            
            for i in 0..<countAddresses {
                
                if i == 0 {
                    let view = TransactionHistoryAddressView.loadView() as! TransactionHistoryAddressView
                    view.frame.origin.y = offset
                    view.setupInfo(item, showComment: false)
                    addressContainer.addSubview(view)
                    offset += view.frame.size.height
                    massSentFullHeight += view.frame.size.height
                }
                else {
                    let view = TransactionHistoryMassSendView.loadView() as! TransactionHistoryMassSendView
                    view.frame.origin.y = massSentFullHeight
                    view.setupInfo(item, showComment: i == countAddresses - 1)
                    addressContainer.addSubview(view)
                    if i < 3 {
                        offset += view.frame.size.height
                    }
                    massSentFullHeight += view.frame.size.height
                }
            }
            
            if countAddresses > 3 {
                let view = TransactionHistoryShowAllView.loadView() as! TransactionHistoryShowAllView
                view.buttonShow.addTarget(self, action: #selector(showAllAddresses), for: .touchUpInside)
                view.buttonShow.setTitle("Show all (\(countAddresses))", for: .normal)
                view.frame.origin.y = offset
                view.setupInfo(item)
                addressContainer.addSubview(view)
                offset += view.frame.size.height
            }
            addressHeight.constant = offset
        }
        else {
            
            let view = TransactionHistoryAddressView.loadView() as! TransactionHistoryAddressView
            view.setupInfo(item, showComment: true)
            addressContainer.addSubview(view)
            addressHeight.constant = view.frame.size.height
        }
    }
}
