//
//  AssetsBalanceSettingsRepositoryLocal.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 04/12/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift
import RxRealm

final class AssetsBalanceSettingsRepositoryLocal: AssetsBalanceSettingsRepositoryProtocol {

    func removeBalancesSettting(actualIds: [String], accountAddress: String) -> Observable<Bool> {
        
        return Observable.create({ (subscribe) -> Disposable in
            
            do {
                let realm = try WalletRealmFactory.realm(accountAddress: accountAddress)
                let objects = realm.objects(AssetBalanceSettings.self).filter("NOT (assetId  IN %@)", actualIds)
                if objects.count > 0 {
                    try realm.write {
                        realm.delete(objects)
                    }
                }
                subscribe.onNext(true)
            }
            catch _ {
                subscribe.onNext(false)
            }
            
            subscribe.onCompleted()
            return Disposables.create()
        })
    }
    
    func settings(by accountAddress: String, ids: [String]) -> Observable<[String: DomainLayer.DTO.AssetBalanceSettings]> {

        return Observable.create({ (observer) -> Disposable in

            guard let realm = try? WalletRealmFactory.realm(accountAddress: accountAddress) else {
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            let objects = realm.objects(AssetBalanceSettings.self)
                .filter("assetId IN %@",ids)
                .toArray()

            let settings = objects
                .reduce(into: [String: DomainLayer.DTO.AssetBalanceSettings](), { $0[$1.assetId] = DomainLayer.DTO.AssetBalanceSettings($1) })

            observer.onNext(settings)
            observer.onCompleted()

            return Disposables.create()
        })
    }

    func settings(by accountAddress: String) -> Observable<[DomainLayer.DTO.AssetBalanceSettings]> {
        return Observable.create({ (observer) -> Disposable in

            guard let realm = try? WalletRealmFactory.realm(accountAddress: accountAddress) else {
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            let objects = realm.objects(AssetBalanceSettings.self)
                .toArray()

            let settings = objects
                .map { DomainLayer.DTO.AssetBalanceSettings($0) }

            observer.onNext(settings)
            observer.onCompleted()

            return Disposables.create()
        })
    }

    func listenerSettings(by accountAddress: String, ids: [String]) -> Observable<[DomainLayer.DTO.AssetBalanceSettings]> {
        return Observable.create({ (observer) -> Disposable in

            guard let realm = try? WalletRealmFactory.realm(accountAddress: accountAddress) else {
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            let objects = realm.objects(AssetBalanceSettings.self)
                .filter("assetId IN %@",ids)

            let dispose = Observable
                .collection(from: objects)                
                .map({ (results) -> [DomainLayer.DTO.AssetBalanceSettings] in
                    return results
                        .toArray()
                        .map({ (settings) -> DomainLayer.DTO.AssetBalanceSettings in
                            return  DomainLayer.DTO.AssetBalanceSettings(settings)
                        })
                })
                .bind(to: observer)

            return Disposables.create([dispose])
        })        
        .subscribeOn(Schedulers.realmThreadScheduler)
    }

    func saveSettings(by accountAddress: String,
                      settings: [DomainLayer.DTO.AssetBalanceSettings]) -> Observable<Bool> {

        return Observable.create({ observer -> Disposable in

            guard let realm = try? WalletRealmFactory.realm(accountAddress: accountAddress) else {
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            do {
                let settingsRealms = settings.map { AssetBalanceSettings($0) }
                try realm.write {
                    realm.add(settingsRealms, update: true)
                }

                observer.onNext(true)
                observer.onCompleted()
            } catch let error {
                SweetLogger.error(error)
                observer.onError(RepositoryError.fail)
            }
            return Disposables.create()
        })
    }
}

private extension DomainLayer.DTO.AssetBalanceSettings {
    init(_ settings: AssetBalanceSettings) {
        self.assetId = settings.assetId
        self.sortLevel = settings.sortLevel
        self.isHidden = settings.isHidden
        self.isFavorite = settings.isFavorite
    }
}

private extension AssetBalanceSettings {
    convenience init(_ settings: DomainLayer.DTO.AssetBalanceSettings) {
        self.init()
        self.assetId = settings.assetId
        self.sortLevel = settings.sortLevel
        self.isHidden = settings.isHidden
        self.isFavorite = settings.isFavorite
    }
}
