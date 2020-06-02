//
//  AssetBalanceCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/1/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Extensions
import UIKit
import UITools

fileprivate enum Constants {
    static let heightViewWithoutBalances: CGFloat = 208
    static let heightBalanceView: CGFloat = 42
    static let heightFirstBalanceView: CGFloat = 28
    static let bottomPadding: CGFloat = 8
    static let heightSeparator: CGFloat = 0.5
    static let countSeparatorsWhenThreeFields: CGFloat = 3
    static let countSeparatorsWhenTwoFields: CGFloat = 3

    enum Font {
        static let percentSize: CGFloat = 11
    }
}

final class AssetBalanceCell: UITableViewCell, NibReusable {
    private struct Options {
        var isHiddenLeased: Bool
        var isHiddenInOrder: Bool
    }

    @IBOutlet private var viewContainer: UIView!
    @IBOutlet private var viewLeased: AssetBalanceMoneyInfoView!
    @IBOutlet private var viewTotal: AssetBalanceMoneyInfoView!
    @IBOutlet private var viewInOrder: AssetBalanceMoneyInfoView!
    @IBOutlet private var firstSeparatorView: SeparatorView!
    @IBOutlet private var secondSeparatorView: SeparatorView!
    @IBOutlet private var thirdSeparatorView: SeparatorView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var balanceLabel: UILabel!
    @IBOutlet private weak var labelPriceUsd: UILabel!
    @IBOutlet private weak var viewPercent: PercentTickerView!

    @IBOutlet private var sendButton: UIButton!
    @IBOutlet private var receiveButton: UIButton!
    @IBOutlet private var exchangeButton: UIButton!
    @IBOutlet private var cardButton: UIButton!

    private var options: Options = Options(isHiddenLeased: false, isHiddenInOrder: false)
    private var isNeedsUpdateConstraints: Bool = false

    var receiveAction: (() -> Void)?
    var sendAction: (() -> Void)?
    var exchangeAction: (() -> Void)?
    var cardAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
        backgroundColor = .basic50
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        receiveButton.addTarget(self, action: #selector(receiveTapped), for: .touchUpInside)
        exchangeButton.addTarget(self, action: #selector(exchangeTapped), for: .touchUpInside)
    }

    @objc private func exchangeTapped() {
        exchangeAction?()
    }

    @objc private func receiveTapped() {
        receiveAction?()
    }

    @objc private func sendTapped() {
        sendAction?()
    }
    
    @objc private func cardTapped() {
        cardAction?()
    }

    override func updateConstraints() {
        if isNeedsUpdateConstraints {
            isNeedsUpdateConstraints = false

            viewLeased.isHidden = options.isHiddenLeased
            viewInOrder.isHidden = options.isHiddenInOrder
            viewTotal.isHidden = options.isHiddenLeased && options.isHiddenInOrder

            if options.isHiddenInOrder, options.isHiddenLeased {
                firstSeparatorView.isHidden = false
                secondSeparatorView.isHidden = true
                thirdSeparatorView.isHidden = true
            } else if !options.isHiddenInOrder, !options.isHiddenLeased {
                firstSeparatorView.isHidden = false
                secondSeparatorView.isHidden = false
                thirdSeparatorView.isHidden = false
            } else {
                firstSeparatorView.isHidden = true
                secondSeparatorView.isHidden = false
                thirdSeparatorView.isHidden = false
            }
        }

        super.updateConstraints()
    }
}

extension AssetBalanceCell: ViewConfiguration {
    func update(with model: AssetDetailTypes.DTO.PriceAsset) {
        let balance = model.asset.balance

        cardButton.isHidden = model.hasNeedCard == false
        
        options = Options(isHiddenLeased: balance.leasedMoney.isZero, isHiddenInOrder: balance.inOrderMoney.isZero)

        sendButton.setTitle(Localizable.Waves.Asset.Cell.Balance.Button.send, for: .normal)
        receiveButton.setTitle(Localizable.Waves.Asset.Cell.Balance.Button.receive, for: .normal)
        exchangeButton.setTitle(Localizable.Waves.Asset.Cell.Balance.Button.trade, for: .normal)
        cardButton.setTitle(Localizable.Waves.Asset.Cell.Balance.Button.card, for: .normal)

        titleLabel.text = Localizable.Waves.Asset.Cell.Balance.avaliableBalance

        balanceLabel.attributedText = NSAttributedString
            .styleForBalance(text: balance.avaliableMoney.displayTextFull(isFiat: balance.isFiat),
                             font: balanceLabel.font)

        viewLeased.update(with: .init(name: Localizable.Waves.Asset.Cell.Balance.leased,
                                      money: balance.leasedMoney,
                                      isFiat: balance.isFiat))
        viewInOrder.update(with: .init(name: Localizable.Waves.Asset.Cell.Balance.inOrderBalance,
                                       money: balance.inOrderMoney,
                                       isFiat: balance.isFiat))
        viewTotal.update(with: .init(name: Localizable.Waves.Asset.Cell.Balance.totalBalance,
                                     money: balance.totalMoney,
                                     isFiat: balance.isFiat))

        viewPercent.update(with: .init(firstPrice: model.price.firstPrice,
                                       lastPrice: model.price.lastPrice,
                                       fontSize: Constants.Font.percentSize))
        labelPriceUsd.text = "$ " + model.price.priceUSD.displayText

        isNeedsUpdateConstraints = true
        setNeedsUpdateConstraints()
    }
}

extension AssetBalanceCell: ViewCalculateHeight {
    static func viewHeight(model: AssetDetailTypes.DTO.PriceAsset, width _: CGFloat) -> CGFloat {
        let isHiddenLeased = model.asset.balance.leasedMoney.isZero
        let isHiddenInOrder = model.asset.balance.inOrderMoney.isZero

        if isHiddenLeased, isHiddenInOrder {
            return Constants.heightViewWithoutBalances + Constants.bottomPadding
        }

        var height: CGFloat = Constants.heightViewWithoutBalances

        if isHiddenLeased == false {
            height += Constants.heightBalanceView
        }

        if isHiddenInOrder == false {
            height += Constants.heightBalanceView
        }

        height += Constants.heightFirstBalanceView + Constants.bottomPadding

        if isHiddenInOrder, isHiddenLeased {
            height += Constants.heightSeparator
        } else if !isHiddenInOrder, !isHiddenLeased {
            height += Constants.heightSeparator * Constants.countSeparatorsWhenThreeFields
        } else {
            height += Constants.heightSeparator * Constants.countSeparatorsWhenTwoFields
        }

        return height
    }
}
