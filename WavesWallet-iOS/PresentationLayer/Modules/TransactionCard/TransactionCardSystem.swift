//
//  TransactionCardSystem.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 04/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxFeedback
import RxSwift
import RxSwiftExt

private typealias Types = TransactionCard
final class TransactionCardSystem: System<TransactionCard.State, TransactionCard.Event> {

    private let kind: TransactionCard.Kind

    init(kind: TransactionCard.Kind) {
        self.kind = kind
    }

    override func initialState() -> State! {

        let core: State.Core = .init(kind: kind,
                                     contacts: .init(),
                                     showingAllRecipients: false)

        let sections = section(by: core)

        return State(ui: .init(sections: sections,
                               action: .update),
                     core: core)
    }

    override func internalFeedbacks() -> [Feedback] {
        return []
    }

    override func reduce(event: Event, state: inout State) {

        switch event {
        case .viewDidAppear:
            break

        case .showAllRecipients:

            guard let transaction = state.core.kind.transaction else { return }

            guard var section = state.ui.sections.first else { return }
            guard let massTransferAny = transaction.massTransferAny else { return }
            guard let lastMassReceivedRowModel = state.ui.findLastMassReceivedRowModel() else { return }

            guard let lastMassReceivedRowIndex = state.ui.findLastMassReceivedRowIndex() else { return }

            let lastRowAddress = lastMassReceivedRowModel.contactDetail.address
            
            guard let transferIndex = massTransferAny.findTransferIndex(by: lastRowAddress) else { return }


            let count = max(0, massTransferAny.transfers.count)
            let results = massTransferAny.transfers[(transferIndex + 1)..<count]

            let newRows = results
                .enumerated()
                .map { $0.element.createTransactionCardMassSentRecipientModel(currency: massTransferAny.total.currency,
                                                                              number: lastMassReceivedRowIndex + $0.offset + 2,
                                                                              core: state.core) }
                .map { Types.Row.massSentRecipient($0) }

            let insertIndexPaths = [Int](0..<count).map {
                return IndexPath(row: $0 + lastMassReceivedRowIndex + 1, section: 0)
            }

            var newRowsAtSection = section.rows

            newRowsAtSection = newRowsAtSection.filter { (row) -> Bool in
                if case .showAll = row {
                    return false
                }

                return true
            }

            let deleteIndexPaths = section.rows.enumerated().filter { (offset, element) -> Bool in
                if case .showAll = element {
                    return true
                }

                return false
            }
            .map { IndexPath(row: $0.offset , section: 0) }

            newRowsAtSection.insert(contentsOf: newRows, at: lastMassReceivedRowIndex + 1)

            section.rows = newRowsAtSection
            state.core.showingAllRecipients = true
            state.ui.sections = [section]
            state.ui.action = .insertRows(rows: newRows,
                                          insertIndexPaths: insertIndexPaths,
                                          deleteIndexPaths: deleteIndexPaths)

        case .addContact(let contact):

            state.core.contacts[contact.address] = .contact(contact)
            let sections = section(by: state.core)
            state.ui.sections = sections
            state.ui.action = .update

        case .deleteContact(let contact):

            state.core.contacts[contact.address] = .deleted
            let sections = section(by: state.core)
            state.ui.sections = sections
            state.ui.action = .update


        case .editContact(let contact):

            state.core.contacts[contact.address] = .contact(contact)
            let sections = section(by: state.core)
            state.ui.sections = sections
            state.ui.action = .update
        
        }
    }
}

fileprivate extension Types.State.UI {

    func findLastMassReceivedRowModel() -> TransactionCardMassSentRecipientCell.Model? {
        if let last = receivedRowsAny.last, case .massSentRecipient(let model) = last {
            return model
        }

        return nil
    }

    func findLastMassReceivedRowIndex() -> Int? {

        let list = rows.enumerated().filter { (element, model) -> Bool in

            switch model {
            case .massSentRecipient:
                return true

            default:
                return false

            }
        }

        return list.last?.offset
    }

    var receivedRowsAnyModel: [TransactionCardMassSentRecipientCell.Model] {

        return rows.map({ (row) -> TransactionCardMassSentRecipientCell.Model? in

            switch row {
            case .massSentRecipient(let model):
                return model

            default:
                return nil

            }
        })
        .compactMap { $0 }
    }

    var rows: [Types.Row] {
        return self.sections.first?.rows ?? []
    }

    var receivedRowsAny: [Types.Row] {

        return rows.filter { (row) -> Bool in
            switch row {
            case .massSentRecipient:
                return true

            default:
                return false

            }
        }
    }
}

fileprivate extension DomainLayer.DTO.SmartTransaction.MassTransfer {

    func findTransfer(by address: String) -> DomainLayer.DTO.SmartTransaction.MassTransfer.Transfer? {
        return transfers.first { $0.recipient.address == address }
    }

    func findTransferAddress(by address: String) -> String? {
        return transfers.first { $0.recipient.address == address }?.recipient.address
    }

    func findTransferIndex(by address: String) -> Int? {
        return transfers.enumerated().first { $0.element.recipient.address == address }?.offset
    }
}

fileprivate extension DomainLayer.DTO.SmartTransaction {

    var massTransferAny: MassTransfer? {

        switch kind {
        case .massSent(let massTransfer):
            return massTransfer

        default:
            return nil

        }
    }
}

extension TransactionCardSystem {

    func section(by core: TransactionCard.State.Core) -> [TransactionCard.Section]  {
        switch core.kind {
        case .transaction(let tx):
            return tx.sections(core: core)

        case .order(let order):
            return order.sections(core: core)
        }
    }
}

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

    func sections(core: TransactionCard.State.Core, needSendAgain: Bool = false) ->  [Types.Section] {

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


        let rowActionsModel = TransactionCardActionsCell.Model(buttons: buttonsActions)

//        rows.append(contentsOf:[.keyValue(self.rowTimestampModel),
//                                .status(self.rowStatusModel)])


        let section = Types.Section(rows: rows)


        return [section]
    }


//    var rowFeeModel: TransactionCardKeyBalanceCell.Model {
//        return TransactionCardKeyBalanceCell.Model(key: Localizable.Waves.Transactioncard.Title.fee, value: BalanceLabel.Model(balance: self.totalFee,
//                                                                                                                               sign: nil,
//                                                                                                                               style: .small))
//    }
//
    var rowTimestampModel: TransactionCardKeyValueCell.Model {

        let formatter = DateFormatter.sharedFormatter
        formatter.dateFormat = Localizable.Waves.Transactioncard.Timestamp.format
        let timestampValue = formatter.string(from: self.time)

        return TransactionCardKeyValueCell.Model(key: Localizable.Waves.Transactioncard.Title.timestamp, value: timestampValue, style: .normalPadding)
    }
}
