//
//  TransactionsUseCase.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 04.09.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Extensions
import Foundation
import RxSwift
import WavesSDK
import WavesSDKExtensions

private enum Constants {
    static let durationInseconds: Double = 15
    static let maxLimit: Int = 1000
    static let offset: Int = 50
    static let rateSmart: Int64 = 400_000
}

private typealias IfNeededLoadNextTransactionsQuery =
    (address: Address,
     specifications: TransactionsSpecifications,
     currentOffset: Int,
     currentLimit: Int)

private typealias InitialTransactionsQuery =
    (address: Address,
     specifications: TransactionsSpecifications,
     isHasTransactions: Bool)

private typealias AnyTransactionsQuery = (accountAddress: String, specifications: TransactionsSpecifications)

private typealias NextTransactionsSyncQuery =
    (address: Address,
     specifications: TransactionsSpecifications,
     currentOffset: Int,
     currentLimit: Int,
     isHasTransactions: Bool,
     transactions: [AnyTransaction],
     remoteError: Error?)

private typealias IsHasTransactionsSyncResult =
    (isHasTransactions: Bool,
     transactions: [AnyTransaction],
     remoteError: Error?)

private typealias IsHasTransactionsSyncQuery =
    (address: Address,
     ids: [String],
     transactions: [AnyTransaction],
     remoteError: Error?)

private struct SmartTransactionsSyncQuery {
    let address: Address
    let transactions: [AnyTransaction]
    let leaseTransactions: [LeaseTransaction]?
    let senderSpecifications: TransactionSenderSpecifications?
    let remoteError: Error?
}

private struct SmartTransactionSyncData {
    let assets: Sync<[Asset]>
    let transaction: [AnyTransaction]
    let block: Int64
    let accounts: Sync<[Address]>
    let leaseTxs: [LeaseTransaction]
    let isEnableSpamFilter: Bool
}

private typealias RemoteResult = (txs: [AnyTransaction], error: Error?)
private typealias RemoteActiveLeasingResult = (txs: [LeaseTransaction], error: Error?)

private typealias AnyTransactionsObservable = Observable<[AnyTransaction]>
private typealias AnyTransactionsSyncQuery =
    (address: Address, specifications: TransactionsSpecifications, remoteError: Error?)

final class TransactionsUseCase: TransactionsUseCaseProtocol {
    typealias SmartTransactionsSyncObservable = SyncObservable<[SmartTransaction]>

    private let transactionsDAO: TransactionsDAO
    private let transactionsRepository: TransactionsRepositoryProtocol

    private let assetsRepository: AssetsRepositoryProtocol

    private let addressInteractors: AddressInteractorProtocol

    private let addressRepository: AddressRepositoryProtocol

    private let blockRepositoryRemote: BlockRepositoryProtocol

    private let accountSettingsRepository: AccountSettingsRepositoryProtocol

    private let orderBookRepository: DexOrderBookRepositoryProtocol

    private let serverEnvironmentUseCase: ServerEnvironmentRepository

    init(transactionsDAO: TransactionsDAO,
         transactionsRepositoryRemote: TransactionsRepositoryProtocol,
         addressInteractors: AddressInteractorProtocol,
         addressRepository: AddressRepositoryProtocol,
         assetsRepository: AssetsRepositoryProtocol,
         blockRepositoryRemote: BlockRepositoryProtocol,
         accountSettingsRepository: AccountSettingsRepositoryProtocol,
         orderBookRepository: DexOrderBookRepositoryProtocol,
         serverEnvironmentUseCase: ServerEnvironmentRepository) {
        self.transactionsDAO = transactionsDAO
        transactionsRepository = transactionsRepositoryRemote
        self.assetsRepository = assetsRepository
        self.addressInteractors = addressInteractors
        self.addressRepository = addressRepository
        self.blockRepositoryRemote = blockRepositoryRemote
        self.accountSettingsRepository = accountSettingsRepository
        self.orderBookRepository = orderBookRepository
        self.serverEnvironmentUseCase = serverEnvironmentUseCase
    }

