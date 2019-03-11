//
//  BalanceLabel.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 06/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

final class BalanceLabel: UIView, NibOwnerLoadable {

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var tickerView: TickerView!
    @IBOutlet private var stackView: UIStackView!

    struct Model {

        //mb need custom style ?
        enum Style {
            case large
            case small
        }

        let balance: Balance
        let sign: Balance.Sign?
        let style: Style
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: frame.width, height: UIView.noIntrinsicMetric)
    }
}

extension BalanceLabel: ViewConfiguration {

    func update(with model: BalanceLabel.Model) {

        let balance = model.balance

        var hasTicker = false

        if let ticker = balance.currency.ticker {
            tickerView.update(with: .init(text: ticker,
                                          style: .normal))
            tickerView.isHidden = false
            hasTicker = true
        } else {
            tickerView.isHidden = true
        }

        let text = balance.displayText(sign: model.sign ?? .none,
                                       withoutCurrency: hasTicker)

        switch model.style {
        case .large:

            titleLabel.attributedText = .styleForBalance(text: text,
                                                         font: UIFont.boldSystemFont(ofSize: 22))

        case .small:

           let attrString = NSMutableAttributedString(string: text,
                                                      attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .regular)])

            titleLabel.attributedText = attrString
        }

        setNeedsUpdateConstraints()
    }
}
