//
//  WalletSortInteractor.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 25/07/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift
import RxRealm

private enum Constants {
    static let stepSize: Float = 0.000000001
}

private extension WalletSort.DTO.Asset {

    static func map(from balance: AssetBalance) -> WalletSort.DTO.Asset {

        let isLock = balance.asset?.isWaves == true
        let isMyAsset = balance.asset?.isMyAsset ?? false
        let isFavorite = balance.settings?.isFavorite ?? false
        let isGateway = balance.asset?.isGateway ?? false
        let isHidden = balance.settings?.isHidden ?? false
        let sortLevel = balance.settings?.sortLevel ?? Float.greatestFiniteMagnitude
        return WalletSort.DTO.Asset(id: balance.assetId,
                                    name: balance.asset?.name ?? "",
                                    isLock: isLock,
                                    isMyAsset: isMyAsset,
                                    isFavorite: isFavorite,
                                    isGateway: isGateway,
                                    isHidden: isHidden,
                                    sortLevel: sortLevel)
    }
}

final class WalletSortInteractor: WalletSortInteractorProtocol {

    func assets() -> Observable<[WalletSort.DTO.Asset]> {

        return Observable.create({ subscribe -> Disposable in

            DispatchQueue.global(qos: .background).async {
                let realm = try! Realm()
                let assets = realm
                    .objects(AssetBalance.self)
                    .filter("asset.isSpam == false")
                    .toArray()
                    .map { WalletSort.DTO.Asset.map(from: $0) }
                subscribe.onNext(assets)
            }
            return Disposables.create()
        })
    }

    func move(asset: WalletSort.DTO.Asset, underAsset: WalletSort.DTO.Asset) {
        move(asset: asset, toAsset: underAsset, shiftSortLevel: Constants.stepSize)
    }
    
    func move(asset: WalletSort.DTO.Asset, overAsset: WalletSort.DTO.Asset) {
        move(asset: asset, toAsset: overAsset, shiftSortLevel: -Constants.stepSize)
    }

    func update(asset: WalletSort.DTO.Asset) {

        DispatchQueue.global(qos: .background).async {
            let realm = try! Realm()
            guard let object = realm
                .object(ofType: AssetBalance.self,
                        forPrimaryKey: asset.id) else { return }
            var sortLevel = object.settings.sortLevel

            if object.settings.isFavorite != asset.isFavorite {

                let objects = realm
                    .objects(AssetBalance.self)
                    .filter("settings.isFavorite == \(asset.isFavorite)")
                    .sorted(byKeyPath: "settings.sortLevel", ascending: true)

                if asset.isFavorite, let object = objects.last {
                    sortLevel = object.settings.sortLevel + Constants.stepSize
                } else if asset.isFavorite == false, let object = objects.first {
                    sortLevel = object.settings.sortLevel - Constants.stepSize
                }
            }

            try? realm.write {
                if asset.isLock == false {
                    object.settings.sortLevel = sortLevel
                    object.settings.isFavorite = asset.isFavorite
                }

                object.settings.isHidden = asset.isHidden && asset.isFavorite == false

                realm.add(object, update: true)
            }
        }
    }

    private func move(asset: WalletSort.DTO.Asset,
                      toAsset: WalletSort.DTO.Asset,
                      shiftSortLevel: Float) {

        DispatchQueue.global(qos: .background).async {
            let realm = try! Realm()
            guard let object = realm
                .object(ofType: AssetBalance.self,
                        forPrimaryKey: asset.id) else { return }
            guard let toObject = realm
                .object(ofType: AssetBalance.self,
                        forPrimaryKey: toAsset.id) else { return }

            try? realm.write {
                object.settings.sortLevel = toObject.settings.sortLevel + shiftSortLevel
                realm.add(object, update: true)
            }
        }
    }
}
