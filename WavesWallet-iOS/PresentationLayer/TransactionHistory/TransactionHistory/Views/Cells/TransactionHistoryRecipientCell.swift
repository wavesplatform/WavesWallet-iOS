//
//  TransactionHistoryRecipientCell.swift
//  WavesWallet-iOS
//
//  Created by Mac on 31/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class TransactionHistoryRecipientCell: UITableViewCell, NibReusable {
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var keyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    class func cellHeight() -> CGFloat {
        return 70.5
    }
}

extension TransactionHistoryRecipientCell: ViewConfiguration {
    func update(with model: TransactionHistoryTypes.ViewModel.Recipient) {
        titleLabel.text = "Sent to"
        valueLabel.text = model.name
        keyLabel.text = model.address
    }
}
