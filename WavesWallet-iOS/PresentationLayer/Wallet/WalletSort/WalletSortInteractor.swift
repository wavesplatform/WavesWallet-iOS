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

protocol WalletSortInteractorProtocol {

    func assets() -> Observable<[WalletSort.DTO.Asset]>
    
}

private extension WalletSort.DTO.Asset {

    static func map(from balance: AssetBalance) -> WalletSort.DTO.Asset {

        let isLock = balance.asset?.isWaves == true
        let isMyAsset = balance.asset?.isMyAsset ?? false
        let isFavorite = balance.settings?.isFavorite ?? false
        let isGateway = balance.asset?.isGateway ?? false
        let isHidden = balance.settings?.isHidden ?? false

        return WalletSort.DTO.Asset(id: balance.assetId,
                                    name: balance.asset?.name ?? "",
                                    isLock: isLock,
                                    isMyAsset: isMyAsset,
                                    isFavorite: isFavorite,
                                    isGateway: isGateway,
                                    isHidden: isHidden)
    }
}

final class WalletSortInteractor: WalletSortInteractorProtocol {

    private let realm = try! Realm()

    func assets() -> Observable<[WalletSort.DTO.Asset]> {
        return Observable.collection(from: realm.objects(AssetBalance.self))
            .map { $0.toArray() }
            .map { $0.map { WalletSort.DTO.Asset.map(from: $0) } }
    }
}

final class WalletSortInteractorMock: WalletSortInteractorProtocol {

    func assets() -> Observable<[WalletSort.DTO.Asset]> { 

        let waves = WalletSort.DTO.Asset.init(id: "WAVES",
                                              name: "Waves",
                                              isLock: true,
                                              isMyAsset: true,
                                              isFavorite: true,
                                              isGateway: false,
                                              isHidden: false)

        let favorite = WalletSort.DTO.Asset.init(id: "Favorite",
                                              name: "Favorite",
                                              isLock: false,
                                              isMyAsset: false,
                                              isFavorite: true,
                                              isGateway: true,
                                              isHidden: false)

        let asset1 = WalletSort.DTO.Asset.init(id: "Asset1",
                                                 name: "Asset1",
                                                 isLock: false,
                                                 isMyAsset: false,
                                                 isFavorite: false,
                                                 isGateway: false,
                                                 isHidden: false)

        let asset2 = WalletSort.DTO.Asset.init(id: "Asset2",
                                               name: "Asset2",
                                               isLock: false,
                                               isMyAsset: false,
                                               isFavorite: false,
                                               isGateway: false,
                                               isHidden: true)

        return Observable.just([waves,
                                favorite,
                                asset1,
                                asset2,
                                asset2,
                                asset2,
                                asset2,
                                asset2])
    }
}
