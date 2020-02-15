//
//  WalletStakingBalanceCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 05.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions

private enum Constants {
    static let height: CGFloat = 286
    static let progressBarPadding: CGFloat = 32
    static let progressBarMinMediumPercent: CGFloat = 3.5
    static let progressBarMinSmallPercent: CGFloat = 2
}

final class StakingBalanceCell: UITableViewCell, NibReusable {

    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var labelTotalBalance: UILabel!
    @IBOutlet private weak var labelTotalBalanceTitle: UILabel!
    @IBOutlet private weak var leasedWidth: NSLayoutConstraint!
    @IBOutlet private weak var labelStaking: UILabel!
    @IBOutlet private weak var labelStakingTitle: UILabel!
    @IBOutlet private weak var labelAvailableTitle: UILabel!
    @IBOutlet private weak var labelAvailable: UILabel!
    @IBOutlet private weak var labelWithdraw: UILabel!
    @IBOutlet private weak var labelDeposit: UILabel!
    @IBOutlet private weak var labelTrade: UILabel!
    @IBOutlet private weak var labelBuy: UILabel!
    
    private var stakingPercent: CGFloat = 0

    var withdrawAction:(() -> Void)?
    var depositAction:(() -> Void)?
    var tradeAction:(() -> Void)?
    var buyAction:(() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
    }
    
    override func updateConstraints() {

        let viewWidth = frame.width - Constants.progressBarPadding * 2
        leasedWidth.constant = stakingPercent * viewWidth / 100

        super.updateConstraints()
    }
    
    @IBAction private func depositTapped(_ sender: Any) {
        depositAction?()
    }
    
    @IBAction private func withdrawTapped(_ sender: Any) {
        withdrawAction?()
    }
    
    @IBAction private func tradeTapped(_ sender: Any) {
        tradeAction?()
    }
    
    @IBAction private func buyTapped(_ sender: Any) {
        buyAction?()
    }
    
    private func setupLocalization() {
        labelTotalBalanceTitle.text = Localizable.Waves.Wallet.Stakingbalance.Label.totalBalance
        labelAvailableTitle.text = Localizable.Waves.Wallet.Stakingbalance.Label.available
        labelStakingTitle.text = Localizable.Waves.Wallet.Stakingbalance.Label.staking
        labelWithdraw.text = Localizable.Waves.Wallet.Stakingbalance.Button.withdraw
        labelDeposit.text = Localizable.Waves.Wallet.Stakingbalance.Button.deposit
        labelTrade.text = Localizable.Waves.Wallet.Stakingbalance.Button.trade
        labelBuy.text = Localizable.Waves.Wallet.Stakingbalance.Button.buy
    }
}

extension StakingBalanceCell: ViewConfiguration {
    
    func update(with model: WalletTypes.DTO.Staking.Balance) {
        
        setupLocalization()
        
        labelAvailable.attributedText = .styleForBalance(text: model.available.displayText,
                                                         font: labelAvailable.font)

        labelStaking.attributedText = .styleForBalance(text: model.inStaking.displayText,
                                                       font: labelStaking.font)

        labelTotalBalance.attributedText = .styleForBalance(text: model.total.displayText,
                                                            font: labelTotalBalance.font)
        
        stakingPercent = CGFloat(model.inStaking.amount) / CGFloat(model.available.amount) * 100

        if stakingPercent < Constants.progressBarMinSmallPercent {
            stakingPercent = Constants.progressBarMinSmallPercent
        }

        if stakingPercent.isNaN {
            stakingPercent = 0
        }

        stakingPercent = min(stakingPercent, 100)

        setNeedsUpdateConstraints()

    }
}

extension StakingBalanceCell: ViewHeight {
    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}