    func calculateFee(by transactionSpecs: DomainLayer.Query.TransactionSpecificationType,
                      accountAddress: String) -> Observable<Money> {
        let serverEnvironment = serverEnvironmentUseCase
            .serverEnvironment()

        let isSmartAccount = serverEnvironment.flatMap { [weak self] serverEnvironment -> Observable<Bool> in

            guard let self = self else { return Observable.never() }

            return self.addressRepository.isSmartAddress(serverEnvironment: serverEnvironment,
                                                         accountAddress: accountAddress)
        }

        // TODO: Dont User List
        let wavesAsset = assetsRepository.assets(ids: [WavesSDKConstants.wavesAssetId],
                                                 accountAddress: accountAddress)
            .map { $0.compactMap { $0 } }
            .flatMap { assets -> Observable<Asset> in

                if let result = assets.first {
                    return Observable.just(result)
                } else {
                    return Observable.error(TransactionsUseCaseError.invalid)
                }
            }

        let isSmartAssets = transactionSpecs
            .assetIds
            .reduce(into: [Observable<(String, Bool)>]()) { result, assetId in

                let isSmartAsset = self.assetsRepository.isSmartAsset(assetId: assetId, accountAddress: accountAddress)
                    .map { isSmartAsset -> (String, Bool) in
                        (assetId, isSmartAsset)
                    }

                result.append(isSmartAsset)
            }

        let isSmartAssetsObservable = Observable.combineLatest(isSmartAssets).ifEmpty(default: [])

        let rules = transactionsRepository.feeRules()

        return Observable.zip(isSmartAccount, wavesAsset, rules, isSmartAssetsObservable)
            .flatMap { [weak self] isSmartAccount, wavesAsset, rules, isSmartAssets -> Observable<Money> in

                guard let self = self else { return Observable.never() }

                let mapSmartAssets = isSmartAssets.reduce(into: [String: Bool]()) { result, isSmartAsset in
                    result[isSmartAsset.0] = isSmartAsset.1
                }

                let money = self.calculateFee(isSmartAddress: isSmartAccount,
                                              wavesAsset: wavesAsset,
                                              rules: rules,
                                              isSmartAssets: mapSmartAssets,
                                              type: transactionSpecs)

                return Observable.just(money)
            }
            .catchError { error -> Observable<Money> in

                switch error {
                case let error as NetworkError:
                    switch error {
                    case .notFound:
                        return Observable.error(TransactionsUseCaseError.commissionReceiving)
                    default:
                        return Observable.error(error)
                    }
                default:
                    return Observable.error(TransactionsUseCaseError.commissionReceiving)
                }
            }
    }

    func send(by specifications: TransactionSenderSpecifications, wallet: SignedWallet) -> Observable<SmartTransaction> {
        let serverEnviroment = serverEnvironmentUseCase.serverEnvironment()

        return serverEnviroment
            .flatMap { [weak self] serverEnvironment -> Observable<AnyTransaction> in

                guard let self = self else { return Observable.never() }

                return self.transactionsRepository
                    .send(serverEnvironment: serverEnvironment,
                          specifications: specifications,
                          wallet: wallet)
            }
            .flatMap { [weak self] transaction -> Observable<AnyTransaction> in
                guard let self = self else { return Observable.never() }
                return self.saveTransactions([transaction], accountAddress: wallet.address).map { _ in transaction }
            }
            .flatMap { [weak self] tx -> Observable<SmartTransaction> in
                guard let self = self else { return Observable.never() }

                let address = Address(address: wallet.address,
                                      contact: nil,
                                      isMyAccount: true,
                                      aliases: [])

                return self.smartTransactionsSync(SmartTransactionsSyncQuery(address: address,
                                                                             transactions: [tx],
                                                                             leaseTransactions: nil,
                                                                             senderSpecifications: specifications,
                                                                             remoteError: nil))
                    .map { ts -> [SmartTransaction] in
                        ts.resultIngoreError ?? []
                    }
                    .flatMap { txs -> Observable<SmartTransaction> in
                        guard let tx = txs.first else { return Observable.error(TransactionsUseCaseError.invalid) }
                        return Observable.just(tx)
                    }
            }
    }

