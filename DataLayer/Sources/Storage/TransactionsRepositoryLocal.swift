//
//  TransactionsRepositoryLocal.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 31.08.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import RealmSwift
import RxRealm
import RxSwift
import WavesSDK
import WavesSDKExtensions

extension Realm {
    func filter<ParentType: Object>(parentType: ParentType.Type,
                                    subclasses: [ParentType.Type],
                                    predicate: NSPredicate) -> [ParentType] {
        return ([parentType] + subclasses)
            .flatMap { classType in
                Array(self.objects(classType).filter(predicate))
            }
    }
}

private extension TransactionType {
    // The types using only waves assetId
    static var waves: [TransactionType] {
        return [.createLease,
                .cancelLease,
                .createAlias,
                .data,
                .script]
    }

    func predicate(from specifications: TransactionsSpecifications, myAddress: DomainLayer.DTO.Address) -> NSPredicate {
        switch self {
        case .createAlias:
            return AliasTransaction.predicate(specifications, myAddress: myAddress)

        case .issue:
            return IssueTransaction.predicate(specifications, myAddress: myAddress)

        case .transfer:
            return TransferTransaction.predicate(specifications, myAddress: myAddress)

        case .reissue:
            return ReissueTransaction.predicate(specifications, myAddress: myAddress)

        case .burn:
            return BurnTransaction.predicate(specifications, myAddress: myAddress)

        case .exchange:
            return ExchangeTransaction.predicate(specifications, myAddress: myAddress)

        case .createLease:
            return LeaseTransaction.predicate(specifications, myAddress: myAddress)

        case .cancelLease:
            return LeaseCancelTransaction.predicate(specifications, myAddress: myAddress)

        case .massTransfer:
            return MassTransferTransaction.predicate(specifications, myAddress: myAddress)

        case .data:
            return DataTransaction.predicate(specifications, myAddress: myAddress)

        case .assetScript:
            return AssetScriptTransaction.predicate(specifications, myAddress: myAddress)

        case .script:
            return ScriptTransaction.predicate(specifications, myAddress: myAddress)

        case .sponsorship:
            return SponsorshipTransaction.predicate(specifications, myAddress: myAddress)

        case .invokeScript:
            return InvokeScriptTransaction.predicate(specifications, myAddress: myAddress)
        }
    }

    func anyTransaction(from transaction: AnyTransaction) -> DomainLayer.DTO.AnyTransaction? {
        switch self {
        case .createAlias:
            guard let aliasTransaction = transaction.aliasTransaction else { return nil }
            return .alias(.init(transaction: aliasTransaction))

        case .issue:
            guard let issueTransaction = transaction.issueTransaction else { return nil }
            return .issue(.init(transaction: issueTransaction))

        case .transfer:
            guard let transferTransaction = transaction.transferTransaction else { return nil }
            return .transfer(.init(transaction: transferTransaction))

        case .reissue:
            guard let reissueTransaction = transaction.reissueTransaction else { return nil }
            return .reissue(.init(transaction: reissueTransaction))

        case .burn:
            guard let burnTransaction = transaction.burnTransaction else { return nil }
            return .burn(.init(transaction: burnTransaction))

        case .exchange:
            guard let exchangeTransaction = transaction.exchangeTransaction else { return nil }
            return .exchange(.init(transaction: exchangeTransaction))

        case .createLease:
            guard let leaseTransaction = transaction.leaseTransaction else { return nil }
            return .lease(.init(transaction: leaseTransaction))

        case .cancelLease:
            guard let leaseCancelTransaction = transaction.leaseCancelTransaction else { return nil }
            return .leaseCancel(.init(transaction: leaseCancelTransaction))

        case .massTransfer:
            guard let massTransferTransaction = transaction.massTransferTransaction else { return nil }
            return .massTransfer(.init(transaction: massTransferTransaction))

        case .data:
            guard let dataTransaction = transaction.dataTransaction else { return nil }
            return .data(.init(transaction: dataTransaction))

        case .script:
            guard let scriptTransaction = transaction.scriptTransaction else { return nil }
            return .script(.init(transaction: scriptTransaction))

        case .assetScript:
            guard let assetScriptTransaction = transaction.assetScriptTransaction else { return nil }
            return .assetScript(.init(transaction: assetScriptTransaction))

        case .sponsorship:
            guard let sponsorshipTransaction = transaction.sponsorshipTransaction else { return nil }
            return .sponsorship(.init(transaction: sponsorshipTransaction))

        case .invokeScript:
            guard let invokeScriptTransaction = transaction.invokeScriptTransaction else { return nil }
            return .invokeScript(.init(transaction: invokeScriptTransaction))
        }
    }
}

