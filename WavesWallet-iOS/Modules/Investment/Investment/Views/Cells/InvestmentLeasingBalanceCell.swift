//
//  WalletLeasingTopCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/29/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Extensions
import UIKit
import UITools

fileprivate enum Constants {
    static let statusBarPadding: CGFloat = 32
    static let statusBarMinMediumPercent: CGFloat = 3.5
    static let statusBarMinSmallPercent: CGFloat = 2
    static let height: CGFloat = 290
    static let blockLeasedTotalBalanceHeight: CGFloat = 90
}

protocol InvestmentLeasingBalanceCellDelegate: AnyObject {
    func walletLeasingBalanceCellDidTapStartLease(availableMoney: Money)
}

final class InvestmentLeasingBalanceCell: UITableViewCell, NibReusable {
    @IBOutlet private weak var viewContainer: UIView!

    @IBOutlet private weak var avaliableTitleLabel: UILabel!
    @IBOutlet private weak var leasedTitleLabel: UILabel!
    @IBOutlet private weak var totalBalanceTitleLabel: UILabel!

    @IBOutlet private weak var labelAvaliableBalance: UILabel!
    @IBOutlet private weak var leasedBalanceLabel: UILabel!
    @IBOutlet private weak var labelTotalBalance: UILabel!

    @IBOutlet private weak var buttonStartLease: UIButton!
    @IBOutlet private weak var leasedWidth: NSLayoutConstraint!

    @IBOutlet private weak var viewContainerLeasedTotalBalance: UIView!

    private var leasedPercent: CGFloat = 0
    private var availableMoney: Money!

    weak var delegate: InvestmentLeasingBalanceCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
        setupLocalization()
        buttonStartLease.addTarget(self, action: #selector(startLease), for: .touchUpInside)
    }

    override func updateConstraints() {
        let viewWidth = frame.width - Constants.statusBarPadding * 2
        leasedWidth.constant = leasedPercent * viewWidth / 100

        super.updateConstraints()
    }

    @objc func startLease() {
        delegate?.walletLeasingBalanceCellDidTapStartLease(availableMoney: availableMoney)
    }
}

// MARK: Localization

extension InvestmentLeasingBalanceCell: Localization {
    func setupLocalization() {
        avaliableTitleLabel.text = Localizable.Waves.Wallet.Label.available
        leasedTitleLabel.text = Localizable.Waves.Wallet.Label.leased
        totalBalanceTitleLabel.text = Localizable.Waves.Wallet.Label.totalBalance
        buttonStartLease.setTitle(Localizable.Waves.Wallet.Button.startLease, for: .normal)
    }
}

// MARK: ViewConfiguration

extension InvestmentLeasingBalanceCell: ViewConfiguration {
    func update(with model: InvestmentLeasingVM.Balance) {
        setupLocalization()
        availableMoney = model.avaliableMoney

        labelAvaliableBalance.attributedText = .styleForBalance(text: model.avaliableMoney.displayText,
                                                                font: labelAvaliableBalance.font)

        leasedBalanceLabel.attributedText = .styleForBalance(text: model.leasedMoney.displayText,
                                                             font: leasedBalanceLabel.font)

        labelTotalBalance.attributedText = .styleForBalance(text: model.totalMoney.displayText,
                                                            font: labelTotalBalance.font)

        leasedPercent = CGFloat(model.leasedMoney.amount) / CGFloat(model.avaliableMoney.amount) * 100

        if model.avaliableMoney.isZero, model.leasedMoney.isZero, model.totalMoney.isZero {
            viewContainerLeasedTotalBalance.isHidden = true
        } else {
            viewContainerLeasedTotalBalance.isHidden = false
        }

        if leasedPercent < Constants.statusBarMinSmallPercent {
            leasedPercent = Constants.statusBarMinSmallPercent
        }

        if leasedPercent.isNaN {
            leasedPercent = 0
        }

        leasedPercent = min(leasedPercent, 100)

        setNeedsUpdateConstraints()
    }
}

extension InvestmentLeasingBalanceCell: ViewCalculateHeight {
    static func viewHeight(model: InvestmentLeasingVM.Balance, width _: CGFloat) -> CGFloat {
        if model.avaliableMoney.isZero, model.leasedMoney.isZero, model.totalMoney.isZero {
            return Constants.height - Constants.blockLeasedTotalBalanceHeight
        }

        return Constants.height
    }
}
