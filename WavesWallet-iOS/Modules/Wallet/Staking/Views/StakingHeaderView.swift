//
//  WalletStakingHeaderView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 05.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions

private enum Contants {
    static let height: CGFloat = 118
}

final class StakingHeaderView: UITableViewHeaderFooterView, NibReusable {

    @IBOutlet private weak var labelEstimatedInterest: UILabel!
    @IBOutlet private weak var labelPercentTitle: UILabel!
    @IBOutlet private weak var labelPercent: UILabel!
    
    @IBOutlet private weak var viewEstimetedInterest: GradientView!
    @IBOutlet private weak var viewProfit: GradientView!
        
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var buttonHowWorkds: UIButton!
    
    @IBOutlet weak var labelTotalProfit: UILabel!
    @IBOutlet weak var labelShare: UILabel!
    @IBOutlet weak var balanceLabel: BalanceLabel!
    
    var howWorksAction: (() -> Void)?
    var twAction: (() -> Void)?
    var fbAction: (() -> Void)?
    var vkAction: (() -> Void)?
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .basic50
        contentView.backgroundColor = .basic50
        
        viewProfit.setupShadow(options: .init(offset: CGSize(width: 0, height: 4),
                                              color: .black,
                                              opacity: 0.1,
                                              shadowRadius: 4,
                                              shouldRasterize: true))

        
        viewEstimetedInterest.colors = [.orangeYellow, .orangeYellowTwo, .pumpkinOrange]
        viewEstimetedInterest.direction = .custom(GradientView.Settings(startPoint: CGPoint(x: 0, y: 1),
                                                                        endPoint: CGPoint(x: 0, y: 0),
                                                                        locations: [0.0, 0.54]))
        viewProfit.startColor = .azureTwo
        viewProfit.endColor = .azure
        viewProfit.direction = .horizontal            
    }
    
    private func setupLocalization() {
        labelEstimatedInterest.text = Localizable.Waves.Wallet.Stakingheader.estimatedInterest
        labelPercentTitle.text = Localizable.Waves.Wallet.Stakingheader.perYear
        buttonHowWorkds.setTitle(Localizable.Waves.Wallet.Stakingheader.howItWorks, for: .normal)
        labelTotalProfit.text = Localizable.Waves.Wallet.Stakingheader.totalProfit
        labelShare.text = Localizable.Waves.Wallet.Stakingheader.share
    }
    
    @IBAction private func howWorksTapped(_ sender: Any) {
        howWorksAction?()
    }
    
    @IBAction private func twitterTapped(_ sender: Any) {
        twAction?()
    }
    
    @IBAction private func fbTapped(_ sender: Any) {
        fbAction?()
    }
    
    @IBAction private func vkTapped(_ sender: Any) {
        vkAction?()
    }
}

extension StakingHeaderView: ViewConfiguration {
    
    func update(with model: WalletTypes.DTO.Staking.Profit) {

        setupLocalization()
                        
        let backgroundColor: UIColor = UIColor.white.withAlphaComponent(0.15)
        
        balanceLabel.update(with: .init(balance: model.total,
                                        sign: nil,
                                        style: .custom(font: UIFont.systemFont(ofSize: 17,
                                                                               weight: .bold),
                                                       textColor: .white,
                                                       tickerStyle: .custom(backgroundColor: backgroundColor,
                                                                            textColor: .white))))
        
        labelPercent.attributedText = .styleForBalance(text: String(format: "%.02f", model.percent),
                                                       font: labelPercent.font,
                                                       weight: .bold)
    }
}

extension StakingHeaderView: ViewHeight {
    
    static func viewHeight() -> CGFloat {
        Contants.height
    }
}
