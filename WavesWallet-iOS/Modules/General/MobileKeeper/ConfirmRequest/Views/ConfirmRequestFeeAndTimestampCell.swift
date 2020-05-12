//
//  ConfirmRequestFeeAndTimestampCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 27.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Extensions
import Foundation
import UIKit
import UITools

private enum Constants {
    static let dateFormatterKey: String = "ConfirmRequestFeeAndTimestampCell.dateFormatterKey"
}

final class ConfirmRequestFeeAndTimestampCell: UITableViewCell, Reusable {
    struct Model {
        let date: Date
        let feeBalance: BalanceLabel.Model
    }

    @IBOutlet private var feeTitleLabel: UILabel!
    @IBOutlet private var balanceLabel: BalanceLabel!

    @IBOutlet private var timeTitleLabel: UILabel!
    @IBOutlet private var timeValueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
        selectionStyle = .none
    }
}

// MARK: ViewConfiguration

extension ConfirmRequestFeeAndTimestampCell: ViewConfiguration {
    func update(with model: Model) {
        let formatter = DateFormatter.uiSharedFormatter(key: Constants.dateFormatterKey)
        formatter.dateFormat = Localizable.Waves.Transactioncard.Timestamp.format
        let timestampValue = formatter.string(from: model.date)

        feeTitleLabel.text = Localizable.Waves.Transactioncard.Title.fee
        timeTitleLabel.text = Localizable.Waves.Keeper.Label.txTime
        timeValueLabel.text = timestampValue
        balanceLabel.update(with: model.feeBalance)
    }
}
