//
//  TransactionsInteractor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 04.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya
import RxSwift

protocol TransactionsInteractorProtocol {
    func transactions(by accountAddress: String, specifications: TransactionsSpecifications) -> AsyncObservable<[DomainLayer.DTO.SmartTransaction]>
}

fileprivate enum Constants {
    static let durationInseconds: Double = 15
    static let maxLimit: Int = 10000
    static let offset: Int = 50
}

fileprivate typealias IsHasTransactionsQuery = (ids: [String], transactions: [DomainLayer.DTO.AnyTransaction])
fileprivate typealias IsHasTransactionsResult = (isHasTransactions: Bool, transactions: [DomainLayer.DTO.AnyTransaction])

fileprivate typealias IfNeededLoadNextTransactionsQuery = (accountAddress: String,
    specifications: TransactionsSpecifications,
    currentOffset: Int,
    currentLimit: Int)

fileprivate typealias NextTransactionsQuery = (accountAddress: String,
    specifications: TransactionsSpecifications,
    currentOffset: Int,
    currentLimit: Int,
    isHasTransactions: Bool,
    transactions: [DomainLayer.DTO.AnyTransaction])

fileprivate typealias InitialTransactionsQuery = (accountAddress: String,
    specifications: TransactionsSpecifications,
    isHasTransactions: Bool)


fileprivate typealias SmartTransactionsQuery = (accountAddress: String, transactions: [DomainLayer.DTO.AnyTransaction])
fileprivate typealias AnyTransactionsQuery = (accountAddress: String, specifications: TransactionsSpecifications)

final class TransactionsInteractor: TransactionsInteractorProtocol {

    typealias AnyTransactionsObservable = Observable<[DomainLayer.DTO.AnyTransaction]>
    typealias SmartTransactionsObservable = Observable<[DomainLayer.DTO.SmartTransaction]>

    private var transactionsRepositoryLocal: TransactionsRepositoryProtocol = FactoryRepositories.instance.transactionsRepositoryLocal
    private var transactionsRepositoryRemote: TransactionsRepositoryProtocol = FactoryRepositories.instance.transactionsRepositoryRemote

    private var assetsInteractors: AssetsInteractorProtocol = FactoryInteractors.instance.assetsInteractor
    private var accountsInteractors: AccountsInteractorProtocol = FactoryInteractors.instance.accounts

    private var blockRepositoryRemote: BlockRepositoryProtocol = FactoryRepositories.instance.blockRemote

    func transactions(by accountAddress: String, specifications: TransactionsSpecifications) -> SmartTransactionsObservable {

        return transactionsRepositoryLocal
            .isHasTransactions
            .map { InitialTransactionsQuery(accountAddress: accountAddress,
                                            specifications: specifications,
                                            isHasTransactions: $0) }
            .flatMap(weak: self, selector: { $0.initialTransaction })
    }

}

// MARK: Main Logic download/save transactions

