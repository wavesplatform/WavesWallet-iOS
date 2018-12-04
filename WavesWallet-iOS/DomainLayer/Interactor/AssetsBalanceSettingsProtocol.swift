//
//  AssetSettingsInteractor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 29/11/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol AssetsBalanceSettingsInteractorProtocol {

    func settings(by ids: [String]) -> Observable<[DomainLayer.DTO.AssetBalanceSettings]>
}

final class AssetsBalanceSettingsInteractor: AssetsBalanceSettingsInteractorProtocol {

    private let assetsBalanceSettingsRepository: AssetsBalanceSettingsRepositoryProtocol = FactoryRepositories.instance.assetsBalanceSettingsRepositoryLocal

    func settings(by ids: [String]) -> Observable<[DomainLayer.DTO.AssetBalanceSettings]> {

        let settings = ids.map { (id) -> DomainLayer.DTO.AssetBalanceSettings in
            return DomainLayer.DTO.AssetBalanceSettings(assetId: id,
                                                        sortLevel: 1,
                                                        isHidden: false,
                                                        isFavorite: false)
        }


        return Observable.just(settings)
    }
}
