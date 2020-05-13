//
//  AccountBalanceRepositoryLocal.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 05/08/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RealmSwift
import RxRealm
import RxSwift
import WavesSDKExtensions
import DomainLayer
import Extensions

final class AccountBalanceRepositoryLocal: AccountBalanceRepositoryProtocol {

    func balances(by serverEnviroment: ServerEnvironment,
                  wallet: DomainLayer.DTO.SignedWallet) -> Observable<[AssetBalance]> {
        return Observable.create { (observer) -> Disposable in

            guard let realm = try? WalletRealmFactory.realm(accountAddress: wallet.address) else {
                observer.onError(AccountBalanceRepositoryError.fail)
                return Disposables.create()
            }

            let objects = realm.objects(AssetBalanceRealm.self)
                .toArray()
                .map { AssetBalance(balance: $0) }

            observer.onNext(objects)
            observer.onCompleted()

            return Disposables.create()
        }
    }

    func balance(by serverEnviroment: ServerEnvironment,
                 assetId: String,
                 wallet: DomainLayer.DTO.SignedWallet) -> Observable<AssetBalance> {

        return Observable.create { (observer) -> Disposable in

            guard let realm = try? WalletRealmFactory.realm(accountAddress: wallet.address) else {
                observer.onError(AccountBalanceRepositoryError.fail)
                return Disposables.create()
            }

            if let object = realm.object(ofType: AssetBalanceRealm.self, forPrimaryKey: assetId) {
                let balance = AssetBalance(balance: object)
                observer.onNext(balance)
                observer.onCompleted()
            } else {
                observer.onError(AccountBalanceRepositoryError.fail)
            }

            return Disposables.create()
        }
    }

    func saveBalances(_ balances: [AssetBalance], accountAddress: String) -> Observable<Bool> {
        return Observable.create { (observer) -> Disposable in

            guard let realm = try? WalletRealmFactory.realm(accountAddress: accountAddress) else {
                observer.onNext(false)
                observer.onError(AccountBalanceRepositoryError.fail)
                return Disposables.create()
            }

            do {
                try realm.write {
                    realm.add(balances.map { AssetBalanceRealm(balance: $0) }, update: .all)
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

    func deleteBalances(_ balances:[AssetBalance], accountAddress: String) -> Observable<Bool> {
        return Observable.create { (observer) -> Disposable in

            guard let realm = try? WalletRealmFactory.realm(accountAddress: accountAddress) else {
                observer.onNext(false)
                observer.onError(AccountBalanceRepositoryError.fail)
                return Disposables.create()
            }

            do {
                let ids = balances.map { $0.assetId }
                let objects = realm.objects(AssetBalanceRealm.self).filter("assetId IN %@", ids)
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

    func saveBalance(_ balance: AssetBalance, accountAddress: String) -> Observable<Bool> {
        return self.saveBalances([balance], accountAddress: accountAddress)
    }

    func listenerOfUpdatedBalances(by accountAddress: String) -> Observable<[AssetBalance]> {

        return Observable<[AssetBalance]>
            .create { (observer) -> Disposable in

            guard let realm = try? WalletRealmFactory.realm(accountAddress: accountAddress) else {
                observer.onError(AccountBalanceRepositoryError.fail)
                return Disposables.create()
            }
            // TODO: - .bind(to: observer) странное поведение
            let result = realm.objects(AssetBalanceRealm.self)
            // TODO: - .bind(to: observer) странное поведение
            let collection = Observable.collection(from: result)
                .skip(1)
                .map { $0.toArray() }
                .map { $0.map { AssetBalance(balance: $0) } }
                .bind(to: observer)

            return Disposables.create {
                collection.dispose()
            }
        }
        .subscribeOn(Schedulers.realmThreadScheduler)
    }
}

fileprivate extension AssetBalance {

    init(balance: AssetBalanceRealm) {

        self.init(assetId: balance.assetId,
                  totalBalance: balance.balance,
                  leasedBalance: balance.leasedBalance,
                  inOrderBalance: balance.inOrderBalance,
                  modified: balance.modified,
                  sponsorBalance: balance.sponsorBalance,
                  minSponsoredAssetFee: balance.minSponsoredAssetFee)
    }
}

fileprivate extension AssetBalanceRealm {

    convenience init(balance: AssetBalance) {
        self.init()
        self.modified = balance.modified
        self.assetId = balance.assetId
        self.balance = balance.totalBalance
        self.leasedBalance = balance.leasedBalance
        self.inOrderBalance = balance.inOrderBalance
        self.sponsorBalance = balance.sponsorBalance
        self.minSponsoredAssetFee = balance.minSponsoredAssetFee
    }
}
