//
//  WalletLeasingTopCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class WalletLeasingBalanceCell: UITableViewCell, Reusable {
    @IBOutlet var viewContainer: UIView!
    @IBOutlet var labelBalance: UILabel!
    @IBOutlet var labelAvaliableBalance: UILabel!
    @IBOutlet var leasedBalanceLabel: UILabel!
    @IBOutlet var leasedInBalanceLabel: UILabel!

    @IBOutlet var buttonStartLease: UIButton!
    @IBOutlet var leasedWidth: NSLayoutConstraint!
    @IBOutlet var leasedInWidth: NSLayoutConstraint!
    @IBOutlet var viewLeasedInHeight: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
    }

    class func cellHeight() -> CGFloat {
        return 326
    }

//    func setupCell(isAvailableLeasingHistory: Bool) {
//        let text = "000.0000000"
//        labelBalance.attributedText = NSAttributedString.styleForBalance(text: text, font: labelBalance.font)
//        let viewWidth = Platform.ScreenWidth - 32 - 32
//        let leasedPercent: CGFloat = 40
//        let leasedInPercent: CGFloat = 50
//        leasedWidth.constant = leasedPercent * viewWidth / 100
//        leasedInWidth.constant = isAvailableLeasingHistory ? leasedInPercent * viewWidth / 100 : 0
//        viewLeasedInHeight.constant = isAvailableLeasingHistory ? 40 : 0
//    }
}

extension WalletLeasingBalanceCell: ViewConfiguration {
    func update(with model: WalletTypes.DTO.Leasing.Balance) {
        labelBalance.attributedText = .styleForBalance(text: model.totalMoney.displayTextFull,
                                                       font: labelAvaliableBalance.font)
        labelAvaliableBalance.attributedText = .styleForBalance(text: model.avaliableMoney.displayTextFull,
                                                                font: labelAvaliableBalance.font)
        leasedInBalanceLabel.attributedText = .styleForBalance(text: model.leasedInMoney.displayTextFull,
                                                               font: leasedInBalanceLabel.font)
        leasedBalanceLabel.attributedText = .styleForBalance(text: model.leasedMoney.displayTextFull,
                                                             font: leasedBalanceLabel.font)
    }
}
