//
//  TransactionsRepositoryLocal.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 31.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift
import RxRealm
import RxSwift
import RxOptional

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

fileprivate extension TransactionType {
    static var waves: [TransactionType] {
        return [.issue,
                .reissue,
                .burn,
                .lease,
                .leaseCancel,
                .alias,
                .data]
    }

    func predicate(from specifications: TransactionsSpecifications) -> NSPredicate {

        switch self {
        case .alias:
            return AliasTransaction.predicate(specifications)

        case .issue:
            return IssueTransaction.predicate(specifications)

        case .transfer:
            return TransferTransaction.predicate(specifications)

        case .reissue:
            return ReissueTransaction.predicate(specifications)

        case .burn:
            return BurnTransaction.predicate(specifications)

        case .exchange:
            return ExchangeTransaction.predicate(specifications)

        case .lease:
            return LeaseTransaction.predicate(specifications)

        case .leaseCancel:
            return LeaseCancelTransaction.predicate(specifications)

        case .massTransfer:
            return MassTransferTransaction.predicate(specifications)

        case .data:
            return DataTransaction.predicate(specifications)
        }
    }

    func anyTransaction(from transaction: AnyTransaction) -> DomainLayer.DTO.AnyTransaction? {

        switch self {
        case .alias:
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

        case .lease:
            guard let leaseTransaction = transaction.leaseTransaction else { return nil }
            return .lease(.init(transaction: leaseTransaction))

        case .leaseCancel:
            guard let leaseCancelTransaction = transaction.leaseCancelTransaction else { return nil }
            return .leaseCancel(.init(transaction: leaseCancelTransaction))

        case .massTransfer:
            guard let massTransferTransaction = transaction.massTransferTransaction else { return nil }
            return .massTransfer(.init(transaction: massTransferTransaction))

        case .data:
            guard let dataTransaction = transaction.dataTransaction else { return nil }
            return .data(.init(transaction: dataTransaction))
        }
    }
}

final class TransactionsRepositoryLocal: TransactionsRepositoryProtocol {

    func transactions(by accountAddress: String, offset: Int, limit: Int) -> Observable<[DomainLayer.DTO.AnyTransaction]> {
        return self.transactions(by: accountAddress, specifications: TransactionsSpecifications(page: .init(offset: offset, limit: limit), assets: [], senders: [], types: TransactionType.all))
    }

    func transactions(by accountAddress: String,
                      specifications: TransactionsSpecifications) -> Observable<[DomainLayer.DTO.AnyTransaction]> {

        return Observable.create { (observer) -> Disposable in

            guard let realm = try? Realm() else {
                observer.onError(AccountBalanceRepositoryError.fail)
                return Disposables.create()
            }

            let wavesAssetId = Environments.Constants.wavesAssetId

            let hasWaves = specifications.assets.contains(wavesAssetId)

            var types = specifications.types
            if specifications.assets.count > 0 && hasWaves == false {
                types = types.filter { TransactionType.waves.contains($0) == false }
            }

            var predicatesFromTypes: [NSPredicate] = .init()
            types.forEach { predicatesFromTypes.append($0.predicate(from: specifications)) }

            let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicatesFromTypes)

            let txsResult = realm
                .objects(AnyTransaction.self)
                .sorted(byKeyPath: "timestamp", ascending: false)
                .filter("type IN %@", types.map { $0.rawValue })
                .filter(predicate)

            var txs: [AnyTransaction] = []
            if let page = specifications.page {
                txs = txsResult.get(offset: page.offset, limit: page.limit)
            } else {
                txs = txsResult.toArray()
            }

            var transactions = [DomainLayer.DTO.AnyTransaction]()

            for any in txs {
                guard let type = TransactionType(rawValue: any.type) else { continue }
                guard let tx = type.anyTransaction(from: any) else { continue }
                transactions.append(tx)
            }

            observer.onNext(transactions)
            observer.onCompleted()
            return Disposables.create()
        }
    }

    func activeLeasingTransactions(by accountAddress: String) -> Observable<[DomainLayer.DTO.LeaseTransaction]> {
        return self.transactions(by: accountAddress,
                                 specifications: TransactionsSpecifications(page: nil,
                                                                            assets: .init(),
                                                                            senders: .init(),
                                                                            types: [TransactionType.lease]))
            .map({ txs -> [DomainLayer.DTO.LeaseTransaction] in
                return txs.map({ tx -> DomainLayer.DTO.LeaseTransaction? in
                    if case .lease(let leaseTx) = tx {
                        return leaseTx
                    } else {
                        return nil
                    }
                })
                .compactMap { $0 }
            })

    }

    var isHasTransactions: Observable<Bool> {

        return Observable.create { observer -> Disposable in

            guard let realm = try? Realm() else {
                observer.onError(AccountBalanceRepositoryError.fail)
                return Disposables.create()
            }

            observer.onNext(realm.objects(AnyTransaction.self).count != 0)
            observer.onCompleted()

            return Disposables.create()
        }
    }

    func isHasTransaction(by id: String) -> Observable<Bool> {

        return Observable.create { observer -> Disposable in

            guard let realm = try? Realm() else {
                observer.onError(AccountBalanceRepositoryError.fail)
                return Disposables.create()
            }

            observer.onNext(realm.object(ofType: AnyTransaction.self, forPrimaryKey: id) != nil)
            observer.onCompleted()

            return Disposables.create()
        }
    }

    func isHasTransactions(by ids: [String]) -> Observable<Bool> {
        return Observable.create { observer -> Disposable in

            guard let realm = try? Realm() else {
                observer.onError(AccountBalanceRepositoryError.fail)
                return Disposables.create()
            }

            let result = realm.objects(AnyTransaction.self).filter("id IN %@", ids)
            observer.onNext(result.count == ids.count)
            observer.onCompleted()

            return Disposables.create()
        }
    }

    func saveTransactions(_ transactions: [DomainLayer.DTO.AnyTransaction]) -> Observable<Bool> {

        return Observable.create { observer -> Disposable in

            guard let realm = try? Realm() else {
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
                    realm.add(anyList, update: true)
                }
                observer.onNext(true)
                observer.onCompleted()
            } catch let e {
                error(e)
                observer.onNext(false)
                observer.onError(AccountBalanceRepositoryError.fail)
            }

            return Disposables.create()
        }
    }
}