final class TransactionsRepositoryLocal: TransactionsRepositoryProtocol {
    func transactions(by address: DomainLayer.DTO.Address,
                      offset: Int,
                      limit: Int) -> Observable<[DomainLayer.DTO.AnyTransaction]> {
        let specifications = TransactionsSpecifications(page: .init(offset: offset, limit: limit),
                                                        assets: [],
                                                        senders: [],
                                                        types: TransactionType.all)
        return transactions(by: address, specifications: specifications)
    }

    func transactions(by address: DomainLayer.DTO.Address,
                      specifications: TransactionsSpecifications) -> Observable<[DomainLayer.DTO.AnyTransaction]> {
        Observable.create { [weak self] observer -> Disposable in

            guard let self = self else {
                observer.onError(AccountBalanceRepositoryError.fail)
                return Disposables.create()
            }

            guard let realm = try? WalletRealmFactory.realm(accountAddress: address.address) else {
                observer.onError(AccountBalanceRepositoryError.fail)
                return Disposables.create()
            }

            let result = self.transactionsResultFromRealm(by: address,
                                                          specifications: specifications,
                                                          realm: realm)

            let transactions = self.mapping(result: result, by: specifications)

            observer.onNext(transactions)
            observer.onCompleted()
            return Disposables.create()
        }
    }

    private func transactionsResultFromRealm(by address: DomainLayer.DTO.Address,
                                             specifications: TransactionsSpecifications,
                                             realm: Realm) -> Results<AnyTransaction> {
        let wavesAssetId = WavesSDKConstants.wavesAssetId

        let hasWaves = specifications.assets.contains(wavesAssetId)

        var types = specifications.types
        if !specifications.assets.isEmpty, !hasWaves {
            types = types.filter { !TransactionType.waves.contains($0) }
        }

        var predicatesFromTypes: [NSPredicate] = []
        types.forEach {
            predicatesFromTypes.append($0.predicate(from: specifications, myAddress: address))
        }

        let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicatesFromTypes)

        let txsResult = realm
            .objects(AnyTransaction.self)
            .sorted(byKeyPath: "timestamp", ascending: false)
            .filter("type IN %@", types.map { $0.rawValue })
            .filter(predicate)

