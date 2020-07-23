//
//  AssetsRepositoryLocal.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 04/08/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Foundation
import RealmSwift
import RxRealm
import RxSwift
import WavesSDKExtensions

final class AssetsRepositoryDAOImp: AssetsDAO {

    func assets(serverEnvironment: ServerEnvironment, ids: [String], accountAddress: String) -> Observable<[Asset]> {
        Observable.create { observer -> Disposable in
            guard let realm = try? WalletRealmFactory.realm(accountAddress: accountAddress) else {
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            let objects = realm.objects(AssetRealm.self).filter("id in %@", ids).toArray()

            let newIds = objects.map { $0.id }

            if !ids.contains(where: { newIds.contains($0) }) {
                observer.onError(RepositoryError.notFound)
            } else {
                let assets = objects.map { Asset($0) }

                observer.onNext(assets)
                observer.onCompleted()
            }

            return Disposables.create()
        }
    }

    func saveAssets(_ assets: [Asset], by accountAddress: String) -> Observable<Bool> {
        Observable.create { observer -> Disposable in
            guard let realm = try? WalletRealmFactory.realm(accountAddress: accountAddress) else {
                observer.onNext(false)
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            do {
                try realm.write {
                    let objects = assets.map { AssetRealm(asset: $0) }
                    realm.add(objects, update: .all)
                }
                observer.onNext(true)
                observer.onCompleted()
            } catch _ {
                observer.onNext(false)
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            return Disposables.create()
        }
    }

    func saveAsset(_ asset: Asset, by accountAddress: String) -> Observable<Bool> {
        saveAssets([asset], by: accountAddress)
    }
}
