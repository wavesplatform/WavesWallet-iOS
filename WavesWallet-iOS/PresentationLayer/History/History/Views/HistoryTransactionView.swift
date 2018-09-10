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
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
        viewContainer.cornerRadius = 2
    }
}


fileprivate extension HistoryTransactionView {

    func update(with asset: DomainLayer.DTO.Asset, balance: Balance, sign: Balance.Sign = .none) {

        if asset.isSpam {
            tickerView.isHidden = false
            tickerView.update(with: .init(text: Localizable.General.Ticker.Title.spam,
                                          style: .normal))
            labelValue.attributedText = .styleForBalance(text: balance.displayText(sign: sign, withoutCurrency: false), font: labelValue.font)
            return
        }

        if let ticker = balance.currency.ticker {
            tickerView.isHidden = false
            tickerView.update(with: .init(text: ticker,
                                          style: .soft))
            labelValue.attributedText = .styleForBalance(text: balance.displayText(sign: sign, withoutCurrency: true), font: labelValue.font)
        } else {
            tickerView.isHidden = true
            labelValue.attributedText = .styleForBalance(text: balance.displayText(sign: sign, withoutCurrency: false), font: labelValue.font)
        }
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

            if tx.order1.kind == .buy {
                update(with: tx.order1.pair.amountAsset, balance: tx.order1.amount, sign: .plus)
            } else {
                update(with: tx.order2.pair.amountAsset, balance: tx.order2.amount)
            }



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
            update(with: tx.asset, balance: tx.balance, sign: .minus)

        case .unrecognisedTransaction:
            labelValue.text = nil

        case .massSent(let tx):
            update(with: tx.asset, balance: tx.total, sign: .plus)

        case .massReceived(let tx):
            update(with: tx.asset, balance: tx.total, sign: .minus)

        case .spamReceive(let tx):
            update(with: tx.asset, balance: tx.balance, sign: .plus)

        case .spamMassReceived(let tx):
            update(with: tx.asset, balance: tx.total, sign: .plus)

        case .data:
            labelValue.text = Localizable.General.History.Transaction.Value.data
        }


//            if asset.isSpam {
//                tickerView.isHidden = false
//                tickerView.update(with: .init(text: Localizable.General.Ticker.Title.spam,
//                                              style: .normal))
//            } else if asset.isGeneral {
//                tickerView.isHidden = false
//                tickerView.update(with: .init(text: asset.name,
//                                              style: .soft))
//            }

//            labelValue.attributedText = .styleForBalance(text: asset.title,
//                                                        font: labelValue.font)
//        } else {
//            switch model.kind {
//            case .data:
//                labelValue.text = Localizable.General.History.Transaction.Value.data
//            case .createdAlias(let name):
//                labelValue.text = name
//            default:
//                labelValue.text = "nil"
//            }
//        }
    }
}

fileprivate extension GeneralTypes.DTO.Transaction.Asset {

    var title: String {
        if let ticker = balance.currency.ticker, isGeneral == false {
            return "\(balance.money.displayTextFull) \(ticker)"
        } else {
            return "\(balance.money.displayTextFull)"
        }
    }
}

extension DomainLayer.DTO.SmartTransaction {

    var title: String {

        switch kind {
        case .receive:
            return Localizable.General.History.Transaction.Title.received

        case .sent:
            return Localizable.General.History.Transaction.Title.sent

        case .startedLeasing:
            return Localizable.General.History.Transaction.Title.startedLeasing

        case .exchange(let tx):
            return "_0_0_"

        case .canceledLeasing:
            return Localizable.General.History.Transaction.Title.canceledLeasing

        case .tokenGeneration:
            return Localizable.General.History.Transaction.Title.tokenGeneration

        case .tokenBurn:
            return Localizable.General.History.Transaction.Title.tokenBurn

        case .tokenReissue:
            return Localizable.General.History.Transaction.Title.tokenReissue

        case .selfTransfer:
            return Localizable.General.History.Transaction.Title.selfTransfer

        case .createdAlias:
            return Localizable.General.History.Transaction.Title.alias

        case .incomingLeasing:
            return Localizable.General.History.Transaction.Title.incomingLeasing

        case .unrecognisedTransaction:
            return Localizable.General.History.Transaction.Title.unrecognisedTransaction

        case .massSent:
            return Localizable.General.History.Transaction.Title.sent

        case .massReceived:
            return Localizable.General.History.Transaction.Title.received

        case .spamReceive:
            return Localizable.General.History.Transaction.Title.received

        case .spamMassReceived:
           return Localizable.General.History.Transaction.Title.received

        case .data:
            return Localizable.General.History.Transaction.Title.data
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

