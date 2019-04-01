//
//  TransactionCardSystemOrder+Mapper.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 01/04/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

private struct Constants {
    static let filledStatusValue: String = "100%"
}

fileprivate typealias Types = TransactionCard

fileprivate extension DomainLayer.DTO.Dex.Asset {

    var ticker: String? {
        if name == shortName {
            return nil
        } else {
            return shortName
        }
    }

    func balance(_ amount: Int64) -> Balance {
        return balance(amount, precision: decimals)
    }

    func balance(_ amount: Int64, precision: Int) -> Balance {
        return Balance(currency: .init(title: name, ticker: ticker), money: money(amount, precision: precision))
    }

    func money(_ amount: Int64, precision: Int) -> Money {
        return .init(amount, precision)
    }

    func money(_ amount: Int64) -> Money {
        return money(amount, precision: decimals)
    }
}

extension DomainLayer.DTO.Dex.MyOrder {
    
    func sections(core: TransactionCard.State.Core, needSendAgain: Bool = false) ->  [TransactionCard.Section] {

        var rows: [Types.Row] = .init()

        var sign: Balance.Sign = .none
        var title = ""

        let priceDisplayName = self.priceAsset.name
        let amountDisplayName = self.amountAsset.name

        if self.type == .sell {
            sign = .minus
            title = Localizable.Waves.Transactioncard.Title.Exchange.sellPair(amountDisplayName, priceDisplayName)
        } else {
            sign = .plus
            title = Localizable.Waves.Transactioncard.Title.Exchange.buyPair(amountDisplayName, priceDisplayName)
        }

        let rowGeneralModel = TransactionCardGeneralCell.Model(image: Images.tExchange48.image,
                                                               title: title,
                                                               info: .balance(.init(balance: self.filledBalance,
                                                                                    sign: sign,
                                                                                    style: .large)))

        rows.append(contentsOf:[.general(rowGeneralModel)])


        let rowOrderModel = TransactionCardOrderCell.Model(amount: .init(balance: amountBalance,
                                                                         sign: .none,
                                                                         style: .small),
                                                           price: .init(balance: priceBalance,
                                                                        sign: .none,
                                                                        style: .small),
                                                           total: .init(balance: totalBalance,
                                                                        sign: .none,
                                                                        style: .small))

        rows.append(contentsOf:[.order(rowOrderModel)])

        var buttonsActions: [TransactionCardActionsCell.Model.Button] = .init()


        buttonsActions.append(contentsOf: [.viewOnExplorer, .copyTxID, .copyAllData])


//        let rowActionsModel = TransactionCardActionsCell.Model(buttons: buttonsActions)

        rows.append(.keyLoading(self.rowFeeLoadingModel))
        rows.append(.keyValue(self.rowTimestampModel))
        rows.append(.keyValue(self.rowStatusModel))


        let section = Types.Section(rows: rows)

        return [section]
    }
}

fileprivate extension DomainLayer.DTO.Dex.MyOrder {

    var precisionDifference: Int {
        return (priceAsset.decimals - amountAsset.decimals) + 8
    }

    func priceBalance(_ amount: Int64) -> Balance {
        return priceAsset.balance(amount, precision: precisionDifference)
    }

    func amountBalance(_ amount: Int64) -> Balance {
        return amountAsset.balance(amount)
    }

    func totalBalance(priceAmount: Int64, assetAmount: Int64) -> Balance {

        let priceA = Decimal(priceAmount) / pow(10, precisionDifference)
        let assetA = Decimal(assetAmount) / pow(10, amountAsset.decimals)

        let amountA = (priceA * assetA) * pow(10, priceAsset.decimals)

        return priceAsset.balance(amountA.int64Value, precision: priceAsset.decimals)
    }

    var filledBalance: Balance {
        return self.totalBalance(priceAmount: self.price.amount, assetAmount: self.filled.amount)
    }

    var priceBalance: Balance {
        return .init(currency: .init(title: priceAsset.name, ticker: priceAsset.ticker), money: self.price)
    }

    var amountBalance: Balance {
        return .init(currency: .init(title: amountAsset.name, ticker: amountAsset.ticker), money: self.amount)
    }

    var totalBalance: Balance {
        return self.totalBalance(priceAmount: self.price.amount, assetAmount: self.amount.amount)
    }

    var filledPercent: Int64 {
        return max(min(self.filled.amount / self.amount.amount, 100), 0)
    }

    var rowFeeLoadingModel: TransactionCardKeyLoadingCell.Model {
        return TransactionCardKeyLoadingCell.Model(key: Localizable.Waves.Transactioncard.Title.fee,
                                                   style: .largePadding)
    }

    var rowTimestampModel: TransactionCardKeyValueCell.Model {

        let formatter = DateFormatter.sharedFormatter
        formatter.dateFormat = Localizable.Waves.Transactioncard.Timestamp.format
        let timestampValue = formatter.string(from: self.time)

        return TransactionCardKeyValueCell.Model(key: Localizable.Waves.Transactioncard.Title.timestamp,
                                                 value: timestampValue,
                                                 style: .init(padding: .normalPadding, textColor: .black))
    }

    var rowStatusModel: TransactionCardKeyValueCell.Model {

        var value: String = ""

        switch status {
        case .accepted, .partiallyFilled:
            value = "\(self.filledPercent)%"

        case .cancelled:
            value = Localizable.Waves.Transactioncard.Title.cancelled("\(self.filledPercent)")

        case .filled:
            value = Constants.filledStatusValue
        }

        return TransactionCardKeyValueCell.Model(key: Localizable.Waves.Transactioncard.Title.status,
                                                 value: value,
                                                 style: .init(padding: .normalPadding,
                                                              textColor: .submit400))
    }
}
