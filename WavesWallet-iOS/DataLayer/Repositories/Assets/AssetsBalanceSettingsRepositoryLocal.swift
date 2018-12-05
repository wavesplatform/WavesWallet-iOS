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

enum RepositoryError: Error {
    case fail
    case notFound
}

extension Float {
    var notFound: Float {
        return -1
    }
}

protocol AssetsBalanceSettingsRepositoryProtocol {
    func settings(by accountAddress: String, ids: [String]) -> Observable<[String: DomainLayer.DTO.AssetBalanceSettings]>
    func saveSettings(by accountAddress: String, settings: [DomainLayer.DTO.AssetBalanceSettings]) -> Observable<Bool>
}

final class AssetsBalanceSettingsRepositoryLocal: AssetsBalanceSettingsRepositoryProtocol {

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

    func saveSettings(by accountAddress: String,
                      settings: [DomainLayer.DTO.AssetBalanceSettings]) -> Observable<Bool> {

        return Observable.create({ observer -> Disposable in

            guard let realm = try? WalletRealmFactory.realm(accountAddress: accountAddress) else {
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            do {
                try realm.write {
                    settings.forEach({ (settings) in
                        realm.add(AssetBalanceSettings(settings))
                    })
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
