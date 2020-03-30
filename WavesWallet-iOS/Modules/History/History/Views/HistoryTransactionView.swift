//
//  HistoryTransactionView.swift
//  WavesWallet-iOS
//
//  Created by Mac on 21/08/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import UIKit

final class HistoryTransactionView: UIView, NibOwnerLoadable {
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var labelValue: UILabel!
    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!

    @IBOutlet weak var tickerView: TickerView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibContent()

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()

        setup()
    }

    private func setup() {
        viewContainer.addTableCellShadowStyle()
        clipsToBounds = false
    }
}

fileprivate extension HistoryTransactionView {
    func update(with asset: DomainLayer.DTO.Asset, balance: DomainLayer.DTO.Balance, sign: DomainLayer.DTO.Balance.Sign = .none) {
        labelValue.attributedText = styleForBalance(balance, sign: sign, ticker: balance.currency.ticker, isSpam: asset.isSpam)

        if asset.isSpam {
            tickerView.isHidden = false
            tickerView.update(with: .init(text: Localizable.Waves.General.Ticker.Title.spam,
                                          style: .normal))
            return
        }

        if let ticker = balance.currency.ticker {
            tickerView.isHidden = false
            tickerView.update(with: .init(text: ticker,
                                          style: .soft))
        } else {
            tickerView.isHidden = true
        }
    }

    func update(with tx: DomainLayer.DTO.SmartTransaction.Exchange) {
        var text = ""
        let balance = tx.amount
        let sign: DomainLayer.DTO.Balance.Sign!
        let ticker = balance.currency.ticker

        if tx.myOrder.kind == .sell {
            sign = .minus
            text = Localizable.Waves.History.Transaction.Cell.Exchange.sell(tx.amount.currency.title, tx.price.currency.title)
        } else {
            sign = .plus
            text = Localizable.Waves.History.Transaction.Cell.Exchange.buy(tx.amount.currency.title, tx.price.currency.title)
        }

        labelTitle.text = text
        labelValue.attributedText = styleForBalance(balance, sign: sign, ticker: ticker, isSpam: false)

        if let ticker = ticker {
            tickerView.isHidden = false
            tickerView.update(with: .init(text: ticker, style: .soft))
        }
    }

    func styleForBalance(_ balance: DomainLayer.DTO.Balance, sign: DomainLayer.DTO.Balance.Sign, ticker: String?,
                         isSpam: Bool) -> NSAttributedString {
        let balanceTitle = balance.displayShortText(sign: sign, withoutCurrency: ticker != nil || isSpam == true)
        let attr = NSMutableAttributedString(attributedString: .styleForBalance(text: balanceTitle, font: labelValue.font))
        attr
            .addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: labelValue.font.pointSize)],
                           range: (balanceTitle as NSString).range(of: balance.currency.title))

        return attr
    }
}

extension HistoryTransactionView: ViewConfiguration {
    typealias Model = DomainLayer.DTO.SmartTransaction