    func activeLeasingTransactionsSync(by accountAddress: String) -> SmartTransactionsSyncObservable {
        let serverEnviroment = serverEnvironmentUseCase.serverEnvironment()

        return serverEnviroment.flatMap { [weak self] serverEnviroment -> Observable<[LeaseTransaction]> in

            guard let self = self else { return Observable.never() }

            return self.transactionsRepository
                .activeLeasingTransactions(serverEnvironment: serverEnviroment,
                                           accountAddress: accountAddress)
        }
        .map {
            return RemoteActiveLeasingResult(txs: $0, error: nil)
        }
        .catchError { error -> Observable<RemoteActiveLeasingResult> in
            Observable.just(RemoteActiveLeasingResult(txs: [], error: error))
        }
        .flatMap { [weak self] result -> Observable<RemoteActiveLeasingResult> in
            guard let self = self else { return Observable.never() }

            let anyTxs = result.txs.map { AnyTransaction.lease($0) }

            return self
                .saveTransactions(anyTxs, accountAddress: accountAddress)
                .map { _ in result }
        }
        .flatMap { [weak self] result -> SmartTransactionsSyncObservable in
            guard let self = self else { return Observable.never() }

            let anyTxs = result.txs.map { AnyTransaction.lease($0) }

            return self
                .smartTransactionsSync(SmartTransactionsSyncQuery(address: Address(address: accountAddress,
                                                                                   contact: nil,
                                                                                   isMyAccount: true,
                                                                                   aliases: []),
                                                                  transactions: anyTxs,
                                                                  leaseTransactions: result.txs,
                                                                  senderSpecifications: nil,
                                                                  remoteError: result.error))
        }
    }

    private struct AnyTransactionsAndAddress {
        let address: Address
        let transactions: [AnyTransaction]
    }

    // это что и зачем? (такие названия не приемлемы, они вводят в заблуждение)
    private struct isHasTransactionsAndAddress {
        let address: Address
        let isHasTransactions: Bool
    }

    func transactionsSync(by accountAddress: String,
                          specifications: TransactionsSpecifications) -> SyncObservable<[SmartTransaction]> {
        addressInteractors
            .addressSync(by: [accountAddress], myAddress: accountAddress)
            .flatMap { [weak self] sync -> Observable<AnyTransactionsAndAddress> in

                guard let self = self else { return Observable.never() }

                guard let address = sync.resultIngoreError?.first else {
                    if let error = sync.error {
                        return Observable.error(error)
                    } else {
                        return Observable.error(TransactionsUseCaseError.invalid)
                    }
                }

                return self
                    .transactionsDAO
                    .transactions(by: address,
                                  specifications: TransactionsSpecifications(page: .init(offset: 0, limit: Constants.maxLimit),
                                                                             assets: [],
                                                                             senders: [],
                                                                             types: TransactionType.all))
                    .map { AnyTransactionsAndAddress(address: address,
                                                     transactions: $0)
                    }
            }
            .map { model -> isHasTransactionsAndAddress in
                let isHasTransactions = model.transactions.count >= Constants.maxLimit
                return isHasTransactionsAndAddress(address: model.address,
                                                   isHasTransactions: isHasTransactions)
            }
            .map { InitialTransactionsQuery(address: $0.address,
                                            specifications: specifications,
                                            isHasTransactions: $0.isHasTransactions) }
            .flatMap(weak: self, selector: { $0.initialLoadingTransactionSync })
            .catchError { error -> Observable<Sync<[SmartTransaction]>> in

                Observable.just(.error(error))
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global(qos: .userInteractive)))
            .share()
    }
}

// MARK: - - Main Logic sync download/save transactions

private extension TransactionsUseCase {
    private func initialLoadingTransactionSync(query: InitialTransactionsQuery) -> SmartTransactionsSyncObservable {
        if query.isHasTransactions {
            return ifNeededLoadNextTransactionsSync(IfNeededLoadNextTransactionsQuery(address: query.address,
                                                                                      specifications: query.specifications,
                                                                                      currentOffset: 0,
                                                                                      currentLimit: Constants.offset))
        } else {
            return firstTransactionsLoadingSync(query.address,
                                                specifications: query.specifications)
        }
    }

    private func firstTransactionsLoadingSync(_ address: Address,
                                              specifications: TransactionsSpecifications) -> SmartTransactionsSyncObservable {
        let serverEnviroment = serverEnvironmentUseCase.serverEnvironment()

        return serverEnviroment
            .flatMap { [weak self] serverEnviroment -> Observable<[AnyTransaction]> in

                guard let self = self else { return Observable.never() }

                return self.transactionsRepository
                    .transactions(serverEnvironment: serverEnviroment,
                                  address: address,
                                  offset: 0,
                                  limit: Constants.maxLimit)
            }
            .map { RemoteResult(txs: $0, error: nil) }
            .catchError { error -> Observable<RemoteResult> in Observable.just(RemoteResult(txs: [], error: error)) }
            .flatMap { [weak self] result -> Observable<RemoteResult> in
                guard let self = self else { return Observable.never() }
                if result.txs.isEmpty {
                    return Observable.just(result)
                }
                return self
                    .saveTransactions(result.txs, accountAddress: address.address)
                    .map { _ in result }
            }
            .map { result in
                AnyTransactionsSyncQuery(address: address, specifications: specifications, remoteError: result.error)
            }
            .flatMap(weak: self, selector: { $0.smartTransactionsFromAnyTransactionsSync })
            .catchError { error -> SmartTransactionsSyncObservable in SmartTransactionsSyncObservable.just(.error(error)) }
    }

