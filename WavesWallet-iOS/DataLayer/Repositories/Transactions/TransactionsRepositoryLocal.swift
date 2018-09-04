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

            let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [UnrecognisedTransaction.predicate(specifications)])

            

            let types = specifications.types.map { $0.rawValue }

            let txs = realm
                .objects(AnyTransaction.self)
                .sorted(byKeyPath: "timestamp")
                .filter("type IN %@", types)
                .filter("dataTransaction != NULL")


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
        return NSPredicate(format: "WAVES IN %@", from.assets)
    }
}

extension IssueTransaction: TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications) -> NSPredicate {
        return NSPredicate(format: "issueTransaction.assetId IN %@", from.assets)
    }
}

extension TransferTransaction: TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications) -> NSPredicate {
        return NSPredicate(format: "transferTransaction.assetId IN %@", from.assets)
    }
}

extension ReissueTransaction: TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications) -> NSPredicate {
        return NSPredicate(format: "reissueTransaction.assetId IN %@", from.assets)
    }
}

extension LeaseTransaction: TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications) -> NSPredicate {
        return NSPredicate(format: "leaseTransaction != NULL AND WAVES IN %@", from.assets)
    }
}

extension LeaseCancelTransaction: TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications) -> NSPredicate {
        return NSPredicate(format: "leaseCancelTransaction != NULL AND WAVES IN %@", from.assets)
    }
}

extension AliasTransaction: TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications) -> NSPredicate {
        return NSPredicate(format: "aliasTransaction != NULL AND WAVES IN %@", from.assets)
    }
}

extension MassTransferTransaction: TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications) -> NSPredicate {
        return NSPredicate(format: "massTransferTransaction.assetId IN %@", from.assets)
    }
}

extension BurnTransaction: TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications) -> NSPredicate {
        return NSPredicate(format: "burnTransaction.assetId IN %@", from.assets)
    }
}

extension ExchangeTransaction: TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications) -> NSPredicate {
        return NSPredicate(format: "exchangeTransaction.order1.assetPair.amountAsset IN %@ OR exchangeTransaction.order1.assetPair.priceAsset IN %@ OR exchangeTransaction.order2.assetPair.amountAsset IN %@ OR exchangeTransaction.order2.assetPair.priceAsset IN %@",
                           from.assets,
                           from.assets,
                           from.assets,
                           from.assets)
    }
}

extension DataTransaction: TransactionsSpecificationsConverter {
    static func predicate(_ from: TransactionsSpecifications) -> NSPredicate {
        return NSPredicate(format: "dataTransaction != NULL AND WAVES IN %@", from.assets)
    }
}