fileprivate extension TransactionsInteractor {

    private func initialTransaction(query: InitialTransactionsQuery) -> SmartTransactionsObservable {

        if query.isHasTransactions {
            return ifNeededLoadNextTransactions(IfNeededLoadNextTransactionsQuery(accountAddress: query.accountAddress,
                                                          specifications: query.specifications,
                                                          currentOffset: 0,
                                                          currentLimit: Constants.offset))
        } else {
            return firstTransactionsLoading(query.accountAddress,
                                           specifications: query.specifications)
        }
    }

    private func firstTransactionsLoading(_ accountAddress: String,
                                         specifications: TransactionsSpecifications) -> SmartTransactionsObservable {

        return transactionsRepositoryRemote
            .transactions(by: accountAddress, offset: 0, limit: Constants.maxLimit)
            .flatMap(weak: self, selector: { $0.saveTransactions })
            .map { _ in AnyTransactionsQuery(accountAddress: accountAddress, specifications: specifications) }
            .flatMap(weak: self, selector: { $0.smartTransactionsFromAnyTransactions })
    }

    private func ifNeededLoadNextTransactions(_ query: IfNeededLoadNextTransactionsQuery) -> SmartTransactionsObservable {

        return transactionsRepositoryRemote
            .transactions(by: query.accountAddress,
                          offset: query.currentOffset,
                          limit: query.currentLimit)
            .map {
                let ids = $0.reduce(into: [String]()) { list, tx in
                    list.append(tx.id)
                }

                return IsHasTransactionsQuery(ids: ids, transactions: $0)
            }
            .flatMap(weak: self, selector: { $0.isHasTransactions })
            .map { NextTransactionsQuery(accountAddress: query.accountAddress,
                                         specifications: query.specifications,
                                         currentOffset: query.currentOffset,
                                         currentLimit: query.currentLimit,
                                         isHasTransactions: $0.isHasTransactions,
                                         transactions: $0.transactions) }
            .flatMap(weak: self, selector: { $0.nextTransactions })

    }

    private func nextTransactions(_ query: NextTransactionsQuery) -> SmartTransactionsObservable {

        if query.isHasTransactions {
            return smartTransactionsFromAnyTransactions(AnyTransactionsQuery(accountAddress: query.accountAddress,
                                                                             specifications: query.specifications))
        } else {
            return saveTransactions(query.transactions)
                .map { _ in IfNeededLoadNextTransactionsQuery(accountAddress: query.accountAddress,
                                                         specifications: query.specifications,
                                                         currentOffset: query.currentOffset + query.currentLimit,
                                                         currentLimit: query.currentLimit) }
                .flatMap(weak: self, selector: { $0.ifNeededLoadNextTransactions })
        }
    }

    private func isHasTransactions(_ query: IsHasTransactionsQuery) -> Observable<IsHasTransactionsResult> {

        return transactionsRepositoryLocal
            .isHasTransactions(by: query.ids)
            .map { IsHasTransactionsResult(isHasTransactions: $0,
                                           transactions: query.transactions)}
    }

    private func saveTransactions(_ transactions: [DomainLayer.DTO.AnyTransaction]) -> AsyncObservable<Bool> {

        let newTxs = normalizeTransactions(transactions)

        return transactionsRepositoryLocal
            .saveTransactions(newTxs)
    }

    private func smartTransactionsFromAnyTransactions(_ query: AnyTransactionsQuery) -> SmartTransactionsObservable {

        return anyTransactions(query)
            .map { SmartTransactionsQuery(accountAddress: query.accountAddress, transactions: $0) }
            .flatMap(weak: self, selector: { $0.smartTransactions })
    }

    private func anyTransactions(_ query: AnyTransactionsQuery) -> AnyTransactionsObservable {

        return transactionsRepositoryLocal
            .transactions(by: query.accountAddress, specifications: query.specifications)
    }

    private func smartTransactions(_ query: SmartTransactionsQuery) -> SmartTransactionsObservable {

        guard query.transactions.count != 0 else { return Observable.just([]) }
        let assetsIds = query.transactions.assetsIds
        let accountsIds = query.transactions.accountsIds


        let assets = assetsInteractors
            .assets(by: assetsIds,
                  accountAddress: query.accountAddress,
                  isNeedUpdated: false)
            .map { $0.reduce(into: [String: DomainLayer.DTO.Asset](), { list, asset in
                    list[asset.id] = asset
                })
            }
        
        let accounts = accountsInteractors
            .accounts(by: accountsIds)
            .map { $0.reduce(into: [String: DomainLayer.DTO.Account](), { list, account in
                    list[account.id] = account
                })
            }

        let txs = Observable.just(query.transactions)

        let blockHeight = blockRepositoryRemote.height()
//        let money = Money(0, 0)
//        return Observable.just(DomainLayer.DTO.SmartTransaction(id: "sdd", kind: .createdAlias("as"), timestamp: Date(), totalFee: Balance(currency: Balance.Currency(title: "sd", ticker: nil, money: money), money: money), height: 32, confirmationHeight: 233, sender: DomainLayer.DTO.SmartTransaction.Account(id: "as", contact: nil, isMyAccount: true)))
        return Observable.zip(assets,
                              accounts,
                              txs,
                              blockHeight)
            .map { arg -> [DomainLayer.DTO.SmartTransaction] in
                return arg.2
                    .map { $0.transaction(by: query.accountAddress, assets: arg.0, accounts: arg.1, totalHeight: arg.3) }
                    .compactMap { $0 }
            }
    }


    private func normalizeTransactions(_ transactions: [DomainLayer.DTO.AnyTransaction]) -> [DomainLayer.DTO.AnyTransaction] {

        var newTransactions: [DomainLayer.DTO.AnyTransaction] = .init()

        for tx in transactions {
            switch tx {

            case .transfer(let tx):
                let newTx = tx.mutate { $0.assetId = $0.assetId.normalizeAssetId }
                newTransactions.append(.transfer(newTx))
            case .massTransfer(let tx):
                let newTx = tx.mutate { $0.assetId = $0.assetId.normalizeAssetId }
                newTransactions.append(.massTransfer(newTx))
            case .exchange(let tx):

                let newTx = tx.mutate {
                    $0.order1 = $0.order1.mutate {
                        $0.assetPair.amountAsset = $0.assetPair.amountAsset.normalizeAssetId
                        $0.assetPair.priceAsset = $0.assetPair.priceAsset.normalizeAssetId
                    }
                    $0.order2 = $0.order2.mutate {
                        $0.assetPair.amountAsset = $0.assetPair.amountAsset.normalizeAssetId
                        $0.assetPair.priceAsset = $0.assetPair.priceAsset.normalizeAssetId
                    }
                }
                newTransactions.append(.exchange(newTx))
            default:
                newTransactions.append(tx)
            }
        }

        return newTransactions
    }
}



