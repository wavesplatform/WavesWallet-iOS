//
//  TransactionCardStatusCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 11/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

private enum Constants {
    static let okBackgroundColor = UIColor(red: 74 / 255, green: 173 / 255, blue: 2 / 255, alpha: 0.1)
    static let warningBackgroundColor = UIColor(red: 248 / 255, green: 183 / 255, blue: 0 / 255, alpha: 0.1)
    static let cornerRadius: Float = 2
}

final class TransactionCardStatusCell: UITableViewCell, Reusable {

    enum Model {
        case activeNow
        case unconfirmed
        case completed
    }

    @IBOutlet private var keyLabel: UILabel!
    @IBOutlet private var valueLabel: UILabel!
    @IBOutlet private var statusContainer: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        statusContainer.cornerRadius = Constants.cornerRadius

        //TODO: Remove
        update(with: .activeNow)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset = .init(top: 0, left: self.bounds.width, bottom: 0, right: 0)
    }
}

// TODO: ViewConfiguration

extension TransactionCardStatusCell: ViewConfiguration {

    func update(with model: TransactionCardStatusCell.Model) {

        keyLabel.text = Localizable.Waves.Transactionhistory.Cell.Status.timestamp

        switch model {
        case .unconfirmed:
            valueLabel.text = Localizable.Waves.Transactionhistory.Cell.Status.Button.unconfirmed.uppercased()
            statusContainer.backgroundColor = Constants.warningBackgroundColor
            valueLabel.textColor = .warning600

        case .activeNow:
            valueLabel.text = Localizable.Waves.Transactionhistory.Cell.Status.Button.activeNow.uppercased()
            statusContainer.backgroundColor = Constants.okBackgroundColor
            valueLabel.textColor = .success500

        case .completed:
            valueLabel.text = Localizable.Waves.Transactionhistory.Cell.Status.Button.completed.uppercased()
            statusContainer.backgroundColor = Constants.okBackgroundColor
            valueLabel.textColor = .success500
        }
    }
}

