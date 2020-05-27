//
//  WalletStakingHeaderView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 05.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Extensions
import UIKit
import UITools

private enum Contants {
    static let height: CGFloat = 118
}

final class StakingHeaderView: UITableViewHeaderFooterView, NibReusable, ResetableView {
    @IBOutlet private weak var labelEstimatedInterest: UILabel!
    @IBOutlet private weak var labelPercentTitle: UILabel!
    @IBOutlet private weak var labelPercent: UILabel!

    @IBOutlet private weak var viewEstimetedInterest: GradientView!
    @IBOutlet private weak var viewProfit: GradientView!

    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var buttonHowWorkds: UIButton!

    @IBOutlet private weak var labelTotalProfit: UILabel!
    @IBOutlet private weak var labelShare: UILabel!
    @IBOutlet private weak var balanceLabel: BalanceLabel!

    @IBOutlet private weak var twitterButton: UIButton!
    @IBOutlet private weak var vkButton: UIButton!
    @IBOutlet private weak var fbButton: UIButton!

    var howWorksAction: (() -> Void)?
    var twAction: (() -> Void)?
    var fbAction: (() -> Void)?
    var vkAction: (() -> Void)?

    @IBAction private func howWorksTapped(_: Any) {
        howWorksAction?()
    }

    @IBAction private func twitterTapped(_: Any) {
        twAction?()
    }

    @IBAction private func fbTapped(_: Any) {
        fbAction?()
    }

    @IBAction private func vkTapped(_: Any) {
        vkAction?()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        do {
            let twitterImage = Images.twitter20White.image.withRenderingMode(.alwaysTemplate)
            twitterButton.tintColor = UIColor.white.withAlphaComponent(0.5)
            twitterButton.setImage(twitterImage, for: .normal)

            let fbImage = Images.fb20White.image.withRenderingMode(.alwaysTemplate)
            fbButton.tintColor = UIColor.white.withAlphaComponent(0.5)
            fbButton.setImage(fbImage, for: .normal)

            let vkImage = Images.vk20White.image.withRenderingMode(.alwaysTemplate)
            vkButton.tintColor = UIColor.white.withAlphaComponent(0.5)
            vkButton.setImage(vkImage, for: .normal)
        }

        backgroundColor = .basic50
        contentView.backgroundColor = .basic50

        viewEstimetedInterest.setupShadow(options: .init(offset: CGSize(width: 0, height: 4),
                                                         color: .black,
                                                         opacity: 0.1,
                                                         shadowRadius: 4,
                                                         shouldRasterize: true))

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

    override func prepareForReuse() {
        super.prepareForReuse()
        resetToEmptyState()
    }

    func resetToEmptyState() {
        howWorksAction = nil
        twAction = nil
        fbAction = nil
        vkAction = nil

        labelEstimatedInterest.text = nil
        labelPercentTitle.text = nil
        buttonHowWorkds.setTitle(nil, for: .normal)
        labelTotalProfit.text = nil
        labelShare.text = nil

        labelPercent.attributedText = nil
        balanceLabel.resetToEmptyState()
    }

    private func setupLocalization() {
        labelEstimatedInterest.text = Localizable.Waves.Wallet.Stakingheader.estimatedInterest
        labelPercentTitle.text = Localizable.Waves.Wallet.Stakingheader.perYear
        buttonHowWorkds.setTitle(Localizable.Waves.Wallet.Stakingheader.howItWorks, for: .normal)
        labelTotalProfit.text = Localizable.Waves.Wallet.Stakingheader.totalProfit
        labelShare.text = Localizable.Waves.Wallet.Stakingheader.share
    }
}

extension StakingHeaderView: ViewConfiguration {
    func update(with model: InvestmentStakingVM.Profit) {
        setupLocalization()

        let backgroundColor = UIColor.white.withAlphaComponent(0.15)

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
    static func viewHeight() -> CGFloat { Contants.height }
}
