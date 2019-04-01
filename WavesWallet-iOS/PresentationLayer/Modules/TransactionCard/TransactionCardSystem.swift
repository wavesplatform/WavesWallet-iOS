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
import RxCocoa

private struct Constants {
    static let shiftIndexInLenght: Int = 1
}


private struct CalculateFeeByOrderQuery: Equatable {

    let order: DomainLayer.DTO.Dex.MyOrder

    static func == (lhs: CalculateFeeByOrderQuery, rhs: CalculateFeeByOrderQuery) -> Bool {
        return lhs.order.id == rhs.order.id
    }
}

private typealias Types = TransactionCard

final class TransactionCardSystem: System<TransactionCard.State, TransactionCard.Event> {

    private let kind: TransactionCard.Kind

    private let authorizationInteractor: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
    private let transactionsInteractor: TransactionsInteractorProtocol = FactoryInteractors.instance.transactions
    private let assetsInteractor: AssetsInteractorProtocol = FactoryInteractors.instance.assetsInteractor

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
        return [calculateFeeByOrder]
    }

    private func getFee(amountAsset: String,
                        priceAsset: String) -> Observable<Money> {
        return authorizationInteractor
            .authorizedWallet()
            .flatMap({ [weak self] (wallet) -> Observable<Money> in
                guard let owner = self else { return Observable.empty() }
                return  owner
                    .transactionsInteractor
                    .calculateFee(by: .createOrder(amountAsset: amountAsset,
                                                   priceAsset: priceAsset),
                                  accountAddress: wallet.address)
        })
    }

    private func getWaves() -> Observable<DomainLayer.DTO.Asset> {
        return authorizationInteractor
            .authorizedWallet()
            .flatMap({ [weak self] (wallet) ->  Observable<DomainLayer.DTO.Asset> in
                guard let owner = self else { return Observable.empty() }
                return  owner
                    .assetsInteractor
                    .assets(by: [GlobalConstants.wavesAssetId],
                            accountAddress: wallet.address)
                    .map { $0.first }
                    .filterNil()
            })
    }

    private var calculateFeeByOrder: Feedback {
        return react(request: { (state) -> CalculateFeeByOrderQuery? in

            if case .order(let order) = state.core.kind {
                return CalculateFeeByOrderQuery(order: order)
            } else {
                return nil
            }

        }, effects: { [weak self] (query) -> Signal<Types.Event> in

            guard let owner = self else { return Signal.empty() }

            let waves = owner.getWaves()
            let fee = owner.getFee(amountAsset: query.order.amountAsset.id,
                                   priceAsset: query.order.priceAsset.id)

            let balance = Observable.zip(waves, fee)
                .flatMap({ (asset, fee) -> Observable<Balance> in

                    return Observable.just(Balance(currency: .init(title: asset.displayName,
                                                                   ticker: asset.ticker),
                                                   money: fee))
                })
                .map { Types.Event.updateFeeByOrder(fee: $0) }

            return balance.asSignal(onErrorSignalWith: .empty())
        })
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
            let results = massTransferAny.transfers[(transferIndex + Constants.shiftIndexInLenght)..<count]

            let newRows = results
                .enumerated()
                .map { $0.element.createTransactionCardMassSentRecipientModel(currency: massTransferAny.total.currency,
                                                                              number: lastMassReceivedRowIndex + $0.offset + Constants.shiftIndexInLenght * 2,
                                                                              core: state.core) }
                .map { Types.Row.massSentRecipient($0) }

            let insertIndexPaths = [Int](0..<count).map {
                return IndexPath(row: $0 + lastMassReceivedRowIndex + Constants.shiftIndexInLenght, section: 0)
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

            newRowsAtSection.insert(contentsOf: newRows, at: lastMassReceivedRowIndex + Constants.shiftIndexInLenght)

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

        case .updateFeeByOrder(let fee):

            guard var section = state.ui.sections.first else { return }

            let index = section.rows.enumerated().first { (element) -> Bool in
                if case .keyLoading = element.element {
                    return true
                }
                return false
            }?.offset

            guard let feeRowIndex = index else { return }

            let rowFeeModel = TransactionCardKeyBalanceCell.Model(key: Localizable.Waves.Transactioncard.Title.fee,
                                                                  value: BalanceLabel.Model(balance: fee,
                                                                                            sign: nil,
                                                                                            style: .small),
                                                                  style: .largePadding)
            section.rows.remove(at: feeRowIndex)
            section.rows.insert(.keyBalance(rowFeeModel), at: feeRowIndex)

            state.ui.sections = [section]
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
