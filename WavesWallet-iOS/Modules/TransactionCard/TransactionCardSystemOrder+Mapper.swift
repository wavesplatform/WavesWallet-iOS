//
//  TransactionCardSystemOrder+Mapper.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 01/04/2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import Extensions
import DomainLayer


fileprivate typealias Types = TransactionCard

extension DomainLayer.DTO.Dex.MyOrder {
    
    func sections(core: TransactionCard.State.Core, needSendAgain: Bool = false) ->  [TransactionCard.Section] {

        var rows: [Types.Row] = .init()

        var statusValue: String? = nil
        var percent: String = ""

        switch status {
        case .accepted, .partiallyFilled, .filled:
            statusValue = nil
            percent = "\(self.filledPercent)% "

        case .cancelled:
            statusValue = Localizable.Waves.Transactioncard.Title.cancelled
            percent = "\(self.filledPercent)% "
        }


        let rowGeneralModel = TransactionCardGeneralCell.Model(image: Images.tExchange48.image,
                                                               title: Localizable.Waves.Transactioncard.Title.status,
                                                               info: .status(percent, status: statusValue))

        rows.append(contentsOf:[.general(rowGeneralModel)])
        rows.append(.dashedLine(.bottomPadding))
        rows.append(.orderFilled(.init(filled: .init(balance: filledBalance,
                                                     sign: type == .buy ? .plus : .minus,
                                                     style: .small))))
        
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

        if let feeBalance = core.feeBalance {

            let rowFeeModel = TransactionCardKeyBalanceCell.Model(key: Localizable.Waves.Transactioncard.Title.fee,
                                                                  value: BalanceLabel.Model(balance: feeBalance,
                                                                                            sign: nil,
                                                                                            style: .small),
                                                                  style: .largePadding)
            rows.append(.keyBalance(rowFeeModel))
        } else {
            rows.append(.keyLoading(self.rowFeeLoadingModel))
        }

        rows.append(.keyValue(self.rowTimestampModel))
        rows.append(.dashedLine(.topPadding))

        switch status {
        case .accepted, .partiallyFilled:
            let rowActionsModel = TransactionCardActionsCell.Model(buttons: [.cancelOrder])
            rows.append(.actions(rowActionsModel))
        default:
            break
        }

        let section = Types.Section(rows: rows)

        return [section]
    }
}

private extension DomainLayer.DTO.Dex.MyOrder {

    var rowFeeLoadingModel: TransactionCardKeyLoadingCell.Model {
        return TransactionCardKeyLoadingCell.Model(key: Localizable.Waves.Transactioncard.Title.fee,
                                                   style: .largePadding)
    }

    var rowTimestampModel: TransactionCardKeyValueCell.Model {

        let formatter = DateFormatter.uiSharedFormatter(key: TransactionCard.Constants.transactionCardDateFormatterKey)
        formatter.dateFormat = Localizable.Waves.Transactioncard.Timestamp.format
        let timestampValue = formatter.string(from: self.time)

        return TransactionCardKeyValueCell.Model(key: Localizable.Waves.Transactioncard.Title.timestamp,
                                                 value: timestampValue,
                                                 style: .init(padding: .normalPadding, textColor: .black))
    }
}
