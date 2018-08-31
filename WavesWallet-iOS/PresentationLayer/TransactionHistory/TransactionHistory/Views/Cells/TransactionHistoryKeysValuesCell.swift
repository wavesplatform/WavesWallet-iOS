//
//  TransactionHistoryKeysValue.swift
//  WavesWallet-iOS
//
//  Created by Mac on 31/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class TransactionHistoryKeysValuesCell: UITableViewCell, NibReusable {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = .green
    }
    
    class func cellHeight() -> CGFloat {
        return 76
    }
}

extension TransactionHistoryKeysValuesCell: ViewConfiguration {
    func update(with model: [TransactionHistoryTypes.ViewModel.KeyValue]) {
        
    }
}
