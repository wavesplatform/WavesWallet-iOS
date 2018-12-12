//
//  TransactionHistoryStatusCell.swift
//  WavesWallet-iOS
//
//  Created by Mac on 31/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//


import UIKit

private enum Constants {
    static let timestampDateFormatBegin = "dd.MM.yyyy '"
    static let timestampDateFormatEnd = "' hh:mm"
    static let okBackgroundColor = UIColor(red: 74 / 255, green: 173 / 255, blue: 2 / 255, alpha: 0.1)
    static let warningBackgroundColor = UIColor(red: 248 / 255, green: 183 / 255, blue: 0 / 255, alpha: 0.1)
    
}

final class TransactionHistoryStatusCell: UITableViewCell, NibReusable {
    
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var valueLabel: UILabel!
    @IBOutlet fileprivate weak var statusLabel: UILabel!
    
    @IBOutlet fileprivate weak var statusContainer: UIView!

    class func cellHeight() -> CGFloat {
        return 62
    }
}

extension TransactionHistoryStatusCell: ViewConfiguration {
    func update(with model: TransactionHistoryTypes.ViewModel.Status) {
        
        titleLabel.text = Localizable.Waves.Transactionhistory.Cell.Status.timestamp
        
        // timestamp
        let formatter = DateFormatter.sharedFormatter
        formatter.locale = Language.currentLocale
        formatter.dateFormat = Constants.timestampDateFormatBegin + Localizable.Waves.Transactionhistory.Cell.Status.at + Constants.timestampDateFormatEnd
        valueLabel.text = formatter.string(from: model.timestamp)
        
        // status
        var status: String = ""
        
        switch model.status {
        case .unconfirmed:
            status = Localizable.Waves.Transactionhistory.Cell.Status.Button.unconfirmed
            statusContainer.backgroundColor = Constants.warningBackgroundColor
            statusLabel.textColor = UIColor.warning600
            
        case .activeNow:
            status = Localizable.Waves.Transactionhistory.Cell.Status.Button.activeNow
            statusContainer.backgroundColor = Constants.okBackgroundColor
            statusLabel.textColor = UIColor.success500
            
        case .completed:
            status = Localizable.Waves.Transactionhistory.Cell.Status.Button.completed
            statusContainer.backgroundColor = Constants.okBackgroundColor
            statusLabel.textColor = UIColor.success500
            
        }
        
        statusLabel.text = status.uppercased()
        
    }
}
