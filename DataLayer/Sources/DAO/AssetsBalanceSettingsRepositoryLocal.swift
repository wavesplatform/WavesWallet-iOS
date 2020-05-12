//
//  AssetsBalanceSettingsRepositoryLocal.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 04/12/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import RealmSwift
import RxCocoa
import RxRealm
import RxSwift
import WavesSDKExtensions

final class AssetsBalanceSettingsRepositoryLocal: AssetsBalanceSettingsRepositoryProtocol {
    func removeBalancesSettting(actualIds: [String], accountAddress: String) -> Observable<Bool> {
        Observable.create { subscribe -> Disposable in
            do {
                let realm = try WalletRealmFactory.realm(accountAddress: accountAddress)
                let objects = realm.objects(AssetBalanceSettingsRealm.self).filter("NOT (assetId  IN %@)", actualIds)
                if !objects.isEmpty {
                    try realm.write {
                        realm.delete(objects)
                    }
                }
                subscribe.onNext(true)
            } catch {
                subscribe.onNext(false)
            }

            subscribe.onCompleted()
            return Disposables.create()
        }
        .subscribeOn(Schedulers.realmThreadScheduler)
    }

    func settings(by accountAddress: String, ids: [String]) -> Observable<[String: AssetBalanceSettings]> {
        Observable.create { observer -> Disposable in

            guard let realm = try? WalletRealmFactory.realm(accountAddress: accountAddress) else {
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            let objects = realm.objects(AssetBalanceSettingsRealm.self).filter("assetId IN %@", ids)
                .toArray()

            let settings = objects.reduce(into: [String: AssetBalanceSettings]()) {
                $0[$1.assetId] = AssetBalanceSettings($1)
            }

            observer.onNext(settings)
            observer.onCompleted()

            return Disposables.create()
        }
        .subscribeOn(Schedulers.realmThreadScheduler)
    }

    func settings(by accountAddress: String) -> Observable<[AssetBalanceSettings]> {
        Observable.create { observer -> Disposable in

            guard let realm = try? WalletRealmFactory.realm(accountAddress: accountAddress) else {
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            let objects = realm.objects(AssetBalanceSettingsRealm.self).toArray()

            let settings = objects.map { AssetBalanceSettings($0) }

            observer.onNext(settings)
            observer.onCompleted()

            return Disposables.create()
        }
        .subscribeOn(Schedulers.realmThreadScheduler)
    }

    func listenerSettings(by accountAddress: String, ids: [String]) -> Observable<[AssetBalanceSettings]> {
        Observable.create { observer -> Disposable in

            guard let realm = try? WalletRealmFactory.realm(accountAddress: accountAddress) else {
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            let objects = realm.objects(AssetBalanceSettingsRealm.self).filter("assetId IN %@", ids)

            // TODO: - .bind(to: observer) странное поведение
            let dispose = Observable
                .collection(from: objects)
                .map { results -> [AssetBalanceSettings] in
                    results.toArray().map { AssetBalanceSettings($0) }
                }
                .bind(to: observer)

            return Disposables.create([dispose])
        }
        .subscribeOn(Schedulers.realmThreadScheduler)
    }

    func saveSettings(by accountAddress: String,
                      settings: [AssetBalanceSettings]) -> Observable<Bool> {
        Observable.create { observer -> Disposable in

            guard let realm = try? WalletRealmFactory.realm(accountAddress: accountAddress) else {
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            do {
                let settingsRealms = settings.map { AssetBalanceSettingsRealm($0) }
                try realm.write {
                    realm.add(settingsRealms,
                              update: .all)
                }

                observer.onNext(true)
                observer.onCompleted()
            } catch {
                SweetLogger.error(error)
                observer.onError(RepositoryError.fail)
            }
            return Disposables.create()
        }
        .subscribeOn(Schedulers.realmThreadScheduler)
    }
}

private extension AssetBalanceSettings {
    init(_ settings: AssetBalanceSettingsRealm) {
        self.init(assetId: settings.assetId,
                  sortLevel: settings.sortLevel,
                  isHidden: settings.isHidden,
                  isFavorite: settings.isFavorite)
    }
}

private extension AssetBalanceSettingsRealm {
    convenience init(_ settings: AssetBalanceSettings) {
        self.init()
        self.assetId = settings.assetId
        self.sortLevel = settings.sortLevel
        self.isHidden = settings.isHidden
        self.isFavorite = settings.isFavorite
    }
}
