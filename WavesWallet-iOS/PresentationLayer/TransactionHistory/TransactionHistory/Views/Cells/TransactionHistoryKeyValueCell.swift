//
//  TransactionHistoryKeyValueCell.swift
//  WavesWallet-iOS
//
//  Created by Mac on 31/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class TransactionHistoryKeyValueCell: UITableViewCell, NibReusable {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = .brown
    }
    
    
    class func cellHeight() -> CGFloat {
        return 76
    }
}

extension TransactionHistoryKeyValueCell: ViewConfiguration {
    func update(with model: TransactionHistoryTypes.ViewModel.KeyValue) {
        
    }
}