    private func ifNeededLoadNextTransactionsSync(_ query: IfNeededLoadNextTransactionsQuery) -> SmartTransactionsSyncObservable {
        let serverEnviroment = serverEnvironmentUseCase.serverEnvironment()

        return serverEnviroment
            .flatMap { [weak self] serverEnvironment -> Observable<[AnyTransaction]> in

                guard let self = self else { return Observable.never() }

                return self.transactionsRepository
                    .transactions(serverEnvironment: serverEnvironment,
                                  address: query.address,
                                  offset: query.currentOffset,
                                  limit: query.currentLimit)
            }
            .map { RemoteResult(txs: $0, error: nil) }
            .catchError { error -> Observable<RemoteResult> in Observable.just(RemoteResult(txs: [], error: error)) }
            .map {
                let ids = $0.txs.reduce(into: [String]()) { list, tx in
                    list.append(tx.id)
                }

                return IsHasTransactionsSyncQuery(address: query.address, ids: ids, transactions: $0.txs, remoteError: $0.error)
            }
            .flatMap(weak: self, selector: { $0.isHasTransactionsSync })
            .map { NextTransactionsSyncQuery(address: query.address,
                                             specifications: query.specifications,
                                             currentOffset: query.currentOffset,
                                             currentLimit: query.currentLimit,
                                             isHasTransactions: $0.isHasTransactions,
                                             transactions: $0.transactions,
                                             remoteError: $0.remoteError)
            }
            .flatMap(weak: self, selector: { $0.nextTransactionsSync })
            .catchError { error -> Observable<Sync<[SmartTransaction]>> in Observable.just(Sync.error(error)) }
    }

    private func nextTransactionsSync(_ query: NextTransactionsSyncQuery) -> SmartTransactionsSyncObservable {
        if query.isHasTransactions {
            return saveTransactions(query.transactions, accountAddress: query.address.address)
                .flatMap { [weak self] _ -> SmartTransactionsSyncObservable in
                    guard let self = self else { return Observable.never() }
                    return self.smartTransactionsFromAnyTransactionsSync(AnyTransactionsSyncQuery(address: query.address,
                                                                                                  specifications: query
                                                                                                      .specifications,
                                                                                                  remoteError: query.remoteError))
                }
        } else {
            return saveTransactions(query.transactions, accountAddress: query.address.address)
                .map { _ in IfNeededLoadNextTransactionsQuery(address: query.address,
                                                              specifications: query.specifications,
                                                              currentOffset: query.currentOffset + query.currentLimit,
                                                              currentLimit: query.currentLimit)
                }
                .flatMap(weak: self, selector: { $0.ifNeededLoadNextTransactionsSync })
        }
    }

    private func anyTransactionsLocal(_ query: AnyTransactionsSyncQuery) -> AnyTransactionsObservable {
        let txs = transactionsDAO
            .transactions(by: query.address, specifications: query.specifications)

        var newTxs = transactionsDAO
            .newTransactions(by: query.address, specifications: query.specifications).skip(1)

        newTxs = Observable.merge(Observable.just([]), newTxs)

        return Observable.merge(txs, newTxs.flatMap { newTxs -> AnyTransactionsObservable in

            if newTxs.isEmpty {
                return Observable.empty()
            } else {
                return txs
            }
        })
    }

    private func smartTransactionsFromAnyTransactionsSync(_ query: AnyTransactionsSyncQuery) -> SmartTransactionsSyncObservable {
        anyTransactionsLocal(query)
            .map { SmartTransactionsSyncQuery(address: query.address,
                                              transactions: $0,
                                              leaseTransactions: nil,
                                              senderSpecifications: nil,
                                              remoteError: query.remoteError)
            }
            .flatMap(weak: self, selector: { $0.smartTransactionsSync })
    }

    private func smartTransactionsSync(_ query: SmartTransactionsSyncQuery) -> SmartTransactionsSyncObservable {
        prepareTransactionsForSyncQuery(query)
            .flatMap { [weak self] query -> SmartTransactionsSyncObservable in
                guard let self = self else { return Observable.never() }
                return self.mapToSmartTransactionsSync(query)
            }
    }

