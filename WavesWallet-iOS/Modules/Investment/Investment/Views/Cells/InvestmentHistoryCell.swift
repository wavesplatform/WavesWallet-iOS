//
//  WalletBalanceHistoryCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/30/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Extensions
import UIKit
import UITools

private enum Constants {
    static let height: CGFloat = 56
}

final class InvestmentHistoryCell: UITableViewCell, NibReusable {
    @IBOutlet private var viewContainer: UIView!
    @IBOutlet private var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
    }

    class func cellHeight() -> CGFloat {
        return Constants.height
    }
}

// MARK: ViewConfiguration

extension InvestmentHistoryCell: ViewConfiguration {
    func update(with model: InvestmentRow.HistoryCellType) {
        switch model {
        case .leasing:
            titleLabel.text = Localizable.Waves.Wallet.Label.viewHistory

        case .staking:
            titleLabel.text = Localizable.Waves.Wallet.Stakingpayouts.payoutsHistory
        }
    }
}
