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

final class WalletStakingHeaderView: UITableViewHeaderFooterView, NibReusable {

    @IBOutlet private weak var labelEstimatedInterest: UILabel!
    @IBOutlet private weak var labelPercentTitle: UILabel!
    @IBOutlet private weak var labelPercent: UILabel!
    
    @IBOutlet private weak var viewEstimetedInterest: GradientView!
    @IBOutlet private weak var viewProfit: GradientView!
        
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var buttonHowWorkds: UIButton!
    @IBOutlet weak var labelTotalProfit: UILabel!
    @IBOutlet weak var labelTotalProfitValue: UILabel!
    @IBOutlet weak var labelShare: UILabel!
    
    var howWorksAction:(() -> Void)?
    var twAction:((String) -> Void)?
    var fbAction:((String) -> Void)?
    var vkAction:((String) -> Void)?
    
    private var sharedText = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewProfit.setupShadow(options: .init(offset: CGSize(width: 0, height: 2),
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
        labelPercentTitle.text = "% " + Localizable.Waves.Wallet.Stakingheader.perYear
        buttonHowWorkds.setTitle(Localizable.Waves.Wallet.Stakingheader.howItWorks, for: .normal)
        labelTotalProfit.text = Localizable.Waves.Wallet.Stakingheader.totalProfit
        labelShare.text = Localizable.Waves.Wallet.Stakingheader.share
    }
    
    @IBAction private func howWorksTapped(_ sender: Any) {
        howWorksAction?()
    }
    
    @IBAction private func twitterTapped(_ sender: Any) {
        twAction?(sharedText)
    }
    
    @IBAction private func fbTapped(_ sender: Any) {
        fbAction?(sharedText)
    }
    
    @IBAction private func vkTapped(_ sender: Any) {
        vkAction?(sharedText)
    }
}

extension WalletStakingHeaderView: ViewConfiguration {
    
    func update(with model: WalletTypes.DTO.Staking.Profit) {

        setupLocalization()
        
        sharedText = Localizable.Waves.Wallet.sharedTitle(model.total.displayText,
                                                          String(format: "%.02f%%", model.percent))
        
        labelTotalProfitValue.attributedText = .styleForBalance(text: model.total.displayText,
                                                                font: labelTotalProfitValue.font,
                                                                weight: .bold)
        
        labelPercent.attributedText = .styleForBalance(text: String(format: "%.02f", model.percent),
                                                       font: labelPercent.font,
                                                       weight: .bold)
        
    }
}

extension WalletStakingHeaderView: ViewHeight {
    
    static func viewHeight() -> CGFloat {
        return Contants.height
    }
}