        return txsResult
    }

    private func mapping(result: Results<AnyTransaction>,
                         by specifications: TransactionsSpecifications) -> [DomainLayer.DTO.AnyTransaction] {
        var txs: [AnyTransaction] = []
        if let page = specifications.page {
            txs = result.get(offset: page.offset, limit: page.limit)
        } else {
            txs = result.toArray()
        }

        return mapping(txs: txs, by: specifications)
    }

    private func mapping(txs: [AnyTransaction],
                         by _: TransactionsSpecifications) -> [DomainLayer.DTO.AnyTransaction] {
        var transactions = [DomainLayer.DTO.AnyTransaction]()

        for any in txs {
            guard let type = TransactionType(rawValue: Int8(any.type)) else { continue }
            guard let tx = type.anyTransaction(from: any) else { continue }
            transactions.append(tx)
        }

        return transactions
    }

    func newTransactions(by address: DomainLayer.DTO.Address,
                         specifications: TransactionsSpecifications) -> Observable<[DomainLayer.DTO.AnyTransaction]> {
        Observable.create { [weak self] observer -> Disposable in

            guard let self = self else {
                observer.onError(AccountBalanceRepositoryError.fail)
                return Disposables.create()
            }

            guard let realm = try? WalletRealmFactory.realm(accountAddress: address.address) else {
                observer.onError(AccountBalanceRepositoryError.fail)
                return Disposables.create()
            }

            let txsResult = self.transactionsResultFromRealm(by: address,
                                                             specifications: specifications,
                                                             realm: realm)

            // TODO: - .bind(to: observer) странное поведение
            let dispose = Observable
                .arrayWithChangeset(from: txsResult)
                .flatMap { [weak self] list, changeSet -> Observable<[DomainLayer.DTO.AnyTransaction]> in

                    guard let self = self else {
                        return Observable.never()
                    }

                    guard let changeset = changeSet else { return Observable.just([]) }
                    let txs = changeset.inserted.reduce(into: [AnyTransaction]()) { result, index in
                        result.append(list[index])
                    }
                    let transactions = self.mapping(txs: txs, by: specifications)
                    return Observable.just(transactions)
                }
                .bind(to: observer)

            return Disposables.create([dispose])
        }
        .subscribeOn(Schedulers.realmThreadScheduler)
    }

    func activeLeasingTransactions(by accountAddress: String) -> Observable<[DomainLayer.DTO.LeaseTransaction]> {
        transactions(by: DomainLayer.DTO.Address(address: accountAddress,
                                                 contact: nil,
                                                 isMyAccount: true,
                                                 aliases: []),
                     specifications: TransactionsSpecifications(page: nil,
                                                                assets: .init(),
                                                                senders: .init(),
                                                                types: [TransactionType.createLease]))
            .map { txs -> [DomainLayer.DTO.LeaseTransaction] in
                txs.map { tx -> DomainLayer.DTO.LeaseTransaction? in
                    if case let .lease(leaseTx) = tx {
                        return leaseTx
                    } else {
                        return nil
                    }
                }
                .compactMap { $0 }
            }
    }

    func send(by _: TransactionSenderSpecifications,
              wallet _: DomainLayer.DTO.SignedWallet) -> Observable<DomainLayer.DTO.AnyTransaction> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func isHasTransactions(by accountAddress: String, ignoreUnconfirmed: Bool) -> Observable<Bool> {
        Observable.create { observer -> Disposable in
            guard let realm = try? WalletRealmFactory.realm(accountAddress: accountAddress) else {
                observer.onError(AccountBalanceRepositoryError.fail)
                return Disposables.create()
            }

            let result = realm.objects(AnyTransaction.self)
                .filter { tx -> Bool in
                    if ignoreUnconfirmed {
                        return tx.status != TransactionStatus.unconfirmed.rawValue
                    }
                    return true
                }

            observer.onNext(!result.isEmpty)
            observer.onCompleted()

            return Disposables.create()
        }
    }

    func isHasTransaction(by id: String, accountAddress: String, ignoreUnconfirmed: Bool) -> Observable<Bool> {
        Observable.create { observer -> Disposable in
            guard let realm = try? WalletRealmFactory.realm(accountAddress: accountAddress) else {
                observer.onError(AccountBalanceRepositoryError.fail)
                return Disposables.create()
            }
            let object = realm.object(ofType: AnyTransaction.self, forPrimaryKey: id)

            var result: Bool = false

            if let object = object {
                if ignoreUnconfirmed {
                    result = object.status != TransactionStatus.unconfirmed.rawValue
                } else {
                    result = true
                }
            }

            observer.onNext(result)
            observer.onCompleted()

            return Disposables.create()
        }
    }

    func isHasTransactions(by ids: [String], accountAddress: String, ignoreUnconfirmed: Bool) -> Observable<Bool> {
        return Observable.create { observer -> Disposable in
            guard let realm = try? WalletRealmFactory.realm(accountAddress: accountAddress) else {
                observer.onError(AccountBalanceRepositoryError.fail)
                return Disposables.create()
            }

            let result = realm.objects(AnyTransaction.self)
                .filter("id IN %@", ids)
                .filter { tx -> Bool in
                    if ignoreUnconfirmed {
                        return tx.status != TransactionStatus.unconfirmed.rawValue
                    }
                    return true
                }
            observer.onNext(result.count == ids.count)
            observer.onCompleted()

            return Disposables.create()
        }
    }

    func saveTransactions(_ transactions: [DomainLayer.DTO.AnyTransaction], accountAddress: String) -> Observable<Bool> {
        Observable.create { observer -> Disposable in

            guard let realm = try? WalletRealmFactory.realm(accountAddress: accountAddress) else {
                observer.onError(AccountBalanceRepositoryError.fail)
                return Disposables.create()
            }

            var anyList: [AnyTransaction] = []

            for tx in transactions {
                let realmTx = tx.transaction
                anyList.append(tx.anyTransaction(from: realmTx))
            }

            do {
                try realm.write {
                    realm.add(anyList, update: .all)
                }
                observer.onNext(true)
                observer.onCompleted()
            } catch let e {
                SweetLogger.error(e)
                observer.onNext(false)
                observer.onError(AccountBalanceRepositoryError.fail)
            }

            return Disposables.create()
        }
    }

    func feeRules() -> Observable<DomainLayer.DTO.TransactionFeeRules> {
        assertMethodDontSupported()
        return Observable.never()
    }
}

