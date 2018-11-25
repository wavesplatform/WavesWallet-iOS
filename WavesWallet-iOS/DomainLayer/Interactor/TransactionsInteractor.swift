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

enum TransactionsInteractorError: Error {
    case invalid
}

protocol TransactionsInteractorProtocol {
    func transactions(by accountAddress: String, specifications: TransactionsSpecifications) -> Observable<[DomainLayer.DTO.SmartTransaction]>
    func activeLeasingTransactions(by accountAddress: String, isNeedUpdate: Bool) -> Observable<[DomainLayer.DTO.SmartTransaction]>
    func send(by specifications: TransactionSenderSpecifications, wallet: DomainLayer.DTO.SignedWallet) -> Observable<DomainLayer.DTO.SmartTransaction>

    func transactionsSync(by accountAddress: String, specifications: TransactionsSpecifications) -> SyncObservable<[DomainLayer.DTO.SmartTransaction]>
    func activeLeasingTransactionsSync(by accountAddress: String) -> SyncObservable<[DomainLayer.DTO.SmartTransaction]>
}

fileprivate enum Constants {
    static let durationInseconds: Double = 15
    static let maxLimit: Int = 1000
    static let offset: Int = 50
}

fileprivate typealias IsHasTransactionsQuery =
    (accountAddress: String,
    ids: [String],
    transactions: [DomainLayer.DTO.AnyTransaction])

fileprivate typealias IsHasTransactionsResult = (isHasTransactions: Bool, transactions: [DomainLayer.DTO.AnyTransaction])

fileprivate typealias IfNeededLoadNextTransactionsQuery =
    (accountAddress: String,
    specifications: TransactionsSpecifications,
    currentOffset: Int,
    currentLimit: Int)

fileprivate typealias NextTransactionsQuery =
    (accountAddress: String,
    specifications: TransactionsSpecifications,
    currentOffset: Int,
    currentLimit: Int,
    isHasTransactions: Bool,
    transactions: [DomainLayer.DTO.AnyTransaction])

fileprivate typealias InitialTransactionsQuery =
    (accountAddress: String,
    specifications: TransactionsSpecifications,
    isHasTransactions: Bool)


fileprivate struct SmartTransactionsQuery {
    let accountAddress: String
    let transactions: [DomainLayer.DTO.AnyTransaction]
    let leaseTransactions: [DomainLayer.DTO.LeaseTransaction]?
    let senderSpecifications: TransactionSenderSpecifications?
}

fileprivate typealias AnyTransactionsQuery = (accountAddress: String, specifications: TransactionsSpecifications)

fileprivate typealias NextTransactionsSyncQuery =
    (accountAddress: String,
    specifications: TransactionsSpecifications,
    currentOffset: Int,
    currentLimit: Int,
    isHasTransactions: Bool,
    transactions: [DomainLayer.DTO.AnyTransaction],
    remoteError: Error?)


fileprivate typealias IsHasTransactionsSyncResult =
    (isHasTransactions: Bool,
    transactions: [DomainLayer.DTO.AnyTransaction],
    remoteError: Error?)

fileprivate typealias IsHasTransactionsSyncQuery =
    (accountAddress: String,
    ids: [String],
    transactions: [DomainLayer.DTO.AnyTransaction],
    remoteError: Error?)


fileprivate struct SmartTransactionsSyncQuery {
    let accountAddress: String
    let transactions: [DomainLayer.DTO.AnyTransaction]
    let leaseTransactions: [DomainLayer.DTO.LeaseTransaction]?
    let senderSpecifications: TransactionSenderSpecifications?
    let remoteError: Error?
}

private typealias RemoteResult = (txs: [DomainLayer.DTO.AnyTransaction], error: Error?)
private typealias RemoteActiveLeasingResult = (txs: [DomainLayer.DTO.LeaseTransaction], error: Error?)

fileprivate typealias AnyTransactionsSyncQuery = (accountAddress: String, specifications: TransactionsSpecifications, remoteError: Error?)

final class TransactionsInteractor: TransactionsInteractorProtocol {

    typealias AnyTransactionsObservable = Observable<[DomainLayer.DTO.AnyTransaction]>
    typealias SmartTransactionsObservable = Observable<[DomainLayer.DTO.SmartTransaction]>

