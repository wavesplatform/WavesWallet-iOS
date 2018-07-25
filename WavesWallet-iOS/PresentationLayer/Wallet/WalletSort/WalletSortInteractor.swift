//
//  WalletSortInteractor.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 25/07/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol WalletSortInteractorProtocol {

    func assets() -> Observable<[WalletSort.DTO.Asset]>
}

final class WalletSortInteractorMock: WalletSortInteractorProtocol {

    func assets() -> Observable<[WalletSort.DTO.Asset]> {

        let waves = WalletSort.DTO.Asset.init(id: "WAVES",
                                              name: "Waves",
                                              isLock: true,
                                              isMyAsset: true,
                                              isFavorite: true,
                                              isFiat: false,
                                              sortLevel: 1)

        let favorite = WalletSort.DTO.Asset.init(id: "Favorite",
                                              name: "Favorite",
                                              isLock: false,
                                              isMyAsset: false,
                                              isFavorite: true,
                                              isFiat: false,
                                              sortLevel: 2)

        let asset1 = WalletSort.DTO.Asset.init(id: "Asset1",
                                                 name: "Asset1",
                                                 isLock: false,
                                                 isMyAsset: false,
                                                 isFavorite: false,
                                                 isFiat: false,
                                                 sortLevel: 3)

        let asset2 = WalletSort.DTO.Asset.init(id: "Asset2",
                                               name: "Asset2",
                                               isLock: false,
                                               isMyAsset: false,
                                               isFavorite: false,
                                               isFiat: false,
                                               sortLevel: 3)

        return Observable.just([waves,
                                favorite,
                                asset1,
                                asset2])
    }
}