fileprivate protocol TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications) -> NSPredicate
}

extension UnrecognisedTransaction: TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications) -> NSPredicate {
        return NSPredicate(format: "unrecognisedTransaction != NULL")
    }
}

extension IssueTransaction: TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications) -> NSPredicate {

        var predicates: [NSPredicate] = .init()
        predicates.append(NSPredicate(format: "issueTransaction != NULL"))

        if from.assets.count > 0 {
            predicates.append(NSPredicate(format: "issueTransaction.assetId IN %@", from.assets))
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}

extension TransferTransaction: TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications) -> NSPredicate {

        var predicates: [NSPredicate] = .init()
        predicates.append(NSPredicate(format: "transferTransaction != NULL"))

        if from.assets.count > 0 {
            predicates.append(NSPredicate(format: "transferTransaction.assetId IN %@", from.assets))
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}

extension ReissueTransaction: TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications) -> NSPredicate {

        var predicates: [NSPredicate] = .init()
        predicates.append(NSPredicate(format: "reissueTransaction != NULL"))

        if from.assets.count > 0 {
            predicates.append(NSPredicate(format: "reissueTransaction.assetId IN %@", from.assets))
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}

extension LeaseTransaction: TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications) -> NSPredicate {
        return NSPredicate(format: "leaseTransaction != NULL")
    }
}

extension LeaseCancelTransaction: TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications) -> NSPredicate {
        return NSPredicate(format: "leaseCancelTransaction != NULL")
    }
}

extension AliasTransaction: TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications) -> NSPredicate {
        return NSPredicate(format: "aliasTransaction != NULL")
    }
}

extension MassTransferTransaction: TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications) -> NSPredicate {

        var predicates: [NSPredicate] = .init()
        predicates.append(NSPredicate(format: "massTransferTransaction != NULL"))

        if from.assets.count > 0 {
            predicates.append(NSPredicate(format: "massTransferTransaction.assetId IN %@", from.assets))
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}

extension BurnTransaction: TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications) -> NSPredicate {

        var predicates: [NSPredicate] = .init()
        predicates.append(NSPredicate(format: "burnTransaction != NULL"))

        if from.assets.count > 0 {
            predicates.append(NSPredicate(format: "burnTransaction.assetId IN %@", from.assets))
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}

extension ExchangeTransaction: TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications) -> NSPredicate {

        var predicates: [NSPredicate] = .init()
        predicates.append(NSPredicate(format: "exchangeTransaction != NULL"))

        if from.assets.count > 0 {

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
    static func predicate(_ from: TransactionsSpecifications) -> NSPredicate {
        return NSPredicate(format: "dataTransaction != NULL")
    }
}
