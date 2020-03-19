//
//  WalletBalanceHistoryCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/30/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import Extensions

private enum Constants {
    static let height: CGFloat = 56
}

final class WalletHistoryCell: UITableViewCell, NibReusable {

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
extension WalletHistoryCell: ViewConfiguration {
 
    func update(with model: WalletTypes.ViewModel.Row.HistoryCellType) {
        
        switch model {
        case .leasing:
            titleLabel.text = Localizable.Waves.Wallet.Label.viewHistory

        case .staking:
            titleLabel.text = Localizable.Waves.Wallet.Stakingpayouts.payoutsHistory
        }
    }
}
