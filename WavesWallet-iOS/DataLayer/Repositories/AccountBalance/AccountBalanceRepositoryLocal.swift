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

    func balances(by accountAddress: String, privateKey: PrivateKeyAccount) -> Observable<[DomainLayer.DTO.AssetBalance]> {
        return Observable.create { (observer) -> Disposable in

            guard let realm = try? Realm() else {
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

    func balance(by id: String) -> Observable<DomainLayer.DTO.AssetBalance> {

        return Observable.create { (observer) -> Disposable in

            guard let realm = try? Realm() else {
                observer.onError(AccountBalanceRepositoryError.fail)
                return Disposables.create()
            }

            if let object = realm.object(ofType: AssetBalance.self, forPrimaryKey: id) {
                let balance = DomainLayer.DTO.AssetBalance(balance: object)
                observer.onNext(balance)
                observer.onCompleted()
            } else {
                observer.onError(AccountBalanceRepositoryError.fail)
            }

            return Disposables.create()
        }
    }

    func saveBalances(_ balances: [DomainLayer.DTO.AssetBalance]) -> Observable<Bool> {
        return Observable.create { (observer) -> Disposable in

            guard let realm = try? Realm() else {
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

    func saveBalance(_ balance: DomainLayer.DTO.AssetBalance) -> Observable<Bool> {
        return self.saveBalances([balance])
    }

    var listenerOfUpdatedBalances: Observable<[DomainLayer.DTO.AssetBalance]> = {
        return Observable<[DomainLayer.DTO.AssetBalance]>.create { (observer) -> Disposable in

            guard let realm = try? Realm() else {
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
    }()
}

fileprivate extension DomainLayer.DTO.AssetBalance.Settings {

    init(settings: AssetBalanceSettings) {
        self.assetId = settings.assetId
        self.sortLevel = settings.sortLevel
        self.isHidden = settings.isHidden
        self.isFavorite = settings.isFavorite
    }
}

fileprivate extension AssetBalanceSettings {

    convenience init(settings: DomainLayer.DTO.AssetBalance.Settings) {
        self.init()
        self.assetId = settings.assetId
        self.sortLevel = settings.sortLevel
        self.isHidden = settings.isHidden
        self.isFavorite = settings.isFavorite
    }
}

fileprivate extension DomainLayer.DTO.AssetBalance {

    init(balance: AssetBalance) {

        self.modified = balance.modified
        self.assetId = balance.assetId
        self.balance = balance.balance
        self.leasedBalance = balance.leasedBalance
        self.inOrderBalance = balance.inOrderBalance

        if let asset = balance.asset {
            self.asset = DomainLayer.DTO.Asset(asset)
        } else {
            self.asset  = nil
        }
        
        if let settings = balance.settings {
            self.settings = .init(settings: settings)
        } else {
            self.settings  = nil
        }
    }
}

fileprivate extension AssetBalance {

    convenience init(balance: DomainLayer.DTO.AssetBalance) {
        self.init()
        self.modified = balance.modified
        self.assetId = balance.assetId
        self.balance = balance.balance
        self.leasedBalance = balance.leasedBalance
        self.inOrderBalance = balance.inOrderBalance

        if let asset = balance.asset {
            self.asset = Asset(asset: asset)
        }

        if let settings = balance.settings {
            self.settings = AssetBalanceSettings(settings: settings)
        }
    }
}