    private func prepareTransactionsForSyncQuery(_ query: SmartTransactionsSyncQuery) -> Observable<SmartTransactionsSyncQuery> {
        var activeLeasing: Observable<[LeaseTransaction]>!

        if let leaseTransactions = query.leaseTransactions {
            activeLeasing = Observable.just(leaseTransactions)
        } else {
            let isNeedActiveLeasing = query.transactions.first(where: { (tx) -> Bool in
                tx.isLease == true && tx.status == .completed
            }) != nil

            if isNeedActiveLeasing {
                let serverEnviroment = serverEnvironmentUseCase.serverEnvironment()

                activeLeasing = serverEnviroment
                    .flatMap { [weak self] serverEnvironment -> Observable<[LeaseTransaction]> in

                        guard let self = self else { return Observable.never() }

                        return self.transactionsRepository
                            .activeLeasingTransactions(serverEnvironment: serverEnvironment,
                                                       accountAddress: query.address.address)
                    }
                    .catchError { _ -> Observable<[LeaseTransaction]> in
                        Observable.just([])
                    }
            } else {
                activeLeasing = Observable.just([])
            }
        }

        return activeLeasing
            .map { txs -> SmartTransactionsSyncQuery in
                SmartTransactionsSyncQuery(address: query.address,
                                           transactions: query.transactions,
                                           leaseTransactions: txs,
                                           senderSpecifications: query.senderSpecifications,
                                           remoteError: query.remoteError)
            }
            .flatMap { [weak self] query -> Observable<SmartTransactionsSyncQuery> in
                guard let self = self else { return Observable.never() }
                return self.prepareTransactionsForSenderSpecifications(query: query)
            }
    }

    private func prepareTransactionsForSenderSpecifications(query: SmartTransactionsSyncQuery)
        -> Observable<SmartTransactionsSyncQuery> {
        let isLeaseCancel = query
            .transactions.first { tx -> Bool in
                tx.isLeaseCancel && tx.status == .unconfirmed
            } != nil

        guard isLeaseCancel else { return Observable.just(query) }

        // When sended lease cancel tx, node dont send responce lease tx
        return transactionsDAO
            .transactions(by: query.address, specifications: TransactionsSpecifications(page: nil,
                                                                                        assets: [],
                                                                                        senders: [],
                                                                                        types: [TransactionType.createLease]))
            .flatMap { txs -> Observable<[String: AnyTransaction]> in
                let map = txs.reduce(into: [String: AnyTransaction].init()) { result, tx in
                    result[tx.id] = tx
                }
                return Observable.just(map)
            }
            .flatMap { txsMap -> Observable<[AnyTransaction]> in
                let txs = query.transactions.map { anyTx -> AnyTransaction in

                    if case let .leaseCancel(leaseCancelTx) = anyTx, case let .lease(leaseTx)? = txsMap[leaseCancelTx.leaseId] {
                        var newLeaseCancelTx = leaseCancelTx
                        newLeaseCancelTx.lease = leaseTx
                        return AnyTransaction.leaseCancel(newLeaseCancelTx)
                    } else {
                        return anyTx
                    }
                }

                return Observable.just(txs)
            }
            .map { txs in
                SmartTransactionsSyncQuery(address: query.address,
                                           transactions: txs,
                                           leaseTransactions: query.leaseTransactions,
                                           senderSpecifications: query.senderSpecifications,
                                           remoteError: query.remoteError)
            }
    }