    func update(with model: DomainLayer.DTO.SmartTransaction) {
        imageViewIcon.image = model.image
        labelTitle.text = model.title
        tickerView.isHidden = true
        labelValue.text = nil

        switch model.kind {
        case let .receive(tx):
            update(with: tx.asset, balance: tx.balance, sign: .plus)

        case let .sent(tx):
            update(with: tx.asset, balance: tx.balance, sign: .minus)

        case let .startedLeasing(tx):
            update(with: tx.asset, balance: tx.balance)

        case let .exchange(tx):

            update(with: tx)

        case let .canceledLeasing(tx):
            update(with: tx.asset, balance: tx.balance)

        case let .tokenGeneration(tx):
            update(with: tx.asset, balance: tx.balance)

        case let .tokenBurn(tx):
            update(with: tx.asset, balance: tx.balance, sign: .minus)

        case let .tokenReissue(tx):
            update(with: tx.asset, balance: tx.balance, sign: .plus)

        case let .selfTransfer(tx):
            update(with: tx.asset, balance: tx.balance)

        case let .createdAlias(name):
            labelValue.text = name

        case let .incomingLeasing(tx):
            update(with: tx.asset, balance: tx.balance)

        case .unrecognisedTransaction:
            labelValue.text = "¯\\_(ツ)_/¯"

        case let .massSent(tx):
            update(with: tx.asset, balance: tx.total, sign: .plus)

        case let .massReceived(tx):
            update(with: tx.asset, balance: tx.myTotal, sign: .plus)

        case let .spamReceive(tx):
            update(with: tx.asset, balance: tx.balance, sign: .plus)

        case let .spamMassReceived(tx):
            update(with: tx.asset, balance: tx.myTotal, sign: .plus)

        case .data:
            labelValue.text = Localizable.Waves.History.Transaction.Title.data

        case let .script(isHasScript):

            if isHasScript {
                labelValue.text = Localizable.Waves.History.Transaction.Value.Setscript.set
            } else {
                labelValue.text = Localizable.Waves.History.Transaction.Value.Setscript.cancel
            }

        case .assetScript:
            labelValue.text = Localizable.Waves.History.Transaction.Value.setAssetScript

        case let .sponsorship(_, tx):
            labelValue.text = tx.displayName

        case .invokeScript:
            labelValue.text = Localizable.Waves.History.Transaction.Value.scriptInvocation
        }
    }
}

fileprivate extension DomainLayer.DTO.SmartTransaction {
    var title: String {
        switch kind {
        case let .receive(tx):

            if tx.hasSponsorship {
                return Localizable.Waves.History.Transaction.Title.receivedSponsorship
            } else {
                return Localizable.Waves.History.Transaction.Title.received
            }

        case .sent:
            return Localizable.Waves.History.Transaction.Title.sent

        case .startedLeasing:
            return Localizable.Waves.History.Transaction.Title.startedLeasing

        case let .exchange(tx):
            let myOrder = tx.myOrder

            if myOrder.kind == .sell {
                return tx.amount.displayShortText(sign: .minus, withoutCurrency: false)
            } else {
                return tx.amount.displayShortText(sign: .plus, withoutCurrency: false)
            }

        case .canceledLeasing:
            return Localizable.Waves.History.Transaction.Title.canceledLeasing

        case .tokenGeneration:
            return Localizable.Waves.History.Transaction.Title.tokenGeneration

        case .tokenBurn:
            return Localizable.Waves.History.Transaction.Title.tokenBurn

        case .tokenReissue:
            return Localizable.Waves.History.Transaction.Title.tokenReissue

        case .selfTransfer:
            return Localizable.Waves.History.Transaction.Title.selfTransfer

        case .createdAlias:
            return Localizable.Waves.History.Transaction.Title.alias

        case .incomingLeasing:
            return Localizable.Waves.History.Transaction.Title.incomingLeasing

        case .unrecognisedTransaction:
            return Localizable.Waves.History.Transaction.Title.unrecognisedTransaction

        case .massSent:
            return Localizable.Waves.History.Transaction.Title.masssent

        case .massReceived:
            return Localizable.Waves.History.Transaction.Title.massreceived

        case .spamReceive:
            return Localizable.Waves.History.Transaction.Title.received

        case .spamMassReceived:
            return Localizable.Waves.History.Transaction.Title.received

        case .data:
            return Localizable.Waves.History.Transaction.Title.entryInBlockchain

        case .script:
            return Localizable.Waves.History.Transaction.Title.entryInBlockchain

        case .assetScript:
            return Localizable.Waves.History.Transaction.Title.entryInBlockchain

        case let .sponsorship(isEnabled, _):
            if isEnabled {
                return Localizable.Waves.History.Transaction.Value.Setsponsorship.set
            } else {
                return Localizable.Waves.History.Transaction.Value.Setsponsorship.cancel
            }

        case .invokeScript:
            return Localizable.Waves.History.Transaction.Title.entryInBlockchain
        }
    }

    var image: UIImage {
        return kind.image
    }
}
