//
//  WalletLeasingTopCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

fileprivate enum Constants {
    static let statusBarPadding: CGFloat = 32
    static let statusBarMinMediumPercent: CGFloat = 3.5
    static let statusBarMinSmallPercent: CGFloat = 2
    static let height: CGFloat = 290
    static let blockLeasedTotalBalanceHeight: CGFloat = 90
}

protocol WalletLeasingBalanceCellDelegate: AnyObject {

    func walletLeasingBalanceCellDidTapStartLease(availableMoney: Money)
}

final class WalletLeasingBalanceCell: UITableViewCell, Reusable {
    
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
    
    weak var delegate: WalletLeasingBalanceCellDelegate?
    
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

extension WalletLeasingBalanceCell: Localization {
    func setupLocalization() {
        avaliableTitleLabel.text = Localizable.Waves.Wallet.Label.available
        leasedTitleLabel.text = Localizable.Waves.Wallet.Label.leased
        totalBalanceTitleLabel.text = Localizable.Waves.Wallet.Label.totalBalance
        buttonStartLease.setTitle(Localizable.Waves.Wallet.Button.startLease, for: .normal)
    }
}

// MARK: ViewConfiguration

extension WalletLeasingBalanceCell: ViewConfiguration {
    func update(with model: WalletTypes.DTO.Leasing.Balance) {

        setupLocalization()
        availableMoney = model.avaliableMoney
        
        labelAvaliableBalance.attributedText = .styleForBalance(text: model.avaliableMoney.displayText,
                                                       font: labelAvaliableBalance.font)

        leasedBalanceLabel.attributedText = .styleForBalance(text: model.leasedMoney.displayText,
                                                                font: leasedBalanceLabel.font)

        labelTotalBalance.attributedText = .styleForBalance(text: model.totalMoney.displayText,
                                                             font: labelTotalBalance.font)

        leasedPercent = CGFloat(model.leasedMoney.amount) / CGFloat(model.avaliableMoney.amount) * 100

        if model.avaliableMoney.isZero && model.leasedMoney.isZero && model.totalMoney.isZero {
            viewContainerLeasedTotalBalance.isHidden = true
        }
        else {
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

extension WalletLeasingBalanceCell: ViewCalculateHeight {
    
    static func viewHeight(model: WalletTypes.DTO.Leasing.Balance, width: CGFloat) -> CGFloat {
        
        if model.avaliableMoney.isZero && model.leasedMoney.isZero && model.totalMoney.isZero {
            return Constants.height - Constants.blockLeasedTotalBalanceHeight
        }
       
        return Constants.height
    }
}
