//
//  BalanceLabel.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 06/03/2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import UIKit

final class BalanceLabel: UIView, NibOwnerLoadable {
    @IBOutlet private var contentView: UIView!

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var tickerView: TickerView!
    @IBOutlet private var stackView: UIStackView!

    struct Model {
        enum Style {
            case large
            case medium
            case small
            case custom(font: UIFont,
                        textColor: UIColor,
                        tickerStyle: TickerView.Model.Style)
        }

        let balance: DomainLayer.DTO.Balance
        let sign: DomainLayer.DTO.Balance.Sign?
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
            switch model.style {
            case .custom(_, _, let tickerStyle):
                tickerView.update(with: .init(text: ticker,
                                              style: tickerStyle))
            default:
                tickerView.update(with: .init(text: ticker,
                                              style: .normal))
            }
            tickerView.isHidden = false
            hasTicker = true
        } else {
            tickerView.isHidden = true
        }

        switch model.style {
        case let .custom(font, textColor, _):

            titleLabel.attributedText = NSMutableAttributedString.attributtedString(model: model,
                                                                                    hasTicker: hasTicker,
                                                                                    font: font,
                                                                                    textColor: textColor)
        case .large:

            titleLabel.attributedText = NSMutableAttributedString.attributtedString(model: model,
                                                                                    hasTicker: hasTicker,
                                                                                    font: UIFont.systemFont(ofSize: 22,
                                                                                                            weight: .regular),
                                                                                    textColor: .black)

        case .medium:

            let font = UIFont.systemFont(ofSize: 17, weight: .regular)
            titleLabel.attributedText = NSMutableAttributedString.attributtedString(model: model,
                                                                                    hasTicker: hasTicker,
                                                                                    font: font,
                                                                                    textColor: .black)

        case .small:

            let text = balance.displayText(sign: model.sign ?? .none,
                                           withoutCurrency: hasTicker)

            let attrString = NSMutableAttributedString(string: text,
                                                       attributes: [.font: UIFont.systemFont(ofSize: 13, weight: .regular)])

            titleLabel.attributedText = attrString
        }

        setNeedsUpdateConstraints()
    }
}

private extension NSMutableAttributedString {
    static func attributtedString(model: BalanceLabel.Model,
                                  hasTicker: Bool,
                                  font: UIFont,
                                  textColor: UIColor) -> NSMutableAttributedString {
        let balance = model.balance

        let text = balance.displayText(sign: model.sign ?? .none,
                                       withoutCurrency: true)

        let string = NSMutableAttributedString()
        string.append(.styleForBalance(text: text,
                                       font: font))

        string.addAttributes([.foregroundColor: textColor], range: NSRange(location: 0, length: string.length))

        if hasTicker == false {
            let name = NSMutableAttributedString(string: " \(balance.currency.title)",
                                                 attributes: [.font: font])
            string.append(name)
        }

        return string
    }
}
