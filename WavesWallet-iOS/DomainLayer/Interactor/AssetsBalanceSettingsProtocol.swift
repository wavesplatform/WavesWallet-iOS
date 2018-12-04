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

    func settings(by accountAddress: String, ids: [String]) -> Observable<[DomainLayer.DTO.AssetBalanceSettings]>
}

final class AssetsBalanceSettingsInteractor: AssetsBalanceSettingsInteractorProtocol {

    private let assetsBalanceSettingsRepository: AssetsBalanceSettingsRepositoryProtocol = FactoryRepositories.instance.assetsBalanceSettingsRepositoryLocal

    func settings(by accountAddress: String, ids: [String]) -> Observable<[DomainLayer.DTO.AssetBalanceSettings]> {

        let enviroments = Environments.current

        let settings = assetsBalanceSettingsRepository
            .settings(by: accountAddress, ids: ids)
            .flatMapLatest { (mapSettings) -> Observable<[DomainLayer.DTO.AssetBalanceSettings]> in

                let sortedSettings = mapSettings
                    .reduce(into: [DomainLayer.DTO.AssetBalanceSettings](), { $0.append($1.value) })
                    .sorted(by: { $0.sortLevel > $1.sortLevel })

                let first = sortedSettings.first
                let last = sortedSettings.last


                return Observable.never()
            }




//        let settings = ids.map { (id) -> DomainLayer.DTO.AssetBalanceSettings in
//            return DomainLayer.DTO.AssetBalanceSettings(assetId: id,
//                                                        sortLevel: 1,
//                                                        isHidden: false,
//                                                        isFavorite: false)
//        }
//

        return Observable.just([])
    }

    private func createSetting(by assetId: String,
                               first: DomainLayer.DTO.AssetBalanceSettings?,
                               last: DomainLayer.DTO.AssetBalanceSettings?,
                               mapSettings: [String: DomainLayer.DTO.AssetBalanceSettings],
                               enviroments: Environment) -> DomainLayer.DTO.AssetBalanceSettings? {

        let enviromentAsset = enviroments.generalAssetIds.enumerated().first(where: { $0.element.assetId == assetId })

        if let enviromentAsset = enviromentAsset {
            let prevIndex =  (enviromentAsset.offset - 1)
            let enviromentAssetPrev = prevIndex >= 0 ? enviroments.generalAssetIds[prevIndex] : nil


        } else {

        }





        return nil
    }
}
