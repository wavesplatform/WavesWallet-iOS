//
//  WalletLeasingCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class WalletLeasingCell: UITableViewCell, NibReusable {
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelMoney: UILabel!
    @IBOutlet var viewContainer: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
    }

    class func cellHeight() -> CGFloat {
        return 76
    }
}

// MARK: ViewConfiguration

extension WalletLeasingCell: ViewConfiguration {
    func update(with model: DomainLayer.DTO.SmartTransaction) {
        labelTitle.text = Localizable.Wallet.Label.startedLeasing

        if case .startedLeasing(let lease) = model.kind {
            labelMoney.attributedText = .styleForBalance(text: lease.balance.money.displayTextFull,
                                                         font: labelMoney.font)
        }
    }
}
