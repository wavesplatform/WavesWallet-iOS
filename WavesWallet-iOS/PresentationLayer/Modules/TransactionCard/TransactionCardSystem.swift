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


private struct OrderQuery: Equatable {

    let order: DomainLayer.DTO.Dex.MyOrder

    static func == (lhs: OrderQuery, rhs: OrderQuery) -> Bool {
        return lhs.order.id == rhs.order.id
    }
}

private typealias Types = TransactionCard

final class TransactionCardSystem: System<TransactionCard.State, TransactionCard.Event> {

    private let kind: TransactionCard.Kind

    private let authorizationInteractor: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
    private let transactionsInteractor: TransactionsInteractorProtocol = FactoryInteractors.instance.transactions
    private let assetsInteractor: AssetsInteractorProtocol = FactoryInteractors.instance.assetsInteractor
    private let dexOrderBookRepository: DexOrderBookRepositoryProtocol = FactoryRepositories.instance.dexOrderBookRepository


    init(kind: TransactionCard.Kind) {
        self.kind = kind
    }

    override func initialState() -> State! {

        let core: State.Core = .init(kind: kind,
                                     contacts: .init(),
                                     showingAllRecipients: false,
                                     feeBalance: nil,
                                     action: .none)

        let sections = section(by: core)

        return State(ui: .init(sections: sections,
                               action: .update),
                     core: core)
    }

    override func internalFeedbacks() -> [Feedback] {
        return [calculateFeeByOrder, cancelOrder]
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
            state.core.feeBalance = fee
            state.ui.sections = [section]
            state.ui.action = .update

        case .cancelOrder:
            state.core.action = .cancelingOrder
            state.ui.action = .none

        case .applyCanceledOrder:

            guard var order = state.core.kind.order else { return }

            order.status = .cancelled
            state.core.kind = .order(order)

            let sections = section(by: state.core)
            state.ui.sections = sections
            state.core.action = .none
            state.ui.action = .didCancelOrder

        case .handlerError(let error):

            state.core.action = .none

            if let error = error as? NetworkError {
                state.ui.action = .error(error)
            } else {
                state.ui.action = .none
            }
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

fileprivate extension TransactionCardSystem {

    private var calculateFeeByOrder: Feedback {
        return react(request: { (state) -> OrderQuery? in

            if case .order(let order) = state.core.kind, state.core.feeBalance == nil {
                return OrderQuery(order: order)
            } else {
                return nil
            }

        }, effects: { [weak self] (query) -> Signal<Types.Event> in

            guard let self = self else { return Signal.empty() }

            let waves = self.getWaves()
            let fee = self.getFee(amountAsset: query.order.amountAsset.id,
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

    private var cancelOrder: Feedback {
        return react(request: { (state) -> OrderQuery? in

            if case .order(let order) = state.core.kind, case .cancelingOrder = state.core.action {
                return OrderQuery(order: order)
            } else {
                return nil
            }

        }, effects: { [weak self] (query) -> Signal<Types.Event> in

            guard let self = self else { return Signal.empty() }

            return self
                .cancelOrder(order: query.order)
                .map { _ in Types.Event.applyCanceledOrder }
                .asSignal { (error) -> Signal<Types.Event> in
                    return Signal.just(.handlerError(error))
                }
        })
    }

    private func cancelOrder(order: DomainLayer.DTO.Dex.MyOrder) -> Observable<Bool> {

        return authorizationInteractor
            .authorizedWallet()
            .flatMap({ [weak self] (wallet) ->  Observable<Bool> in
                guard let self = self else { return Observable.empty() }
                return self
                    .dexOrderBookRepository
                    .cancelOrder(wallet: wallet,
                                 orderId: order.id,
                                 amountAsset: order.amountAsset.id,
                                 priceAsset: order.priceAsset.id)
                    .flatMap({ (status) -> Observable<Bool> in
                        return Observable.just(true)
                    })
        })
    }

    private func getFee(amountAsset: String,
                        priceAsset: String) -> Observable<Money> {
        return authorizationInteractor
            .authorizedWallet()
            .flatMap({ [weak self] (wallet) -> Observable<Money> in
                guard let self = self else { return Observable.empty() }
                return  self
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
                guard let self = self else { return Observable.empty() }
                return  self
                    .assetsInteractor
                    .assets(by: [GlobalConstants.wavesAssetId],
                            accountAddress: wallet.address)
                    .map { $0.first }
                    .filterNil()
            })
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
