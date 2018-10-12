//
//  WalletBalanceHistoryCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/30/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class WalletHistoryCell: UITableViewCell, NibReusable {

    typealias Model = Void

    @IBOutlet var viewContainer: UIView!
    @IBOutlet var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
        setupLocalization()
    }

    class func cellHeight() -> CGFloat {
        return 56
    }
}

// MARK: ViewConfiguration
extension WalletHistoryCell: ViewConfiguration {
    func update(with model: Void) {
        titleLabel.text = Localizable.Wallet.Label.viewHistory
    }
}

// MARK: Localization
extension WalletHistoryCell: Localization {
    func setupLocalization() {
        titleLabel.text = Localizable.Wallet.Label.viewHistory
    }
}
