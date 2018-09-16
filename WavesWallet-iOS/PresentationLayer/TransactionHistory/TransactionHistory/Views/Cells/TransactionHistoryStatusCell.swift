//
//  TransactionHistoryStatusCell.swift
//  WavesWallet-iOS
//
//  Created by Mac on 31/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//


import UIKit

private enum Constants {
    static let timestampDateFormat = "dd.MM.yyyy 'at' hh:mm"
}

final class TransactionHistoryStatusCell: UITableViewCell, NibReusable {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    class func cellHeight() -> CGFloat {
        return 62
    }
}

extension TransactionHistoryStatusCell: ViewConfiguration {
    func update(with model: TransactionHistoryTypes.ViewModel.Status) {
        
        titleLabel.text = "Timestamp"
        
        let formatter = DateFormatter.sharedFormatter
        formatter.dateFormat = Constants.timestampDateFormat
        valueLabel.text = formatter.string(from: model.timestamp)
        
        statusLabel.text = model.status.rawValue
        
    }
}
