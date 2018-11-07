//
//  TransactionHistoryKeysValue.swift
//  WavesWallet-iOS
//
//  Created by Mac on 31/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class TransactionHistoryKeysValuesCell: UITableViewCell, NibReusable {
    
    @IBOutlet fileprivate weak var firstTitleLabel: UILabel!
    @IBOutlet fileprivate weak var firstValueLabel: UILabel!
    @IBOutlet fileprivate weak var secondTitleLabel: UILabel!
    @IBOutlet fileprivate weak var secondValueLabel: UILabel!
    
    class func cellHeight() -> CGFloat {
        return 62
    }
}

extension TransactionHistoryKeysValuesCell: ViewConfiguration {
    func update(with model: [TransactionHistoryTypes.ViewModel.KeyValue]) {
        
        if model.count > 0 {
            let firstModel = model[0]
            firstTitleLabel.text = firstModel.title
            firstValueLabel.text = firstModel.value
        }
        
        if model.count > 1 {
            let secondModel = model[1]
            secondTitleLabel.text = secondModel.title
            secondValueLabel.text = secondModel.value
        }
        
    }
}