    typealias SmartTransactionsSyncObservable = SyncObservable<[DomainLayer.DTO.SmartTransaction]>

    private var transactionsRepositoryLocal: TransactionsRepositoryProtocol = FactoryRepositories.instance.transactionsRepositoryLocal
    private var transactionsRepositoryRemote: TransactionsRepositoryProtocol = FactoryRepositories.instance.transactionsRepositoryRemote

    private var assetsInteractors: AssetsInteractorProtocol = FactoryInteractors.instance.assetsInteractor
    private var accountsInteractors: AccountsInteractorProtocol = FactoryInteractors.instance.accounts
    
    private var blockRepositoryRemote: BlockRepositoryProtocol = FactoryRepositories.instance.blockRemote

    func transactions(by accountAddress: String, specifications: TransactionsSpecifications) -> SmartTransactionsObservable {

        return transactionsRepositoryLocal
            .isHasTransactions(by: accountAddress, ignoreUnconfirmed: false)
            .map { InitialTransactionsQuery(accountAddress: accountAddress,
                                            specifications: specifications,
                                            isHasTransactions: $0) }
            .flatMap(weak: self, selector: { $0.initialTransaction })
    }

    func activeLeasingTransactions(by accountAddress: String, isNeedUpdate: Bool = false) -> SmartTransactionsObservable {

        return transactionsRepositoryRemote
            .activeLeasingTransactions(by: accountAddress)
            .map  {
                return RemoteActiveLeasingResult(txs: $0, error: nil)
            }
            .catchError({ (error) -> Observable<RemoteActiveLeasingResult> in
                return Observable.just(RemoteActiveLeasingResult(txs: [], error: error))
            })
            .flatMap({ [weak self] result -> Observable<RemoteActiveLeasingResult> in
                guard let owner = self else { return Observable.never() }

                let anyTxs = result.txs.map { DomainLayer.DTO.AnyTransaction.lease($0) }

                return owner
                    .saveTransactions(anyTxs, accountAddress: accountAddress)
                    .map { _ in result}
            })
            .flatMap({ [weak self] result -> SmartTransactionsObservable in
                guard let owner = self else { return Observable.never() }

                let anyTxs = result.txs.map { DomainLayer.DTO.AnyTransaction.lease($0) }

                return owner.smartTransactions(SmartTransactionsQuery(accountAddress: accountAddress,
                                                                      transactions: anyTxs,
                                                                      leaseTransactions: result.txs,
                                                                      senderSpecifications: nil))
            })
    }

    func send(by specifications: TransactionSenderSpecifications, wallet: DomainLayer.DTO.SignedWallet) -> Observable<DomainLayer.DTO.SmartTransaction> {

        return transactionsRepositoryRemote
                .send(by: specifications, wallet: wallet)                
                .flatMap({ [weak self] transaction -> Observable<DomainLayer.DTO.AnyTransaction> in
                    guard let owner = self else { return Observable.never() }
                    return owner.saveTransactions([transaction], accountAddress: wallet.address).map { _ in transaction }
                })
                .flatMap({ [weak self] tx -> Observable<DomainLayer.DTO.SmartTransaction> in
                    guard let owner = self else { return Observable.never() }
                    return owner.smartTransactionsSync(SmartTransactionsSyncQuery(accountAddress: wallet.address,
                                                                                  transactions: [tx],
                                                                                  leaseTransactions: nil,
                                                                                  senderSpecifications: specifications,
                                                                                  remoteError: nil))
                        .map({ (ts) -> [DomainLayer.DTO.SmartTransaction] in
                            return ts.resultIngoreError ?? []
                        })
                        .flatMap({ txs -> Observable<DomainLayer.DTO.SmartTransaction> in
                            guard let tx = txs.first else { return Observable.error(TransactionsInteractorError.invalid) }
                            return Observable.just(tx)
                        })
                }).sweetDebug("Send tx")
    }
}


