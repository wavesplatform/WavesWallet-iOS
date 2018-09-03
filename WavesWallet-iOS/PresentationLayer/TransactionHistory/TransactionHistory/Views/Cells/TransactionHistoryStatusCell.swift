//
//  TransactionHistoryStatusCell.swift
//  WavesWallet-iOS
//
//  Created by Mac on 31/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//


import UIKit

final class TransactionHistoryStatusCell: UITableViewCell, NibReusable {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    class func cellHeight() -> CGFloat {
        return 64
    }
}

extension TransactionHistoryStatusCell: ViewConfiguration {
    func update(with model: TransactionHistoryTypes.ViewModel.Status) {
        
        titleLabel.text = "Timestamp"
        valueLabel.text = model.timestamp
        
        statusLabel.text = model.status.rawValue
        
    }
}