    private func mapToSmartTransactionsSync(_ query: SmartTransactionsSyncQuery) -> SmartTransactionsSyncObservable {
        guard !query.transactions.isEmpty else {
            if let error = query.remoteError {
                return Observable.just(.local([], error: error))
            } else {
                return Observable.just(.remote([]))
            }
        }

        let accountAddress = query.address.address
        let assetsIds = query.transactions.assetsIds

        var accountsIds = query.transactions.accountsIds
        accountsIds.insert(accountAddress)

        let listAccountsIds = accountsIds.flatMap { [$0] }

        let assets = assetsRepository.assets(ids: assetsIds,
                                             accountAddress: accountAddress)
            .take(1)
            .map { $0.compactMap { $0 } }

        let accounts = addressInteractors.addressSync(by: listAccountsIds,
                                                      myAddress: accountAddress)

        let blockHeight = serverEnvironmentUseCase
            .serverEnvironment()
            .flatMap { [weak self] serverEnvironment -> Observable<Int64> in
                guard let self = self else { return Observable.never() }
                return self
                    .blockRepositoryRemote
                    .height(serverEnvironment: serverEnvironment,
                            accountAddress: accountAddress)
            }
            .catchError { _ -> Observable<Int64> in Observable.just(0) } // TODO: думаю что в данном моменте возвращать 0 неверно

        let accountSettings = accountSettingsRepository.accountSettings(accountAddress: accountAddress)

        return Observable
            .zip(blockHeight, assets, accountSettings)
            .flatMap { args -> Observable<SmartTransactionSyncData> in
                let blocks = args.0
                let assets = args.1
                let settings = args.2

                let activeLeaseing = query.leaseTransactions ?? []

                return accounts
                    .map { accounts -> SmartTransactionSyncData in
                        SmartTransactionSyncData(assets: .remote(assets),
                                                 transaction: query.transactions,
                                                 block: blocks,
                                                 accounts: accounts,
                                                 leaseTxs: activeLeaseing,
                                                 isEnableSpamFilter: settings?.isEnabledSpam ?? false)
                    }
            }
            .flatMap { [weak self] data -> SmartTransactionsSyncObservable in

                guard let self = self else { return Observable.never() }

                guard let assets = data.assets.resultIngoreError else {
                    if let error = data.assets.error {
                        if let remoteError = query.remoteError {
                            return SmartTransactionsSyncObservable.just(.error(remoteError))
                        } else {
                            return SmartTransactionsSyncObservable.just(.error(error))
                        }
                    }

                    return SmartTransactionsSyncObservable.just(.error(TransactionsUseCaseError.invalid))
                }

                guard let accounts = data.accounts.resultIngoreError else {
                    if let error = data.accounts.error {
                        if let remoteError = query.remoteError {
                            return SmartTransactionsSyncObservable.just(.error(remoteError))
                        } else {
                            return SmartTransactionsSyncObservable.just(.error(error))
                        }
                    }

                    return SmartTransactionsSyncObservable.just(.error(TransactionsUseCaseError.invalid))
                }

                let assetsMap = assets.reduce(into: [String: Asset]()) { $0[$1.id] = $1 }
                let accountsMap = accounts.reduce(into: [String: Address]()) { $0[$1.address] = $1 }
                let leaseTxsMap = data.leaseTxs.reduce(into: [String: LeaseTransaction]()) { $0[$1.id] = $1 }

                let txs = self.mapToSmartTransactions(by: accountAddress,
                                                      txs: data.transaction,
                                                      assets: assetsMap,
                                                      accounts: accountsMap,
                                                      block: data.block,
                                                      leaseTxs: leaseTxsMap,
                                                      isEnableSpamFilter: data.isEnableSpamFilter)

                if let error = query.remoteError {
                    return .just(.local(txs, error: error))
                } else {
                    return .just(.remote(txs))
                }
            }
    }

    private func mapToSmartTransactions(by accountAddress: String,
                                        txs: [AnyTransaction],
                                        assets: [String: Asset],
                                        accounts: [String: Address],
                                        block: Int64,
                                        leaseTxs: [String: LeaseTransaction],
                                        isEnableSpamFilter: Bool) -> [SmartTransaction] {
        txs.map { tx -> SmartTransaction? in
            tx.transaction(by: accountAddress,
                           assets: assets,
                           accounts: accounts,
                           totalHeight: block,
                           leaseTransactions: leaseTxs,
                           mapTxs: [:])
        }
        .compactMap { $0 }
        .filter { $0.isCanceledLeasingBySender == false &&
            $0.isSpamTransaction(isEnableSpam: isEnableSpamFilter) == false
        }
    }
}

// MARK: - - Assistants method

private extension TransactionsUseCase {
    private func isHasTransactionsSync(_ query: IsHasTransactionsSyncQuery) -> Observable<IsHasTransactionsSyncResult> {
        transactionsDAO.isHasTransactions(by: query.ids,
                                          accountAddress: query.address.address,
                                          ignoreUnconfirmed: true)
            .map { IsHasTransactionsSyncResult(isHasTransactions: $0,
                                               transactions: query.transactions,
                                               remoteError: query.remoteError)
            }
    }

    private func saveTransactions(_ transactions: [AnyTransaction], accountAddress: String) -> Observable<Bool> {
        transactionsDAO.saveTransactions(transactions, accountAddress: accountAddress)
    }