extension TransactionsInteractor {
    func activeLeasingTransactionsSync(by accountAddress: String) -> SmartTransactionsSyncObservable {

        return transactionsRepositoryRemote
            .activeLeasingTransactions(by: accountAddress)
            .map  {
                return RemoteActiveLeasingResult(txs: $0, error: nil)
            }
            .catchError({ (error) -> Observable<RemoteActiveLeasingResult> in
                return Observable.just(RemoteActiveLeasingResult(txs: [], error: error))
            })
            .flatMap({ [weak self] result -> Observable<RemoteActiveLeasingResult> in
                guard let owner = self else { return Observable.never() }

                let anyTxs = result.txs.map { DomainLayer.DTO.AnyTransaction.lease($0) }

                return owner
                    .saveTransactions(anyTxs, accountAddress: accountAddress)
                    .map { _ in result}
            })
            .flatMap({ [weak self] result -> SmartTransactionsSyncObservable in
                guard let owner = self else { return Observable.never() }

                let anyTxs = result.txs.map { DomainLayer.DTO.AnyTransaction.lease($0) }

                return owner.smartTransactionsSync(SmartTransactionsSyncQuery(accountAddress: accountAddress,
                                                                              transactions: anyTxs,
                                                                              leaseTransactions: result.txs,
                                                                              senderSpecifications: nil,
                                                                              remoteError: result.error))
            })
    }

    func transactionsSync(by accountAddress: String, specifications: TransactionsSpecifications) -> SyncObservable<[DomainLayer.DTO.SmartTransaction]> {
        return transactionsRepositoryLocal
            .isHasTransactions(by: accountAddress, ignoreUnconfirmed: false)
            .map { InitialTransactionsQuery(accountAddress: accountAddress,
                                            specifications: specifications,
                                            isHasTransactions: $0) }
            .flatMap(weak: self, selector: { $0.initialLoadingTransactionSync })
            .catchError({ (error) -> Observable<Sync<[DomainLayer.DTO.SmartTransaction]>> in

                return Observable.just(.error(error))
            })
    }
}


// MARK: Main Logic sync download/save transactions

