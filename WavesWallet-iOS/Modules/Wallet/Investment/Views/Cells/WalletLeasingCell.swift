//
//  WalletLeasingCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/29/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import UIKit
import UITools

final class WalletLeasingCell: UITableViewCell, NibReusable {
    @IBOutlet private var labelTitle: UILabel!
    @IBOutlet private var labelMoney: UILabel!
    @IBOutlet private var viewContainer: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
    }

    class func cellHeight() -> CGFloat {
        76
    }
}

// MARK: ViewConfiguration

extension WalletLeasingCell: ViewConfiguration {
    func update(with model: SmartTransaction) {
        labelTitle.text = Localizable.Waves.Wallet.Label.startedLeasing

        if case let .startedLeasing(lease) = model.kind {
            labelMoney.attributedText = .styleForBalance(text: lease.balance.money.displayText,
                                                         font: labelMoney.font)
        }
    }
}
