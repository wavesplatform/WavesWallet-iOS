//
//  HistoryTransactionView.swift
//  WavesWallet-iOS
//
//  Created by Mac on 21/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

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

    func update(with asset: DomainLayer.DTO.Asset, balance: Balance, sign: Balance.Sign = .none) {

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
        let sign: Balance.Sign!
        let ticker = balance.currency.ticker
        
        if tx.myOrder.kind == .sell {
            sign = .minus
            text = Localizable.Waves.History.Transaction.Cell.Exchange.buy(tx.amount.currency.title, tx.price.currency.title)
        }
        else {
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
    
    func styleForBalance(_ balance: Balance, sign: Balance.Sign, ticker: String?, isSpam: Bool) -> NSAttributedString {
        
        let balanceTitle = balance.displayShortText(sign: sign, withoutCurrency: ticker != nil || isSpam == true)
        let attr = NSMutableAttributedString.init(attributedString: .styleForBalance(text: balanceTitle, font: labelValue.font))
        attr.addAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: labelValue.font.pointSize)], range: (balanceTitle as NSString).range(of:  balance.currency.title))
        
        return attr
    }
}


// TODO: ViewConfiguration

extension HistoryTransactionView: ViewConfiguration {

    typealias Model = DomainLayer.DTO.SmartTransaction

    func update(with model: DomainLayer.DTO.SmartTransaction) {

        imageViewIcon.image = model.image
        labelTitle.text = model.title
        tickerView.isHidden = true
        labelValue.text = nil

        switch model.kind {
        case .receive(let tx):
            update(with: tx.asset, balance: tx.balance, sign: .plus)

        case .sent(let tx):
            update(with: tx.asset, balance: tx.balance, sign: .minus)

        case .startedLeasing(let tx):
            update(with: tx.asset, balance: tx.balance)

        case .exchange(let tx):
            
            update(with: tx)

        case .canceledLeasing(let tx):
            update(with: tx.asset, balance: tx.balance)

        case .tokenGeneration(let tx):
            update(with: tx.asset, balance: tx.balance)

        case .tokenBurn(let tx):
            update(with: tx.asset, balance: tx.balance, sign: .minus)

        case .tokenReissue(let tx):
            update(with: tx.asset, balance: tx.balance, sign: .plus)

        case .selfTransfer(let tx):
            update(with: tx.asset, balance: tx.balance)

        case .createdAlias(let name):
            labelValue.text = name

        case .incomingLeasing(let tx):
            update(with: tx.asset, balance: tx.balance)

        case .unrecognisedTransaction:
            labelValue.text = "¯\\_(ツ)_/¯"

        case .massSent(let tx):
            update(with: tx.asset, balance: tx.total, sign: .plus)

        case .massReceived(let tx):
            update(with: tx.asset, balance: tx.myTotal, sign: .plus)

        case .spamReceive(let tx):
            update(with: tx.asset, balance: tx.balance, sign: .plus)

        case .spamMassReceived(let tx):
            update(with: tx.asset, balance: tx.myTotal, sign: .plus)

        case .data:
            labelValue.text = Localizable.Waves.History.Transaction.Value.data
        }
    }
}

extension DomainLayer.DTO.SmartTransaction {

    var title: String {

        switch kind {
        case .receive:
            return Localizable.Waves.History.Transaction.Title.received

        case .sent:
            return Localizable.Waves.History.Transaction.Title.sent

        case .startedLeasing:
            return Localizable.Waves.History.Transaction.Title.startedLeasing

        case .exchange(let tx):
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
            return Localizable.Waves.History.Transaction.Title.data
        }
    }

    var image: UIImage {
        switch kind {
        case .receive:
            return Images.assetReceive.image

        case .sent:
            return Images.tSend48.image

        case .startedLeasing:
            return Images.walletStartLease.image

        case .exchange:
            return Images.tExchange48.image

        case .canceledLeasing:
            return Images.tCloselease48.image

        case .tokenGeneration:
            return Images.tTokengen48.image

        case .tokenBurn:
            return Images.tTokenburn48.image

        case .tokenReissue:
            return Images.tTokenreis48.image

        case .selfTransfer:
            return Images.tSelftrans48.image

        case .createdAlias:
            return Images.tAlias48.image

        case .incomingLeasing:
            return Images.tIncominglease48.image

        case .unrecognisedTransaction:
            return Images.tUndefined48.image

        case .massSent:
            return Images.tMasstransfer48.image

        case .massReceived:
            return Images.tMassreceived48.image

        case .spamReceive:
            return Images.tSpamReceive48.image

        case .spamMassReceived:
            return Images.tSpamMassreceived48.image

        case .data:
            return Images.tData48.image
        }
    }
}

