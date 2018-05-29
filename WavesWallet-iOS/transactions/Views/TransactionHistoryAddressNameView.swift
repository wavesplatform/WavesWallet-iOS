//
//  TransactionAddressNameView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/23/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class TransactionHistoryAddressNameView: TransactionHistoryBaseView {

    
    @IBOutlet weak var buttonEdit: UIButton!
    @IBOutlet weak var labelTitle: UILabel!
    
    override var viewHeight: CGFloat {
        return 75
    }
    
    override func setupInfo(_ item: NSDictionary) {
        super.setupInfo(item)
        
        let state = HistoryTransactionState(rawValue: item["state"] as! Int)!
        labelTitle.text = transactionTextState(state)
    }
}