    private func assets(by ids: [String], accountAddress: String) -> Observable<[String: Asset]> {
        let assets = assetsRepository
            .assets(ids: ids,
                    accountAddress: accountAddress)
            .map { $0.compactMap { $0 } }
            .map { assets -> [String: Asset] in

                assets.reduce(into: [String: Asset]()) { list, asset in
                    list[asset.id] = asset
                }
            }
        return assets
    }

    private func accounts(by ids: [String], accountAddress: String) -> Observable<[String: Address]> {
        let accounts = addressInteractors
            .address(by: ids, myAddress: accountAddress)
            .map {
                $0.reduce(into: [String: Address]()) { list, account in
                    list[account.address] = account
                }
            }
        return accounts
    }

    private func calculateFee(isSmartAddress: Bool,
                              wavesAsset: Asset,
                              rules: DomainLayer.DTO.TransactionFeeRules,
                              isSmartAssets: [String: Bool],
                              type: DomainLayer.Query.TransactionSpecificationType) -> Money {
        var rule: DomainLayer.DTO.TransactionFeeRules.Rule!

        if let txType = type.transactionType {
            rule = rules.rules[txType] ?? rules.defaultRule
        } else {
            rule = rules.defaultRule
        }

        var fee: Int64 = rule.fee

        if rule.addSmartAccountFee, isSmartAddress {
            fee += rules.smartAccountExtraFee
        }

        switch type {
        case .createAlias, .lease, .cancelLease:
            break

        case let .burn(assetId):
            if rule.addSmartAssetFee, isSmartAssets[assetId] == true {
                fee += rules.smartAssetExtraFee
            }

        case let .sendTransaction(assetId):
            if rule.addSmartAssetFee, isSmartAssets[assetId] == true {
                fee += rules.smartAssetExtraFee
            }

        case let .createOrder(amountAssetId, priceAssetId, settingsOrderFee, feeAssetId):

            var n: Int64 = 0

            if isSmartAssets[amountAssetId] == true {
                n += 1
            }

            if isSmartAssets[priceAssetId] == true {
                n += 1
            }

            if isSmartAssets[feeAssetId] == true,
                feeAssetId != amountAssetId,
                feeAssetId != priceAssetId {
                n += 1
            }

            if isSmartAddress {
                n += 1
            }

            let assetRate = settingsOrderFee.feeAssets.first(where: { $0.asset.id == feeAssetId })?.rate ?? 0
            let assetDecimal = settingsOrderFee.feeAssets.first(where: { $0.asset.id == feeAssetId })?.asset.precision ?? 0
            let assetFee = assetRate * Double(settingsOrderFee.baseFee + Constants.rateSmart * n)

            let factorFee = (wavesAsset.precision - assetDecimal)
            let correctFee: Int64 = {
                let assetFeeDouble = ceil(assetFee)

                if factorFee == 0 {
                    return Int64(assetFeeDouble)
                }

                return Int64(ceil(assetFeeDouble / pow(10.0, Double(factorFee))))
            }()

            return Money(correctFee, assetDecimal)
        }

        return Money(fee, wavesAsset.precision)
    }
}

// MARK: - -

private extension Array where Element == AnyTransaction {
    var assetsIds: [String] {
        reduce(into: [String]()) { list, tx in
            let assetsIds = tx.assetsIds
            list.append(contentsOf: assetsIds)
        }
        .reduce(into: Set<String>()) { set, id in
            set.insert(id)
        }
        .flatMap { [$0] }
    }

    var accountsIds: Set<String> {
        reduce(into: [String]()) { list, tx in
            let accountsIds = tx.accountsIds
            list.append(contentsOf: accountsIds)
        }
        .reduce(into: Set<String>()) { set, id in set.insert(id) }
    }
}

// MARK: - -  Assisstants Mapper

