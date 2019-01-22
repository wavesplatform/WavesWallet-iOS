//
//  AssetsRepositoryLocal.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 04/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift
import RxRealm

final class AssetsRepositoryLocal: AssetsRepositoryProtocol {
    
    func assets(by ids: [String], accountAddress: String) -> Observable<[DomainLayer.DTO.Asset]> {
        return Observable.create({ (observer) -> Disposable in

            guard let realm = try? WalletRealmFactory.realm(accountAddress: accountAddress) else {
                observer.onError(AssetsRepositoryError.fail)
                return Disposables.create()
            }

            let objects = realm.objects(Asset.self)
                .filter("id in %@",ids)
                .toArray()

            let newIds = objects.map { $0.id }

            if ids.contains(where: { newIds.contains($0) }) == false {
                observer.onError(AssetsRepositoryError.notFound)
            } else {
                let assets = objects
                    .map { DomainLayer.DTO.Asset($0) }

                observer.onNext(assets)
                observer.onCompleted()
            }

            return Disposables.create()
        })
    }

    func saveAssets(_ assets:[DomainLayer.DTO.Asset], by accountAddress: String) -> Observable<Bool> {
        return Observable.create({ (observer) -> Disposable in

            guard let realm = try? WalletRealmFactory.realm(accountAddress: accountAddress) else {
                observer.onNext(false)
                observer.onError(AssetsRepositoryError.fail)
                return Disposables.create()
            }

            do {
                try realm.write({
                    realm.add(assets.map { Asset(asset: $0) }, update: true)
                })
                observer.onNext(true)
                observer.onCompleted()
            } catch _ {
                observer.onNext(false)
                observer.onError(AssetsRepositoryError.fail)
                return Disposables.create()
            }

            return Disposables.create()
        })
    }

    func saveAsset(_ asset: DomainLayer.DTO.Asset, by accountAddress: String) -> Observable<Bool> {
        return saveAssets([asset], by: accountAddress)
    }

    func isSmartAsset(_ assetId: String, by accountAddress: String) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }
}
