//
//  WalletStakingBalanceCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 05.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions
import DeviceKit

private enum Constants {    
    static let progressBarPadding: CGFloat = 32
    static let progressBarMinMediumPercent: CGFloat = 3.5
    static let progressBarMinSmallPercent: CGFloat = 2
}

final class StakingBalanceCell: UITableViewCell, NibReusable {

    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var labelTotalBalanceTitle: UILabel!
    @IBOutlet private weak var totalBalanceLabel: BalanceLabel!
    
    @IBOutlet private weak var leasedWidth: NSLayoutConstraint!
    @IBOutlet private weak var labelStaking: UILabel!
    @IBOutlet private weak var labelStakingTitle: UILabel!
    @IBOutlet private weak var labelAvailableTitle: UILabel!
    @IBOutlet private weak var labelAvailable: UILabel!
    
    @IBOutlet private weak var withdrawButton: UIButton!
    @IBOutlet private weak var depositButton: UIButton!
    @IBOutlet private weak var tradeButton: UIButton!
    @IBOutlet private weak var buyButton: UIButton!
    
    private var stakingPercent: CGFloat = 0

    var withdrawAction:(() -> Void)?
    var depositAction:(() -> Void)?
    var tradeAction:(() -> Void)?
    var buyAction:(() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
        
        if Platform.isSmallDevices {
            buyButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            depositButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            withdrawButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            tradeButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        }
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
}

// MARK: Localization

extension StakingBalanceCell: Localization {
    
    func setupLocalization() {
        labelTotalBalanceTitle.text = Localizable.Waves.Wallet.Stakingbalance.Label.totalBalance
        labelAvailableTitle.text = Localizable.Waves.Wallet.Stakingbalance.Label.available
        labelStakingTitle.text = Localizable.Waves.Wallet.Stakingbalance.Label.staking
        
        buyButton.setTitle(Localizable.Waves.Wallet.Stakingbalance.Button.buy,
                           for: .normal)
        
        withdrawButton.setTitle(Localizable.Waves.Wallet.Stakingbalance.Button.withdraw,
                                for: .normal)
        
        depositButton.setTitle(Localizable.Waves.Wallet.Stakingbalance.Button.deposit,
                               for: .normal)
        
        tradeButton.setTitle(Localizable.Waves.Wallet.Stakingbalance.Button.trade,
                            for: .normal)
    }
}

// MARK: ViewConfiguration

extension StakingBalanceCell: ViewConfiguration {
    
    func update(with model: WalletTypes.DTO.Staking.Balance) {
        
        setupLocalization()
        
        let inStakingBalance = model.inStaking.money
        let availableBalance = model.available.money
                        
        labelAvailable.attributedText = .styleForBalance(text: model.available.displayText,
                                                         font: labelAvailable.font)

        labelStaking.attributedText = .styleForBalance(text: model.inStaking.displayText,
                                                       font: labelStaking.font)
            
        totalBalanceLabel.update(with: .init(balance: model.total,
                                             sign: nil,
                                             style: .large))
        
        stakingPercent = CGFloat(inStakingBalance.amount) / CGFloat(availableBalance.amount) * 100

        if stakingPercent.isNaN {
            stakingPercent = 0
        }
        
        if stakingPercent < Constants.progressBarMinSmallPercent {
            stakingPercent = Constants.progressBarMinSmallPercent
        }
    
        stakingPercent = min(stakingPercent, 100)

        setNeedsUpdateConstraints()
    }
}
