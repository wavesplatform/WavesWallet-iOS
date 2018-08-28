//
//  AssetBalanceCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/1/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let heightViewWithoutBalances: CGFloat = 188
    static let heightViewWithBalance: CGFloat = 208
    static let heightBalanceView: CGFloat = 42
    static let heightFirstBalanceView: CGFloat = 28
    static let bottomPadding: CGFloat = 8
    static let heightSeparator: CGFloat = 0.5
    static let countSeparatorsWhenThreeFields = 3
    static let countSeparatorsWhenTwoFields = 3
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

    @IBOutlet private(set) var sendButton: UIButton!
    @IBOutlet private(set) var receiveButton: UIButton!
    @IBOutlet private(set) var exchangeButton: UIButton!

    private var options: Options = Options(isHiddenLeased: false, isHiddenInOrder: false)
    private var isNeedsUpdateConstraints: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
        backgroundColor = .basic50        
    }

    override func updateConstraints() {

        if isNeedsUpdateConstraints {
            isNeedsUpdateConstraints = false

            viewLeased.isHidden = options.isHiddenLeased
            viewInOrder.isHidden = options.isHiddenInOrder
            viewTotal.isHidden = options.isHiddenLeased && options.isHiddenInOrder

            if options.isHiddenInOrder && options.isHiddenLeased {
                firstSeparatorView.isHidden = false
                secondSeparatorView.isHidden = true
                thirdSeparatorView.isHidden = true
            } else if !options.isHiddenInOrder && !options.isHiddenLeased {
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

    func update(with model: AssetTypes.DTO.Asset.Balance) {

        options = Options(isHiddenLeased: model.leasedMoney.isZero, isHiddenInOrder: model.inOrderMoney.isZero)

        sendButton.setTitle(Localizable.Asset.Cell.Balance.Button.send, for: .normal)
        receiveButton.setTitle(Localizable.Asset.Cell.Balance.Button.receive, for: .normal)
        exchangeButton.setTitle(Localizable.Asset.Cell.Balance.Button.exchange, for: .normal)

        titleLabel.text = Localizable.Asset.Cell.Balance.avaliableBalance

        balanceLabel.attributedText = NSAttributedString.styleForBalance(text: model.avaliableMoney.displayTextFull,
                                                                         font: balanceLabel.font)

        viewLeased.update(with: .init(name: Localizable.Asset.Cell.Balance.leased,
                                      money: model.leasedMoney))
        viewInOrder.update(with: .init(name: Localizable.Asset.Cell.Balance.inOrderBalance,
                                       money: model.inOrderMoney))
        viewTotal.update(with: .init(name: Localizable.Asset.Cell.Balance.totalBalance,
                                     money: model.totalMoney))

        isNeedsUpdateConstraints = true
        setNeedsUpdateConstraints()
    }
}

extension AssetBalanceCell: ViewCalculateHeight {

    static func viewHeight(model: AssetTypes.DTO.Asset.Balance, width: CGFloat) -> CGFloat {

        let isHiddenLeased = model.leasedMoney.isZero
        let isHiddenInOrder = model.inOrderMoney.isZero

        if isHiddenLeased && isHiddenInOrder {
            return Constants.heightViewWithoutBalances + Constants.bottomPadding
        }

        var height : CGFloat = Constants.heightViewWithoutBalances

        if isHiddenLeased == false {
            height += Constants.heightBalanceView
        }

        if isHiddenInOrder == false {
            height += Constants.heightBalanceView
        }

         height += Constants.heightFirstBalanceView + Constants.bottomPadding

        if isHiddenInOrder && isHiddenLeased {
            height += Constants.heightSeparator
        } else if !isHiddenInOrder && !isHiddenLeased {
            height += Constants.heightSeparator * Constants.countSeparatorsWhenThreeFields
        } else {
            height += Constants.heightSeparator * Constants.countSeparatorsWhenTwoFields
        }

        return height
    }
}
