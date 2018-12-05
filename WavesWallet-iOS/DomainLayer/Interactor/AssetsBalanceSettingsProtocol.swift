//
//  AssetSettingsInteractor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 29/11/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

private enum Constants {
    static let sortLevelNotFound: Float = -1
}

protocol AssetsBalanceSettingsInteractorProtocol {

    func settings(by accountAddress: String, assets: [DomainLayer.DTO.Asset]) -> Observable<[DomainLayer.DTO.AssetBalanceSettings]>
}

final class AssetsBalanceSettingsInteractor: AssetsBalanceSettingsInteractorProtocol {

    private let assetsBalanceSettingsRepository: AssetsBalanceSettingsRepositoryProtocol = FactoryRepositories.instance.assetsBalanceSettingsRepositoryLocal

    func settings(by accountAddress: String, assets: [DomainLayer.DTO.Asset]) -> Observable<[DomainLayer.DTO.AssetBalanceSettings]> {

        let enviroment = Environments.current

        let ids = assets.map { $0.id }

        let settings = assetsBalanceSettingsRepository
            .settings(by: accountAddress, ids: ids)
            .flatMapLatest { [weak self] (mapSettings) -> Observable<[DomainLayer.DTO.AssetBalanceSettings]> in

                guard let owner = self else { return Observable.never() }

                let sortedSettings = mapSettings
                    .reduce(into: [DomainLayer.DTO.AssetBalanceSettings](), { $0.append($1.value) })
                    .filter({ $0.sortLevel !    = Constants.sortLevelNotFound })
                    .sorted(by: { $0.sortLevel > $1.sortLevel })

                let withoutSettingsAssets = assets.reduce(into: [DomainLayer.DTO.Asset](), { (result, asset) in
                    if let settings = mapSettings[asset.id] {
                        if settings.sortLevel == Constants.sortLevelNotFound {
                            result.append(asset)
                        }
                    } else {
                        result.append(asset)
                    }
                })

                let withoutSettingsAssetsSorted = owner
                    .sort(assets: withoutSettingsAssets, enviroment: enviroment)
                    .map { (asset) -> DomainLayer.DTO.AssetBalanceSettings in
                        return DomainLayer.DTO.AssetBalanceSettings(assetId: asset.id,
                                                                    sortLevel: Constants.sortLevelNotFound,
                                                                    isHidden: false,
                                                                    isFavorite: asset.isWaves == true)
                    }

                var settings = [DomainLayer.DTO.AssetBalanceSettings]()
                settings.append(contentsOf: sortedSettings)
                settings.append(contentsOf: withoutSettingsAssetsSorted)

                settings = settings
                    .enumerated()
                    .map { (element) -> DomainLayer.DTO.AssetBalanceSettings in
                        let settings = element.element
                        let level = Float(element.offset)

                        return DomainLayer.DTO.AssetBalanceSettings(assetId: settings.assetId,
                                                                    sortLevel: level,
                                                                    isHidden: settings.isHidden,
                                                                    isFavorite: settings.isFavorite)
                    }

                return Observable.just(settings)
            }
            .flatMapLatest { [weak self] (settings) -> Observable<[DomainLayer.DTO.AssetBalanceSettings]> in

                guard let owner = self else { return Observable.never() }
                return owner
                    .assetsBalanceSettingsRepository
                    .saveSettings(by: accountAddress, settings: settings)
                    .map { _ in settings}
            }

        return settings
    }

    private func sort(assets: [DomainLayer.DTO.Asset], enviroment: Environment) -> [DomainLayer.DTO.Asset] {

        let generalBalances = enviroment.generalAssetIds

        return assets.sorted { (assetFirst, assetSecond) -> Bool in

            let isGeneralFirst = assetFirst.isGeneral
            let isGeneralSecond = assetSecond.isGeneral

            if isGeneralFirst == true && isGeneralSecond == true {
                let indexOne = generalBalances
                    .enumerated()
                    .first(where: { $0.element.assetId == assetFirst.id })
                    .map { $0.offset }

                let indexTwo = generalBalances
                    .enumerated()
                    .first(where: { $0.element.assetId == assetSecond.id })
                    .map { $0.offset }

                if let indexOne = indexOne, let indexTwo = indexTwo {
                    return indexOne < indexTwo
                }
                return false
            }

            if isGeneralFirst {
                return true
            }
            return false
        }
    }
}