private extension AnyTransaction {
    var assetsIds: [String] {
        switch self {
        case .unrecognised:
            return [WavesSDKConstants.wavesAssetId]

        case let .issue(tx):
            return [tx.assetId]

        case let .transfer(tx):
            let assetId = tx.assetId
            return [assetId, WavesSDKConstants.wavesAssetId, tx.feeAssetId]

        case let .reissue(tx):
            return [tx.assetId]

        case let .burn(tx):

            return [tx.assetId, WavesSDKConstants.wavesAssetId]

        case let .exchange(tx):

            var ids = [tx.order1.assetPair.amountAsset, tx.order1.assetPair.priceAsset]
            if let matcherFeeAssetId = tx.order1.matcherFeeAssetId {
                ids.append(matcherFeeAssetId)
            }
            if let matcherFeeAssetId = tx.order2.matcherFeeAssetId {
                ids.append(matcherFeeAssetId)
            }
            return ids

        case .lease:
            return [WavesSDKConstants.wavesAssetId]

        case .leaseCancel:
            return [WavesSDKConstants.wavesAssetId]

        case .alias:
            return [WavesSDKConstants.wavesAssetId]

        case let .massTransfer(tx):
            return [tx.assetId, WavesSDKConstants.wavesAssetId]

        case .data:
            return [WavesSDKConstants.wavesAssetId]

        case .script:
            return [WavesSDKConstants.wavesAssetId]

        case let .assetScript(tx):
            return [tx.assetId]

        case let .sponsorship(tx):
            return [tx.assetId]

        case let .invokeScript(tx):

            var payments = tx.payments?.map { $0.assetId }.compactMap { $0 } ?? []
            payments.append(WavesSDKConstants.wavesAssetId)

            return payments
        case let .updateAssetInfo(tx):
            var list = [tx.assetId, WavesSDKConstants.wavesAssetId]
            if let feeAssetId = tx.feeAssetId {
                list.append(feeAssetId)
            }
            return list
        }
    }

    var accountsIds: [String] {
        switch self {
        case let .unrecognised(tx):
            return [tx.sender]

        case let .issue(tx):
            return [tx.sender]

        case let .transfer(tx):
            return [tx.sender, tx.recipient]

        case let .reissue(tx):
            return [tx.sender]

        case let .burn(tx):
            return [tx.sender]

        case let .exchange(tx):
            return [tx.sender, tx.order1.sender, tx.order2.sender]

        case let .lease(tx):
            return [tx.sender, tx.recipient]

        case let .leaseCancel(tx):
            var accountsIds: [String] = [String]()
            accountsIds.append(tx.sender)
            if let lease = tx.lease {
                accountsIds.append(lease.sender)
                accountsIds.append(lease.recipient)
            }

            return accountsIds

        case let .alias(tx):
            return [tx.sender]

        case let .massTransfer(tx):
            var list = tx.transfers.map { $0.recipient }
            list.append(tx.sender)
            return list

        case let .data(tx):
            return [tx.sender]

        case let .script(tx):
            return [tx.sender]

        case let .assetScript(tx):
            return [tx.sender]

        case let .sponsorship(tx):
            return [tx.sender]

        case let .invokeScript(tx):
            return [tx.sender]

        case let .updateAssetInfo(tx):
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

private extension DomainLayer.Query.TransactionSpecificationType {
    var assetIds: [String] {
        switch self {
        case .createAlias, .lease, .cancelLease:
            return []

        case let .burn(assetId):
            return [assetId]

        case let .sendTransaction(assetId):
            return [assetId]

        case let .createOrder(amountAssetId, priceAssetId, _, feeAssetId):
            return [amountAssetId, priceAssetId, feeAssetId]
        }
    }

    var transactionType: TransactionType? {
        switch self {
        case .createAlias:
            return TransactionType.createAlias

        case .lease:
            return TransactionType.createLease

        case .cancelLease:
            return TransactionType.cancelLease

        case .burn:
            return TransactionType.burn

        case .sendTransaction:
            return TransactionType.transfer

        case .createOrder:
            return TransactionType.exchange
        }
    }
}

private extension SmartTransaction {
    var isCanceledLeasingBySender: Bool {
        switch kind {
        case .canceledLeasing:
            return sender.isMyAccount ? false : true
        default:
            return false
        }
    }

    func isSpamTransaction(isEnableSpam: Bool) -> Bool {
        if isEnableSpam {
            switch kind {
            case .spamReceive:
                return true

            case .spamMassReceived:
                return true

            case let .sent(tx):
                return tx.asset.isSpam

            case let .selfTransfer(tx):
                return tx.asset.isSpam

            case let .massSent(tx):
                return tx.asset.isSpam

            case let .tokenGeneration(tx):
                return tx.asset.isSpam

            case let .tokenBurn(tx):
                return tx.asset.isSpam

            case let .tokenReissue(tx):
                return tx.asset.isSpam

            case let .assetScript(asset):
                return asset.isSpam

            case let .sponsorship(_, asset):
                return asset.isSpam

            default:
                return false
            }
        }
        return false
    }
}
