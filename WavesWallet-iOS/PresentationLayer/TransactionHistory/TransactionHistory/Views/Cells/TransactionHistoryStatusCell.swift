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
    static let okBackgroundColor = UIColor(red: 74 / 255, green: 173 / 255, blue: 2 / 255, alpha: 0.1)
    static let warningBackgroundColor = UIColor(red: 248 / 255, green: 183 / 255, blue: 0 / 255, alpha: 0.1)
}

final class TransactionHistoryStatusCell: UITableViewCell, NibReusable {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var statusContainer: UIView!
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
        
        switch model.status {
        case .unconfirmed:
            statusContainer.backgroundColor = Constants.warningBackgroundColor
            statusLabel.textColor = UIColor.warning600
        case .activeNow:
            fallthrough
        case .completed:
            statusContainer.backgroundColor = Constants.okBackgroundColor
            statusLabel.textColor = UIColor.success500
        }
        
    }
}