private protocol TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications, myAddress: DomainLayer.DTO.Address) -> NSPredicate
}

extension UnrecognisedTransaction: TransactionsSpecificationsConverter {
    static func predicate(_: TransactionsSpecifications, myAddress _: DomainLayer.DTO.Address) -> NSPredicate {
        NSPredicate(format: "unrecognisedTransaction != NULL")
    }
}

extension IssueTransaction: TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications, myAddress _: DomainLayer.DTO.Address) -> NSPredicate {
        var predicates: [NSPredicate] = []
        predicates.append(NSPredicate(format: "issueTransaction != NULL"))

        if !from.assets.isEmpty {
            predicates.append(NSPredicate(format: "issueTransaction.assetId IN %@", from.assets))
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}

extension TransferTransaction: TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications, myAddress: DomainLayer.DTO.Address) -> NSPredicate {
        var predicates: [NSPredicate] = []
        predicates.append(NSPredicate(format: "transferTransaction != NULL"))

        if !from.assets.isEmpty {
            let aliases = myAddress.aliases.map { $0.name }
            let predicateFormat = "transferTransaction.assetId IN %@ AND ((transferTransaction.sender == %@" +
                " ||  transferTransaction.sender IN %@) OR" +
                " ((transferTransaction.recipient == %@ || transferTransaction.recipient IN %@)))"
            let myTx = NSPredicate(format: predicateFormat, from.assets, myAddress.address, aliases, myAddress.address, aliases)

            let sponsoredTxPredicateFormat = "transferTransaction.feeAssetId IN %@" +
                " AND ((transferTransaction.sender != %@ && !(transferTransaction.sender IN %@))" +
                " AND (transferTransaction.recipient != %@ && !(transferTransaction.recipient IN %@)))"
            let sponsoredTx = NSPredicate(format: sponsoredTxPredicateFormat,
                                          from.assets,
                                          myAddress.address,
                                          aliases,
                                          myAddress.address,
                                          aliases)

            predicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: [myTx, sponsoredTx]))
        }
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}

extension ReissueTransaction: TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications, myAddress _: DomainLayer.DTO.Address) -> NSPredicate {
        var predicates: [NSPredicate] = .init()
        predicates.append(NSPredicate(format: "reissueTransaction != NULL"))

