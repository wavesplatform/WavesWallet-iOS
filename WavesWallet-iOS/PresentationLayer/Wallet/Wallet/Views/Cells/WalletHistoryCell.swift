//
//  WalletBalanceHistoryCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/30/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let height: CGFloat = 56
}

final class WalletHistoryCell: UITableViewCell, NibReusable {

    typealias Model = Void

    @IBOutlet private var viewContainer: UIView!
    @IBOutlet private var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
        setupLocalization()
    }

    class func cellHeight() -> CGFloat {
        return Constants.height
    }
}

// MARK: ViewConfiguration
extension WalletHistoryCell: ViewConfiguration {
    func update(with model: Void) {
        titleLabel.text = Localizable.Waves.Wallet.Label.viewHistory
    }
}

// MARK: Localization
extension WalletHistoryCell: Localization {
    func setupLocalization() {
        titleLabel.text = Localizable.Waves.Wallet.Label.viewHistory
    }
}