fileprivate extension TransactionsInteractor {

    private func initialLoadingTransactionSync(query: InitialTransactionsQuery) -> SmartTransactionsSyncObservable {

        if query.isHasTransactions {
            return ifNeededLoadNextTransactionsSync(IfNeededLoadNextTransactionsQuery(accountAddress: query.accountAddress,
                                                                                      specifications: query.specifications,
                                                                                      currentOffset: 0,
                                                                                      currentLimit: Constants.offset))
        } else {
            return firstTransactionsLoadingSync(query.accountAddress,
                                                specifications: query.specifications)
        }
    }

    private func firstTransactionsLoadingSync(_ accountAddress: String,
                                              specifications: TransactionsSpecifications) -> SmartTransactionsSyncObservable {

        return transactionsRepositoryRemote
            .transactions(by: accountAddress,
                          offset: 0,
                          limit: Constants.maxLimit)
            .map {
                return RemoteResult(txs: $0, error: nil)
            }
            .catchError({ (error) -> Observable<RemoteResult> in
                return Observable.just(RemoteResult(txs: [], error: error))
            })
            .flatMap({ [weak self] result -> Observable<RemoteResult> in
                guard let owner = self else { return Observable.never() }

                if result.txs.count == 0 {
                    return Observable.just(result)
                }
                return owner
                    .saveTransactions(result.txs, accountAddress: accountAddress)
                    .map { _ in result }
            })
            .map { result in AnyTransactionsSyncQuery(accountAddress: accountAddress, specifications: specifications, remoteError: result.error) }
            .flatMap(weak: self, selector: { $0.smartTransactionsFromAnyTransactionsSync })
            .catchError({ (error) -> SmartTransactionsSyncObservable in
                return SmartTransactionsSyncObservable.just(.error(error))
            })
    }


    private func ifNeededLoadNextTransactionsSync(_ query: IfNeededLoadNextTransactionsQuery) -> SmartTransactionsSyncObservable {

        return transactionsRepositoryRemote
            .transactions(by: query.accountAddress,
                          offset: query.currentOffset,
                          limit: query.currentLimit)
            .map {
                return RemoteResult(txs: $0, error: nil)
            }
            .catchError({ (error) -> Observable<RemoteResult> in
                return Observable.just(RemoteResult(txs: [], error: error))
            })
            .map {
                let ids = $0.txs.reduce(into: [String]()) { list, tx in
                    list.append(tx.id)
                }

                return IsHasTransactionsSyncQuery(accountAddress: query.accountAddress, ids: ids, transactions: $0.txs, remoteError: $0.error)
            }
            .flatMap(weak: self, selector: { $0.isHasTransactionsSync })
            .map { NextTransactionsSyncQuery(accountAddress: query.accountAddress,
                                             specifications: query.specifications,
                                             currentOffset: query.currentOffset,
                                             currentLimit: query.currentLimit,
                                             isHasTransactions: $0.isHasTransactions,
                                             transactions: $0.transactions,
                                             remoteError: $0.remoteError) }
            .flatMap(weak: self, selector: { $0.nextTransactionsSync })
            .catchError({ (error) -> Observable<Sync<[DomainLayer.DTO.SmartTransaction]>> in
                return Observable.just(Sync.error(error))
            })
    }

    private func nextTransactionsSync(_ query: NextTransactionsSyncQuery) -> SmartTransactionsSyncObservable {

        if query.isHasTransactions {
            return saveTransactions(query.transactions, accountAddress: query.accountAddress)
                .flatMap({ [weak self] _ -> SmartTransactionsSyncObservable in
                    guard let owner = self else { return Observable.never() }
                    return owner.smartTransactionsFromAnyTransactionsSync(AnyTransactionsSyncQuery(accountAddress: query.accountAddress,
                                                                                                   specifications: query.specifications,
                                                                                                   remoteError: query.remoteError))
                })
        } else {
            return saveTransactions(query.transactions, accountAddress: query.accountAddress)
                .map { _ in IfNeededLoadNextTransactionsQuery(accountAddress: query.accountAddress,
                                                              specifications: query.specifications,
                                                              currentOffset: query.currentOffset + query.currentLimit,
                                                              currentLimit: query.currentLimit) }
                .flatMap(weak: self, selector: { $0.ifNeededLoadNextTransactionsSync })
        }
    }

    private func anyTransactionsLocal(_ query: AnyTransactionsSyncQuery) -> AnyTransactionsObservable {

        let txs = transactionsRepositoryLocal
            .transactions(by: query.accountAddress, specifications: query.specifications)

        var newTxs = transactionsRepositoryLocal
            .newTransactions(by: query.accountAddress, specifications: query.specifications).skip(1)

        newTxs = Observable.merge(Observable.just([]), newTxs)

        return txs.flatMap { (txs) -> AnyTransactionsObservable in
            return newTxs.map({ lastTxs -> [DomainLayer.DTO.AnyTransaction] in
                var newTxs = lastTxs
                newTxs.append(contentsOf: txs)
                return newTxs
            })
        }
    }


    private func smartTransactionsFromAnyTransactionsSync(_ query: AnyTransactionsSyncQuery) -> SmartTransactionsSyncObservable {

        return anyTransactionsLocal(query)
            .map { SmartTransactionsSyncQuery(accountAddress: query.accountAddress,
                                              transactions: $0,
                                              leaseTransactions: nil,
                                              senderSpecifications: nil,
                                              remoteError: query.remoteError) }
            .flatMap(weak: self, selector: { $0.smartTransactionsSync })

    }

    private func smartTransactionsSync(_ query: SmartTransactionsSyncQuery) -> SmartTransactionsSyncObservable {
        return prepareTransactionsForSyncQuery(query)
            .flatMap({ [weak self] (query) -> SmartTransactionsSyncObservable in
                guard let owner = self else { return Observable.never() }
                return owner.mapToSmartTransactionsSync(query)
            })
    }

    private func prepareTransactionsForSyncQuery(_ query: SmartTransactionsSyncQuery) -> Observable<SmartTransactionsSyncQuery> {

        var activeLeasing: Observable<[DomainLayer.DTO.LeaseTransaction]>!

        if let leaseTransactions = query.leaseTransactions {
                activeLeasing = Observable.just(leaseTransactions)
        } else {

            let isNeedActiveLeasing = query.transactions.first(where: { (tx) -> Bool in
                return tx.isLease == true && tx.status == .completed
            }) != nil

            if isNeedActiveLeasing {
                //need handler error correct
                activeLeasing = transactionsRepositoryRemote
                    .activeLeasingTransactions(by: query.accountAddress)
                    .catchError({ error -> Observable<[DomainLayer.DTO.LeaseTransaction]> in
                        return Observable.just([])
                    })
            } else {
                activeLeasing = Observable.just([])
            }
        }

        return activeLeasing
            .map({ (txs) -> SmartTransactionsSyncQuery in
                return SmartTransactionsSyncQuery(accountAddress: query.accountAddress,
                                                  transactions: query.transactions,
                                                  leaseTransactions: txs,
                                                  senderSpecifications: query.senderSpecifications,
                                                  remoteError: query.remoteError)
            })
            .flatMap({ [weak self] (query) -> Observable<SmartTransactionsSyncQuery> in
                guard let owner = self else { return Observable.never() }
                return owner.prepareTransactionsForSenderSpecifications(query: query)
            })
    }

    private func prepareTransactionsForSenderSpecifications(query: SmartTransactionsSyncQuery) -> Observable<SmartTransactionsSyncQuery> {

        let isLeaseCancel = query
            .transactions.first { (tx) -> Bool in
                return tx.isLeaseCancel && tx.status == .unconfirmed
            } != nil

        guard isLeaseCancel else { return Observable.just(query) }

         //When sended lease cancel tx, node dont send responce lease tx
        return transactionsRepositoryLocal
            .transactions(by: query.accountAddress, specifications: TransactionsSpecifications(page: nil,
                                                                                               assets: [],
                                                                                               senders: [],
                                                                                               types: [TransactionType.lease]))
            .flatMap { (txs) -> Observable<[String: DomainLayer.DTO.AnyTransaction]> in
                let map = txs.reduce(into: [String: DomainLayer.DTO.AnyTransaction].init(), { (result, tx) in
                    result[tx.id] = tx
                })
                return Observable.just(map)
            }
            .flatMap({ txsMap -> Observable<[DomainLayer.DTO.AnyTransaction]> in
                let txs = query.transactions.map({ (anyTx) -> DomainLayer.DTO.AnyTransaction in

                    if case .leaseCancel(let leaseCancelTx) = anyTx, case .lease(let leaseTx)? = txsMap[leaseCancelTx.leaseId] {
                        var newLeaseCancelTx = leaseCancelTx
                        newLeaseCancelTx.lease = leaseTx
                        return DomainLayer.DTO.AnyTransaction.leaseCancel(newLeaseCancelTx)
                    } else {
                        return anyTx
                    }
                })

                return Observable.just(txs)
            })
            .map { txs in
                return SmartTransactionsSyncQuery(accountAddress: query.accountAddress,
                                                  transactions: txs,
                                                  leaseTransactions: query.leaseTransactions,
                                                  senderSpecifications: query.senderSpecifications,
                                                  remoteError: query.remoteError)
        }
    }


    private struct SmartTransactionSyncData {
        let assets: Sync<[DomainLayer.DTO.Asset]>
        let transaction: [DomainLayer.DTO.AnyTransaction]
        let block: Int64
        let accounts: Sync<[DomainLayer.DTO.Account]>
        let leaseTxs: [DomainLayer.DTO.LeaseTransaction]
    }

    private func mapToSmartTransactionsSync(_ query: SmartTransactionsSyncQuery) -> SmartTransactionsSyncObservable {

        guard query.transactions.count != 0 else {

            if let error = query.remoteError {
                return Observable.just(.local([], error: error))
            } else {
                return Observable.just(.remote([]))
            }
        }

        let accountAddress = query.accountAddress
        let assetsIds = query.transactions.assetsIds
        let accountsIds = query.transactions.accountsIds

        let assets = self.assetsInteractors.assetsSync(by: assetsIds,
                                                       accountAddress: accountAddress)

        let accounts = self.accountsInteractors.accountsSync(by: accountsIds,
                                                             accountAddress: accountAddress)

        //TODO: Caching
        let blockHeight = blockRepositoryRemote
            .height(accountAddress: query.accountAddress)
            .catchError { (_) -> Observable<Int64> in
                return Observable.just(0)
            }

        return Observable
            .zip(blockHeight, assets)
            .flatMapLatest { (args) -> Observable<SmartTransactionSyncData> in
                let blocks = args.0
                let assets = args.1
                let activeLeaseing = query.leaseTransactions ?? []

                return accounts
                    .map({ (accounts) -> SmartTransactionSyncData in

                        return SmartTransactionSyncData(assets: assets,
                                                        transaction: query.transactions,
                                                        block: blocks,
                                                        accounts: accounts,
                                                        leaseTxs: activeLeaseing)

                    })
            }
            .flatMap { [weak self] (data) -> SmartTransactionsSyncObservable in

                guard let owner = self else { return Observable.never() }

                guard let assets = data.assets.resultIngoreError else {
                    if let error = data.assets.error {
                        if let remoteError = query.remoteError {
                            return SmartTransactionsSyncObservable.just(.error(remoteError))
                        } else {
                            return SmartTransactionsSyncObservable.just(.error(error))
                        }
                    }
                    //TODO: it current line whith shit
                    return SmartTransactionsSyncObservable.just(.error(TransactionsInteractorError.invalid))
                }

                guard let accounts = data.accounts.resultIngoreError else {
                    if let error = data.accounts.error {
                        if let remoteError = query.remoteError {
                            return SmartTransactionsSyncObservable.just(.error(remoteError))
                        } else {
                            return SmartTransactionsSyncObservable.just(.error(error))
                        }
                    }

                    return SmartTransactionsSyncObservable.just(.error(TransactionsInteractorError.invalid))
                }

                let assetsMap = assets.reduce(into: [String: DomainLayer.DTO.Asset](), { $0[$1.id] = $1 })
                let accountsMap = accounts.reduce(into: [String: DomainLayer.DTO.Account](), { $0[$1.address] = $1 })
                let leaseTxsMap = data.leaseTxs.reduce(into: [String: DomainLayer.DTO.LeaseTransaction](), { $0[$1.id] = $1 })

                let txs = owner.mapToSmartTransactions(by: accountAddress,
                                                       txs: data.transaction,
                                                       assets: assetsMap,
                                                       accounts: accountsMap,
                                                       block: data.block,
                                                       leaseTxs: leaseTxsMap)

                if let error = query.remoteError {
                    return .just(.local(txs, error: error))
                } else {
                    return .just(.remote(txs))
                }
        }
    }

    private func mapToSmartTransactions(by accountAddress: String,
                                        txs: [DomainLayer.DTO.AnyTransaction],
                                        assets: [String: DomainLayer.DTO.Asset],
                                        accounts: [String: DomainLayer.DTO.Account],
                                        block: Int64,
                                        leaseTxs: [String: DomainLayer.DTO.LeaseTransaction]) -> [DomainLayer.DTO.SmartTransaction]
    {
        return txs.map({ (tx) -> DomainLayer.DTO.SmartTransaction? in
            return tx.transaction(by: accountAddress,
                                  assets: assets,
                                  accounts: accounts,
                                  totalHeight: block,
                                  leaseTransactions: leaseTxs,
                                  mapTxs: [:])
        })
        .compactMap { $0 }
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
            .flatMap({ [weak self] transactions -> Observable<Bool> in
                guard let owner = self else { return Observable.never() }
                return owner.saveTransactions(transactions, accountAddress: accountAddress)
            })
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

                return IsHasTransactionsQuery(accountAddress: query.accountAddress, ids: ids, transactions: $0)
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
            return saveTransactions(query.transactions, accountAddress: query.accountAddress)
                .flatMap({ [weak self] _ -> SmartTransactionsObservable in
                    guard let owner = self else { return Observable.never() }
                    return owner.smartTransactionsFromAnyTransactions(AnyTransactionsQuery(accountAddress: query.accountAddress,
                                                                                           specifications: query.specifications))
                })
        } else {
            return saveTransactions(query.transactions, accountAddress: query.accountAddress)
                .map { _ in IfNeededLoadNextTransactionsQuery(accountAddress: query.accountAddress,
                                                         specifications: query.specifications,
                                                         currentOffset: query.currentOffset + query.currentLimit,
                                                         currentLimit: query.currentLimit) }
                .flatMap(weak: self, selector: { $0.ifNeededLoadNextTransactions })
        }
    }

    private typealias SmartTransactionData = (
        [String : DomainLayer.DTO.Asset],
        [DomainLayer.DTO.AnyTransaction],
        Int64,
        [String : DomainLayer.DTO.Account],
        [String : DomainLayer.DTO.LeaseTransaction],
        [String : DomainLayer.DTO.AnyTransaction]
    )

    private func prepareTransactionsForQuery(_ query: SmartTransactionsQuery) -> Observable<SmartTransactionsQuery> {

        //When sended lease cancel tx, node dont send responce lease tx
        if let specification = query.senderSpecifications, case .cancelLease = specification {

            return transactionsRepositoryLocal
                .transactions(by: query.accountAddress, specifications: TransactionsSpecifications(page: nil,
                                                                                                   assets: [],
                                                                                                   senders: [],
                                                                                                   types: [TransactionType.lease]))
                .flatMap { (txs) -> Observable<[String: DomainLayer.DTO.AnyTransaction]> in
                    let map = txs.reduce(into: [String: DomainLayer.DTO.AnyTransaction].init(), { (result, tx) in
                        result[tx.id] = tx
                    })
                    return Observable.just(map)
                }
                .flatMap({ txsMap -> Observable<[DomainLayer.DTO.AnyTransaction]> in
                    let txs = query.transactions.map({ (anyTx) -> DomainLayer.DTO.AnyTransaction in

                        if case .leaseCancel(let leaseCancelTx) = anyTx, case .lease(let leaseTx)? = txsMap[leaseCancelTx.leaseId] {
                            var newLeaseCancelTx = leaseCancelTx
                            newLeaseCancelTx.lease = leaseTx
                            return DomainLayer.DTO.AnyTransaction.leaseCancel(newLeaseCancelTx)
                        } else {
                            return anyTx
                        }
                    })

                    return Observable.just(txs)
                })
                .map { txs in
                    return SmartTransactionsQuery(accountAddress: query.accountAddress,
                                                  transactions: txs,
                                                  leaseTransactions: query.leaseTransactions,
                                                  senderSpecifications: query.senderSpecifications)
            }
        }

        return Observable.just(query)
    }

    private func smartTransactionsFromAnyTransactions(_ query: AnyTransactionsQuery) -> SmartTransactionsObservable {

        return anyTransactionsLocal(query)
            .map { SmartTransactionsQuery(accountAddress: query.accountAddress, transactions: $0, leaseTransactions: nil, senderSpecifications: nil) }
            .flatMap(weak: self, selector: { $0.smartTransactions })
    }

    private func smartTransactions(_ query: SmartTransactionsQuery) -> SmartTransactionsObservable {
        return prepareTransactionsForQuery(query)
            .flatMap({ [weak self] (query) -> SmartTransactionsObservable in
                guard let owner = self else { return Observable.never() }
                return owner.mapToSmartTransactions(query)
            })
    }

    private func mapToSmartTransactions(_ query: SmartTransactionsQuery) -> SmartTransactionsObservable {

        guard query.transactions.count != 0 else { return Observable.just([]) }
        let assetsIds = query.transactions.assetsIds
        let accountsIds = query.transactions.accountsIds

        let assets = self.assets(by: assetsIds, accountAddress: query.accountAddress)
        let accounts = self.accounts(by: accountsIds, accountAddress: query.accountAddress)

        var activeLeasing: Observable<[DomainLayer.DTO.LeaseTransaction]>!

        if let leaseTransactions = query.leaseTransactions {
            activeLeasing = Observable.just(leaseTransactions)
        } else {
            //it is code for avoid query when lease thx not found
            let isNeedActiveLeasing = query.transactions.first(where: { (tx) -> Bool in
                return tx.isLease == true && tx.status == .completed
            }) != nil

            if isNeedActiveLeasing {
                activeLeasing = transactionsRepositoryRemote.activeLeasingTransactions(by: query.accountAddress)
            } else {
                activeLeasing = Observable.just([])
            }
        }

        let activeLeasingMap = activeLeasing!.flatMap { (txs) -> Observable<[String: DomainLayer.DTO.LeaseTransaction]> in
            let map = txs.reduce(into: [String: DomainLayer.DTO.LeaseTransaction].init(), { (result, tx) in
                result[tx.id] = tx
            })
            return Observable.just(map)
        }

        let txs = Observable.just(query.transactions)
        let blockHeight = blockRepositoryRemote.height(accountAddress: query.accountAddress)

        let txsMap: Observable<[String: DomainLayer.DTO.AnyTransaction]> = Observable.just([String: DomainLayer.DTO.AnyTransaction]())

        return Observable.zip(assets, txs, blockHeight, activeLeasingMap, txsMap)
            .flatMap({ (arg) -> Observable<SmartTransactionData> in

                // Acoounts few emitted
                return accounts.map { (arg.0, arg.1, arg.2, $0, arg.3, arg.4) }
            })
            .map { arg -> [DomainLayer.DTO.SmartTransaction] in

                return arg.1
                    .map { $0.transaction(by: query.accountAddress,
                                          assets: arg.0,
                                          accounts: arg.3,
                                          totalHeight: arg.2,
                                          leaseTransactions: arg.4,
                                          mapTxs: arg.5) }
                    .compactMap { $0 }
        }
    }
}

