//
//  AccountBalanceRepositoryLocal.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 05/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift
import RxRealm
import RxSwift

final class AccountBalanceRepositoryLocal: AccountBalanceRepositoryProtocol {

    func balances(by wallet: DomainLayer.DTO.SignedWallet) -> Observable<[DomainLayer.DTO.AssetBalance]> {
        return Observable.create { (observer) -> Disposable in

            guard let realm = try? WalletRealmFactory.realm(accountAddress: wallet.address) else {
                observer.onError(AccountBalanceRepositoryError.fail)
                return Disposables.create()
            }

            let objects = realm.objects(AssetBalance.self)
                .toArray()
                .map { DomainLayer.DTO.AssetBalance(balance: $0) }

            observer.onNext(objects)
            observer.onCompleted()

            return Disposables.create()
        }
    }

    func balance(by assetId: String, accountAddress: String) -> Observable<DomainLayer.DTO.AssetBalance> {

        return Observable.create { (observer) -> Disposable in

            guard let realm = try? WalletRealmFactory.realm(accountAddress: accountAddress) else {
                observer.onError(AccountBalanceRepositoryError.fail)
                return Disposables.create()
            }

            if let object = realm.object(ofType: AssetBalance.self, forPrimaryKey: assetId) {
                let balance = DomainLayer.DTO.AssetBalance(balance: object)
                observer.onNext(balance)
                observer.onCompleted()
            } else {
                observer.onError(AccountBalanceRepositoryError.fail)
            }

            return Disposables.create()
        }
    }

    func saveBalances(_ balances: [DomainLayer.DTO.AssetBalance], accountAddress: String) -> Observable<Bool> {
        return Observable.create { (observer) -> Disposable in

            guard let realm = try? WalletRealmFactory.realm(accountAddress: accountAddress) else {
                observer.onNext(false)
                observer.onError(AccountBalanceRepositoryError.fail)
                return Disposables.create()
            }

            do {
                try realm.write {
                    realm.add(balances.map { AssetBalance(balance: $0) }, update: true)
                }
                observer.onNext(true)
                observer.onCompleted()
            } catch _ {
                observer.onNext(false)
                observer.onError(AccountBalanceRepositoryError.fail)
                return Disposables.create()
            }

            return Disposables.create()
        }
    }

    func deleteBalances(_ balances:[DomainLayer.DTO.AssetBalance], accountAddress: String) -> Observable<Bool> {
        return Observable.create { (observer) -> Disposable in

            guard let realm = try? WalletRealmFactory.realm(accountAddress: accountAddress) else {
                observer.onNext(false)
                observer.onError(AccountBalanceRepositoryError.fail)
                return Disposables.create()
            }

            do {
                let ids = balances.map { $0.assetId }
                let objects = realm.objects(AssetBalance.self).filter("assetId IN %@", ids)
                try realm.write {
                    realm.delete(objects)            
                }
                observer.onNext(true)
                observer.onCompleted()
            } catch let e {
                SweetLogger.error(e)
                observer.onNext(false)
                observer.onError(AccountBalanceRepositoryError.fail)
                return Disposables.create()
            }

            return Disposables.create()
        }
    }

    func saveBalance(_ balance: DomainLayer.DTO.AssetBalance, accountAddress: String) -> Observable<Bool> {
        return self.saveBalances([balance], accountAddress: accountAddress)
    }

    func listenerOfUpdatedBalances(by accountAddress: String) -> Observable<[DomainLayer.DTO.AssetBalance]> {

        return Observable<[DomainLayer.DTO.AssetBalance]>
            .create { (observer) -> Disposable in

            guard let realm = try? WalletRealmFactory.realm(accountAddress: accountAddress) else {
                observer.onError(AccountBalanceRepositoryError.fail)
                return Disposables.create()
            }

            let result = realm.objects(AssetBalance.self)
            let collection = Observable.collection(from: result)
                .skip(1)
                .map { $0.toArray() }
                .map { $0.map { DomainLayer.DTO.AssetBalance(balance: $0) } }
                .bind(to: observer)

            return Disposables.create {
                collection.dispose()
            }
        }
        .subscribeOn(Schedulers.realmThreadScheduler)
    }
}

fileprivate extension DomainLayer.DTO.AssetBalance {

    init(balance: AssetBalance) {

        self.modified = balance.modified
        self.assetId = balance.assetId
        self.totalBalance = balance.balance
        self.leasedBalance = balance.leasedBalance
        self.inOrderBalance = balance.inOrderBalance
        self.sponsorBalance = balance.sponsorBalance
    }
}

fileprivate extension AssetBalance {

    convenience init(balance: DomainLayer.DTO.AssetBalance) {
        self.init()
        self.modified = balance.modified
        self.assetId = balance.assetId
        self.balance = balance.totalBalance
        self.leasedBalance = balance.leasedBalance
        self.inOrderBalance = balance.inOrderBalance
        self.sponsorBalance = balance.sponsorBalance
    }
}
