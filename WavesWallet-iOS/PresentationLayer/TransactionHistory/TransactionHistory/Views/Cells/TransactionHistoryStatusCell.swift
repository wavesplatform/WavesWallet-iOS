//
//  TransactionHistoryStatusCell.swift
//  WavesWallet-iOS
//
//  Created by Mac on 31/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//


import UIKit

private enum Constants {
    static let timestampDateFormat = "dd.MM.yyyy '" + Localizable.TransactionHistory.Cell.Status.at + "' hh:mm"
    static let okBackgroundColor = UIColor(red: 74 / 255, green: 173 / 255, blue: 2 / 255, alpha: 0.1)
    static let warningBackgroundColor = UIColor(red: 248 / 255, green: 183 / 255, blue: 0 / 255, alpha: 0.1)
    
    static let activeNow = Localizable.TransactionHistory.Cell.Status.Button.activeNow
    static let completed = Localizable.TransactionHistory.Cell.Status.Button.completed
    static let unconfirmed = Localizable.TransactionHistory.Cell.Status.Button.unconfirmed
}

final class TransactionHistoryStatusCell: UITableViewCell, NibReusable {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var statusContainer: UIView!

    class func cellHeight() -> CGFloat {
        return 62
    }
}

extension TransactionHistoryStatusCell: ViewConfiguration {
    func update(with model: TransactionHistoryTypes.ViewModel.Status) {
        
        titleLabel.text = Localizable.TransactionHistory.Cell.Status.timestamp
        
        // timestamp
        let formatter = DateFormatter.sharedFormatter
        formatter.dateFormat = Constants.timestampDateFormat
        valueLabel.text = formatter.string(from: model.timestamp)
        
        // status
        var status: String = ""
        
        switch model.status {
        case .unconfirmed:
            status = Constants.unconfirmed
            statusContainer.backgroundColor = Constants.warningBackgroundColor
            statusLabel.textColor = UIColor.warning600
            
        case .activeNow:
            status = Constants.activeNow
            statusContainer.backgroundColor = Constants.okBackgroundColor
            statusLabel.textColor = UIColor.success500
            
        case .completed:
            status = Constants.completed
            statusContainer.backgroundColor = Constants.okBackgroundColor
            statusLabel.textColor = UIColor.success500
            
        }
        
        statusLabel.text = status.uppercased()
        
    }
}
