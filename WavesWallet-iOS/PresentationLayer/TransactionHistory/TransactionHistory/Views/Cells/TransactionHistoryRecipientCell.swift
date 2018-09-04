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
    
    @IBOutlet weak var nameToKeyConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    class func cellHeight(width: CGFloat, model: TransactionHistoryTypes.ViewModel.Recipient) -> CGFloat {
        let titleHeight = "Sent to".maxHeight(font: UIFont.systemFont(ofSize: 13), forWidth: width)
        
        let nameToAddressY: CGFloat = (model.name != nil) ? 2 : 0
        
        let nameHeight = model.name?.maxHeight(font: UIFont.systemFont(ofSize: 13), forWidth: width) ?? 0
        let addressHeight = model.address.maxHeight(font: UIFont.systemFont(ofSize: 10), forWidth: width)
        
        return 14 + titleHeight + 6 + nameHeight + nameToAddressY + addressHeight + 14
    }
}

extension TransactionHistoryRecipientCell: ViewConfiguration {
    func update(with model: TransactionHistoryTypes.ViewModel.Recipient) {
        titleLabel.text = "Sent to"
        valueLabel.text = model.name
        keyLabel.text = model.address
        
        nameToKeyConstraint.constant = model.name != nil ? 2 : 0
        
        setNeedsUpdateConstraints()
    }
}
