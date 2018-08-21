//
//  HistoryAssetCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/10/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class HistoryTransactionCell: UITableViewCell, Reusable {

    @IBOutlet var transactionView: HistoryTransactionView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
//        transactionView = HistoryTransactionView()
    }
    
    class func cellHeight() -> CGFloat {
        return 76
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        transactionView.frame = bounds
    }
    
}

