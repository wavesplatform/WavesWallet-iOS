//
//  WalletBalanceHistoryCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/30/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class WalletHistoryCell: UITableViewCell, NibReusable {
    @IBOutlet var viewContainer: UIView!
    @IBOutlet var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = Localizable.Wallet.Label.viewHistory
        viewContainer.addTableCellShadowStyle()
    }

    class func cellHeight() -> CGFloat {
        return 56
    }
}
