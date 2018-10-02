//
//  TransactionHistoryKeyValueCell.swift
//  WavesWallet-iOS
//
//  Created by Mac on 31/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit


final class TransactionHistoryKeyValueCell: UITableViewCell, NibReusable {
    
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var separator: SeparatorView!
    @IBOutlet fileprivate weak var valueLabel: UILabel!
    
    class func cellHeight() -> CGFloat {
        return 62
    }
}

extension TransactionHistoryKeyValueCell: ViewConfiguration {
    func update(with model: TransactionHistoryTypes.ViewModel.KeyValue) {
        
        titleLabel.text = model.title
        valueLabel.text = model.value
        
    }
}
