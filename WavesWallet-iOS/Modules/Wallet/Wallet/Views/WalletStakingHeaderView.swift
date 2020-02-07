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
    static let height: CGFloat = 110
}

final class WalletStakingHeaderView: UITableViewHeaderFooterView, NibReusable {

    @IBOutlet private weak var labelEstimatedInterest: UILabel!
    @IBOutlet private weak var labelPercentTitle: UILabel!
    @IBOutlet private weak var labelPercent: UILabel!
    @IBOutlet private weak var viewEstimetedInterest: GradientView!
    @IBOutlet private weak var viewProfit: GradientView!
    @IBOutlet private weak var viewContainer: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.setupShadow(options: .init(offset: CGSize(width: 0, height: 5),
                                                 color: .black,
                                                 opacity: 0.1,
                                                 shadowRadius: 5,
                                                 shouldRasterize: true))

        viewEstimetedInterest.startColor = .orangeYellow
        viewEstimetedInterest.endColor = .pumpkinOrange
        viewEstimetedInterest.direction = .custom(GradientView.Settings(startPoint: CGPoint(x: 0, y: 1),
                                                                        endPoint: CGPoint(x: 0, y: 0),
                                                                        locations: [0.0, 0.6]))
      
        viewProfit.startColor = .azureTwo
        viewProfit.endColor = .azure
        viewProfit.direction = .horizontal            
    }
    
    private func setupLocalization() {
        labelEstimatedInterest.text = Localizable.Waves.Wallet.Stakingheader.estimatedInterest
        labelPercentTitle.text = "% " + Localizable.Waves.Wallet.Stakingheader.percentPerYear
    }
}

extension WalletStakingHeaderView: ViewConfiguration {
    
    func update(with model: WalletTypes.DTO.Staking.Profit) {

        setupLocalization()
        
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