        if !from.assets.isEmpty {
            predicates.append(NSPredicate(format: "reissueTransaction.assetId IN %@", from.assets))
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}

extension LeaseTransaction: TransactionsSpecificationsConverter {
    static func predicate(_: TransactionsSpecifications, myAddress _: DomainLayer.DTO.Address) -> NSPredicate {
        NSPredicate(format: "leaseTransaction != NULL")
    }
}

extension LeaseCancelTransaction: TransactionsSpecificationsConverter {
    static func predicate(_: TransactionsSpecifications, myAddress _: DomainLayer.DTO.Address) -> NSPredicate {
        NSPredicate(format: "leaseCancelTransaction != NULL")
    }
}

extension AliasTransaction: TransactionsSpecificationsConverter {
    static func predicate(_: TransactionsSpecifications, myAddress _: DomainLayer.DTO.Address) -> NSPredicate {
        NSPredicate(format: "aliasTransaction != NULL")
    }
}

extension MassTransferTransaction: TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications, myAddress _: DomainLayer.DTO.Address) -> NSPredicate {
        var predicates: [NSPredicate] = []
        predicates.append(NSPredicate(format: "massTransferTransaction != NULL"))

        if !from.assets.isEmpty {
            predicates.append(NSPredicate(format: "massTransferTransaction.assetId IN %@", from.assets))
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}

extension BurnTransaction: TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications, myAddress _: DomainLayer.DTO.Address) -> NSPredicate {
        var predicates: [NSPredicate] = .init()
        predicates.append(NSPredicate(format: "burnTransaction != NULL"))

        if !from.assets.isEmpty {
            predicates.append(NSPredicate(format: "burnTransaction.assetId IN %@", from.assets))
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}

extension ExchangeTransaction: TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications, myAddress _: DomainLayer.DTO.Address) -> NSPredicate {
        var predicates: [NSPredicate] = .init()
        predicates.append(NSPredicate(format: "exchangeTransaction != NULL"))

        if !from.assets.isEmpty {
            let format = "exchangeTransaction.order1.assetPair.amountAsset IN %@"
                + " OR exchangeTransaction.order1.assetPair.priceAsset IN %@"
                + " OR exchangeTransaction.order2.assetPair.amountAsset IN %@"
                + " OR exchangeTransaction.order2.assetPair.priceAsset IN %@"

            predicates.append(NSPredicate(format: format,
                                          from.assets,
                                          from.assets,
                                          from.assets,
                                          from.assets))
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}

extension DataTransaction: TransactionsSpecificationsConverter {
    static func predicate(_: TransactionsSpecifications, myAddress _: DomainLayer.DTO.Address) -> NSPredicate {
        NSPredicate(format: "dataTransaction != NULL")
    }
}

extension AssetScriptTransaction: TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications, myAddress _: DomainLayer.DTO.Address) -> NSPredicate {
        var predicates: [NSPredicate] = .init()
        predicates.append(NSPredicate(format: "assetScriptTransaction != NULL"))

        if !from.assets.isEmpty {
            predicates.append(NSPredicate(format: "assetScriptTransaction.assetId IN %@", from.assets))
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}

extension ScriptTransaction: TransactionsSpecificationsConverter {
    static func predicate(_: TransactionsSpecifications, myAddress _: DomainLayer.DTO.Address) -> NSPredicate {
        NSPredicate(format: "scriptTransaction != NULL")
    }
}

extension SponsorshipTransaction: TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications, myAddress _: DomainLayer.DTO.Address) -> NSPredicate {
        var predicates: [NSPredicate] = .init()
        predicates.append(NSPredicate(format: "sponsorshipTransaction != NULL"))

        if !from.assets.isEmpty {
            predicates.append(NSPredicate(format: "sponsorshipTransaction.assetId IN %@", from.assets))
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}

extension InvokeScriptTransaction: TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications, myAddress _: DomainLayer.DTO.Address) -> NSPredicate {
        var predicates: [NSPredicate] = .init()
        predicates.append(NSPredicate(format: "invokeScriptTransaction != NULL"))

        if !from.assets.isEmpty {
            predicates.append(NSPredicate(format: "invokeScriptTransaction.payment.assetId IN %@", from.assets))
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}
