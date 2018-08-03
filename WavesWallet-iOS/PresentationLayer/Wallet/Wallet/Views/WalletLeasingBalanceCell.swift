//
//  WalletLeasingTopCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let statusBarPadding: CGFloat = 32
    static let statusBarMinMediumPercent: CGFloat = 3.5
    static let statusBarMinSmallPercent: CGFloat = 2
}

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

    private var leasedPercent: CGFloat = 0
    private var leasedInPercent: CGFloat = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
    }

    override func updateConstraints() {

        let viewWidth = frame.width - Constants.statusBarPadding * 2
        leasedWidth.constant = leasedPercent * viewWidth / 100
        leasedInWidth.constant =  leasedInPercent * viewWidth / 100

        super.updateConstraints()
    }

    class func cellHeight() -> CGFloat {
        return 326
    }
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

        leasedPercent = CGFloat(model.leasedMoney.amount) / CGFloat(model.avaliableMoney.amount) * 100
        leasedInPercent = CGFloat(model.leasedInMoney.amount + model.leasedMoney.amount) / CGFloat(model.avaliableMoney.amount) * 100

        if leasedPercent < Constants.statusBarMinSmallPercent {
            leasedPercent = leasedPercent > leasedInPercent ? Constants.statusBarMinMediumPercent : Constants.statusBarMinSmallPercent
        }

        if leasedInPercent < Constants.statusBarMinSmallPercent {
            let offSet = leasedPercent > leasedInPercent ? Constants.statusBarMinMediumPercent : Constants.statusBarMinSmallPercent
            leasedInPercent = leasedPercent + offSet
        }

        leasedPercent = min(leasedPercent, 100)
        leasedInPercent = min(leasedInPercent, 100)

        setNeedsUpdateConstraints()
    }
}