extension Array where Element == DomainLayer.DTO.AnyTransaction {

    var assetsIds: [String] {

        return reduce(into: [String](), { list, tx in
            let assetsIds = tx.assetsIds
            list.append(contentsOf: assetsIds)
        })
        .reduce(into: Set<String>(), { set, id in
            set.insert(id)
        })
        .flatMap { [$0] }
    }


    var accountsIds: [String] {

        return reduce(into: [String](), { list, tx in
            let accountsIds = tx.accountsIds
            list.append(contentsOf: accountsIds)
        })
        .reduce(into: Set<String>(), { set, id in
            set.insert(id)
        })
        .flatMap { [$0] }
    }
}

// MARK: Assisstants Mapper
fileprivate extension DomainLayer.DTO.AnyTransaction {

    var assetsIds: [String] {

        switch self {
        case .unrecognised:
            return [Environments.Constants.wavesAssetId]

        case .issue(let tx):
            return [tx.assetId]

        case .transfer(let tx):
            guard let assetId = tx.assetId else { return [] }
            return [assetId]

        case .reissue(let tx):
            return [tx.assetId]

        case .burn(let tx):
            return [tx.assetId]

        case .exchange(let tx):
            guard let amountAssetId = tx.order1.assetPair.amountAsset else { return [] }
            guard let priceAssetId = tx.order1.assetPair.priceAsset else { return [] }
            return [amountAssetId, priceAssetId]

        case .lease:
            return [Environments.Constants.wavesAssetId]

        case .leaseCancel:
            return [Environments.Constants.wavesAssetId]

        case .alias:
            return [Environments.Constants.wavesAssetId]

        case .massTransfer(let tx):
            guard let assetId = tx.assetId else { return [] }
            return [assetId]

        case .data:
            return [Environments.Constants.wavesAssetId]
        }
    }

    var accountsIds: [String] {

        switch self {
        case .unrecognised(let tx):
            return [tx.sender]

        case .issue(let tx):
            return [tx.sender]

        case .transfer(let tx):
            return [tx.sender, tx.recipient]

        case .reissue(let tx):
            return [tx.sender]

        case .burn(let tx):
            return [tx.sender]

        case .exchange(let tx):
            return [tx.sender, tx.order1.sender, tx.order2.sender]

        case .lease(let tx):
            return [tx.sender, tx.recipient]

        case .leaseCancel(let tx):
            return [tx.sender]

        case .alias(let tx):
            return [tx.sender]

        case .massTransfer(let tx):
            var list = tx.transfers.map { $0.recipient }
            list.append(tx.sender)
            return list

        case .data(let tx):
            return [tx.sender]
        }
    }
}
