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

extension HistoryTransactionView: ViewConfiguration {
    
    func update(with model: GeneralTypes.DTO.Transaction) {

//        imageViewIcon.image = model.kind.image
//        labelTitle.text = model.kind.title
//        tickerView.isHidden = true
//        labelValue.text = nil
//
//        if let asset = model.kind.asset {
//            if asset.isSpam {
//                tickerView.isHidden = false
//                tickerView.update(with: .init(text: Localizable.General.Ticker.Title.spam,
//                                              style: .normal))
//            } else if asset.isGeneral {
//                tickerView.isHidden = false
//                tickerView.update(with: .init(text: asset.name,
//                                              style: .soft))
//            }
//
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

extension GeneralTypes.DTO.Transaction {

//    var asset: GeneralTypes.DTO.Transaction.Asset? {
//
//        switch kind {
//        case .receive(let tx):
//            return GeneralTypes.DTO.Transaction.Asset(
//
//        case .sent(let asset):
//            return asset
//
//        case .startedLeasing(let asset):
//            return asset
//
//        case .exchange(_, _):
//            return from
//
//        case .canceledLeasing(let asset):
//            return asset
//
//        case .tokenGeneration(let asset):
//            return asset
//
//        case .tokenBurn(let asset):
//            return asset
//
//        case .tokenReissue(let asset):
//            return asset
//
//        case .selfTransfer(let asset):
//            return asset
//
//        case .createdAlias:
//            return nil
//
//        case .incomingLeasing(let asset):
//            return asset
//
//        case .unrecognisedTransaction:
//            return nil
//
//        case .massSent(let asset):
//            return asset
//
//        case .massReceived(let asset):
//            return asset
//
//        case .spamReceive(let asset):
//            return asset
//
//        case .spamMassReceived(let asset):
//            return asset
//
//        case .data:
//            return nil
//        }
//    }
//
//    var title: String {
//
//        switch kind {
//        case .receive:
//            return Localizable.General.History.Transaction.Title.received
//
//        case .sent:
//            return Localizable.General.History.Transaction.Title.sent
//
//        case .startedLeasing:
//            return Localizable.General.History.Transaction.Title.startedLeasing
//
//        case .exchange(_, _):
//            return "" //from.title
//
//        case .canceledLeasing:
//            return Localizable.General.History.Transaction.Title.canceledLeasing
//
//        case .tokenGeneration:
//            return Localizable.General.History.Transaction.Title.tokenGeneration
//
//        case .tokenBurn:
//            return Localizable.General.History.Transaction.Title.tokenBurn
//
//        case .tokenReissue:
//            return Localizable.General.History.Transaction.Title.tokenReissue
//
//        case .selfTransfer:
//            return Localizable.General.History.Transaction.Title.selfTransfer
//
//        case .createdAlias:
//            return Localizable.General.History.Transaction.Title.alias
//
//        case .incomingLeasing:
//            return Localizable.General.History.Transaction.Title.incomingLeasing
//
//        case .unrecognisedTransaction:
//            return Localizable.General.History.Transaction.Title.unrecognisedTransaction
//
//        case .massSent:
//            return Localizable.General.History.Transaction.Title.sent
//
//        case .massReceived:
//            return Localizable.General.History.Transaction.Title.received
//
//        case .spamReceive:
//            return Localizable.General.History.Transaction.Title.received
//
//        case .spamMassReceived:
//           return Localizable.General.History.Transaction.Title.received
//
//        case .data:
//            return Localizable.General.History.Transaction.Title.data
//        }
//    }

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

