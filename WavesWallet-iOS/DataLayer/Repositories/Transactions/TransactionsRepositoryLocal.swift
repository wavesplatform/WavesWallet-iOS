//
//  TransactionsRepositoryLocal.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 31.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxRealm
import RealmSwift

extension Realm {
    func filter<ParentType: Object>(parentType: ParentType.Type,
                                    subclasses: [ParentType.Type],
                                    predicate: NSPredicate) -> [ParentType] {
        return ([parentType] + subclasses)
            .flatMap { classType in
            return Array(self.objects(classType).filter(predicate))
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
}


final class TransactionsRepositoryLocal: TransactionsRepositoryProtocol {

    func transactions(by accountAddress: String, offset: Int, limit: Int) -> Observable<[DomainLayer.DTO.AnyTransaction]> {
        return Observable.never()
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

            let txs = realm
                .objects(AnyTransaction.self)
                .sorted(byKeyPath: "timestamp")
                .filter("type IN %@", types.map { $0.rawValue })
                .filter(predicate)



            for any in txs.toArray() {


            }

            debug(txs.toArray())




//
//
//            let unrecogniedTxs = realm
//                .objects(AnyTransaction.self)
//                .toArray()
//                .map { DomainLayer.DTO.UnrecognisedTransaction(transaction: $0) }
//                .map { DomainLayer.DTO.AnyTransaction.unrecognised($0) }
//
//            let issueTxs = realm
//                .objects(IssueTransaction.self)
//                .toArray()
//                .map { DomainLayer.DTO.IssueTransaction(transaction: $0) }
//                .map { DomainLayer.DTO.AnyTransaction.issue($0) }
//
//            let transferTxs = realm
//                .objects(TransferTransaction.self)
//                .toArray()
//                .map { DomainLayer.DTO.TransferTransaction(transaction: $0) }
//                .map { DomainLayer.DTO.AnyTransaction.transfer($0) }
//
//            let reissueTxs = realm
//                .objects(ReissueTransaction.self)
//                .toArray()
//                .map { DomainLayer.DTO.ReissueTransaction(transaction: $0) }
//                .map { DomainLayer.DTO.AnyTransaction.reissue($0) }
//
//            let leaseTxs = realm
//                .objects(LeaseTransaction.self)
//                .toArray()
//                .map { DomainLayer.DTO.LeaseTransaction(transaction: $0) }
//                .map { DomainLayer.DTO.AnyTransaction.lease($0) }
//
//            let leaseCancelTxs = realm
//                .objects(LeaseCancelTransaction.self)
//                .toArray()
//                .map { DomainLayer.DTO.LeaseCancelTransaction(transaction: $0) }
//                .map { DomainLayer.DTO.AnyTransaction.leaseCancel($0) }
//
//            let aliasTxs = realm
//                .objects(AliasTransaction.self)
//                .toArray()
//                .map { DomainLayer.DTO.AliasTransaction(transaction: $0) }
//                .map { DomainLayer.DTO.AnyTransaction.alias($0) }
//
//            let massTransferTxs = realm
//                .objects(MassTransferTransaction.self)
//                .toArray()
//                .map { DomainLayer.DTO.MassTransferTransaction(transaction: $0) }
//                .map { DomainLayer.DTO.AnyTransaction.massTransfer($0) }
//
//            let burnTxs = realm
//                .objects(BurnTransaction.self)
//                .toArray()
//                .map { DomainLayer.DTO.BurnTransaction(transaction: $0) }
//                .map { DomainLayer.DTO.AnyTransaction.burn($0) }
//
//            let exchangeTxs = realm
//                .objects(ExchangeTransaction.self)
//                .toArray()
//                .map { DomainLayer.DTO.ExchangeTransaction(transaction: $0) }
//                .map { DomainLayer.DTO.AnyTransaction.exchange($0) }
//
//            let dataTxs = realm
//                .objects(DataTransaction.self)
//                .toArray()
//                .map { DomainLayer.DTO.DataTransaction(transaction: $0) }
//                .map { DomainLayer.DTO.AnyTransaction.data($0) }
//
//            var transactions = [DomainLayer.DTO.AnyTransaction]()
//
//            transactions.append(contentsOf: unrecogniedTxs)
//            transactions.append(contentsOf: issueTxs)
//            transactions.append(contentsOf: transferTxs)
//            transactions.append(contentsOf: reissueTxs)
//            transactions.append(contentsOf: leaseTxs)
//            transactions.append(contentsOf: leaseCancelTxs)
//            transactions.append(contentsOf: aliasTxs)
//            transactions.append(contentsOf: massTransferTxs)
//            transactions.append(contentsOf: burnTxs)
//            transactions.append(contentsOf: exchangeTxs)
//            transactions.append(contentsOf: dataTxs)
//
//
//
//            observer.onNext(transactions)
            observer.onCompleted()
//
            return Disposables.create()
        }
    }

    var isHasTransactions: Observable<Bool> {

        return Observable.create { observer -> Disposable in

            guard let realm = try? Realm() else {
                observer.onError(AccountBalanceRepositoryError.fail)
                return Disposables.create()
            }

            observer.onNext(realm.objects(AnyTransaction.self).count == 0)
            observer.onCompleted()

            return Disposables.create()
        }
    }

    func transactions(by accountAddress: String, assetId: String, offset: Int, limit: Int) -> Observable<[DomainLayer.DTO.AnyTransaction]> {
        return Observable.never()
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