// MARK: Assistants method

fileprivate extension TransactionsInteractor {

    private func isHasTransactions(_ query: IsHasTransactionsQuery) -> Observable<IsHasTransactionsResult> {

        return transactionsRepositoryLocal
            .isHasTransactions(by: query.ids, accountAddress: query.accountAddress, ignoreUnconfirmed: true)
            .map { IsHasTransactionsResult(isHasTransactions: $0,
                                           transactions: query.transactions)}
    }

    private func isHasTransactionsSync(_ query: IsHasTransactionsSyncQuery) -> Observable<IsHasTransactionsSyncResult> {

        return transactionsRepositoryLocal
            .isHasTransactions(by: query.ids, accountAddress: query.accountAddress, ignoreUnconfirmed: true)
            .map { IsHasTransactionsSyncResult(isHasTransactions: $0,
                                               transactions: query.transactions,
                                               remoteError: query.remoteError)}
    }

    private func saveTransactions(_ transactions: [DomainLayer.DTO.AnyTransaction], accountAddress: String) -> Observable<Bool> {

        return transactionsRepositoryLocal
            .saveTransactions(transactions, accountAddress: accountAddress)
    }

    private func anyTransactionsLocal(_ query: AnyTransactionsQuery) -> AnyTransactionsObservable {

        let txs = transactionsRepositoryLocal
            .transactions(by: query.accountAddress, specifications: query.specifications)

        var newTxs = transactionsRepositoryLocal
            .newTransactions(by: query.accountAddress, specifications: query.specifications).skip(1)

        newTxs = Observable.merge(Observable.just([]), newTxs)

        return txs.flatMap { (txs) -> AnyTransactionsObservable in
            return newTxs.map({ lastTxs -> [DomainLayer.DTO.AnyTransaction] in
                var newTxs = lastTxs
                newTxs.append(contentsOf: txs)
                return newTxs
            })
        }
    }

    private func assets(by ids: [String], accountAddress: String) -> Observable<[String: DomainLayer.DTO.Asset]> {
        let assets = assetsInteractors
            .assets(by: ids,
                    accountAddress: accountAddress,
                    isNeedUpdated: false)
            .map { $0.reduce(into: [String: DomainLayer.DTO.Asset](), { list, asset in
                list[asset.id] = asset
            })
        }
        return assets
    }

    private func accounts(by ids: [String], accountAddress: String) -> Observable<[String: DomainLayer.DTO.Account]> {
        let accounts = accountsInteractors
            .accounts(by: ids, accountAddress: accountAddress)
            .map { $0.reduce(into: [String: DomainLayer.DTO.Account](), { list, account in
                list[account.address] = account
            })
        }
        return accounts
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
            return [GlobalConstants.wavesAssetId]

        case .issue(let tx):
            return [tx.assetId]

        case .transfer(let tx):
            let assetId = tx.assetId
            return [assetId, GlobalConstants.wavesAssetId]

        case .reissue(let tx):
            return [tx.assetId]

        case .burn(let tx):
            return [tx.assetId, GlobalConstants.wavesAssetId]

        case .exchange(let tx):
            return [tx.order1.assetPair.amountAsset, tx.order1.assetPair.priceAsset]

        case .lease:
            return [GlobalConstants.wavesAssetId]

        case .leaseCancel:
            return [GlobalConstants.wavesAssetId]

        case .alias:
            return [GlobalConstants.wavesAssetId]

        case .massTransfer(let tx):
            return [tx.assetId, GlobalConstants.wavesAssetId]

        case .data:
            return [GlobalConstants.wavesAssetId]
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
            var accountsIds: [String] = [String]()
            accountsIds.append(tx.sender)
            if let lease = tx.lease {
                accountsIds.append(lease.sender)
                accountsIds.append(lease.recipient)
            }

            return accountsIds

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

private extension TransactionSenderSpecifications {

    var isCancelLease: Bool {
        switch self {
        case .cancelLease:
            return true

        default:
            return false
        }
    }
}
