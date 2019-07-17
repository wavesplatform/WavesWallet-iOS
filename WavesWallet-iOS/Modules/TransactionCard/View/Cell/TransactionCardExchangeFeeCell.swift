//
//  TransactionCardExchangeFeeCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 15.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

final class TransactionCardExchangeFeeCell: UITableViewCell, Reusable {

    @IBOutlet private weak var labelFee: UILabel!
    @IBOutlet private weak var fee1: BalanceLabel!
    @IBOutlet private weak var fee2: BalanceLabel!
    
    struct Model {
        let fee1: BalanceLabel.Model
        let fee2: BalanceLabel.Model?
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        labelFee.text = Localizable.Waves.Transactioncard.Title.fee
    }
}

extension TransactionCardExchangeFeeCell: ViewConfiguration {
    
    func update(with model: TransactionCardExchangeFeeCell.Model) {
        fee1.update(with: model.fee1)
        
        if let fee = model.fee2 {
            fee2.update(with: fee)
            fee2.isHidden = false
        }
        else {
            fee2.isHidden = true
        }
    }
}
