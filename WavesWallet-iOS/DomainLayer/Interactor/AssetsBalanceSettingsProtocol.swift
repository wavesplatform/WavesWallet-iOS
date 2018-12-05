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
    func move(by accountAddress: String, assetId: String, underAssetId: String) -> Observable<Bool>
    func move(by accountAddress: String, assetId: String, overAssetId: String) -> Observable<Bool>
    func setFavorite(by accountAddress: String, assetId: String, isFavorite: Bool) -> Observable<Bool>
    func setHidden(by accountAddress: String, assetId: String, isHidden: Bool) -> Observable<Bool>
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
                    .filter({ $0.sortLevel != Constants.sortLevelNotFound })
                    .sorted(by: { $0.sortLevel < $1.sortLevel })

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
            .flatMapLatest { [weak self] (settings) -> Observable<Bool> in

                guard let owner = self else { return Observable.never() }
                return owner
                    .assetsBalanceSettingsRepository
                    .saveSettings(by: accountAddress, settings: settings)
            }
            .flatMapLatest { [weak self] (settings) -> Observable<[DomainLayer.DTO.AssetBalanceSettings]> in

                guard let owner = self else { return Observable.never() }
                return owner
                    .assetsBalanceSettingsRepository
                    .listenerSettings(by: accountAddress, ids: ids)
                    .map { $0.sorted(by: { $0.sortLevel < $1.sortLevel }) }
            }

        return settings
    }

    func move(by accountAddress: String, assetId: String, underAssetId: String) -> Observable<Bool> {

        return assetsBalanceSettingsRepository
            .settings(by: accountAddress, ids: [assetId, underAssetId])
            .flatMapLatest { [weak self] (settingsMap) -> Observable<Bool> in
                guard let owner = self else { return Observable.never() }
                guard var asset = settingsMap[assetId] else { return Observable.never() }
                guard let underAsset = settingsMap[underAssetId] else { return Observable.never() }

                asset.sortLevel = underAsset.sortLevel + 0.005

                return owner.assetsBalanceSettingsRepository.saveSettings(by: accountAddress,
                                                                          settings: [asset])
            }
    }

    func move(by accountAddress: String, assetId: String, overAssetId: String) -> Observable<Bool> {

        return assetsBalanceSettingsRepository
            .settings(by: accountAddress, ids: [assetId, overAssetId])
            .flatMap { [weak self] (settingsMap) -> Observable<Bool> in
                guard let owner = self else { return Observable.never() }
                guard var asset = settingsMap[assetId] else { return Observable.never() }
                guard let overAssetId = settingsMap[overAssetId] else { return Observable.never() }

                asset.sortLevel = overAssetId.sortLevel - 0.005

                return owner.assetsBalanceSettingsRepository.saveSettings(by: accountAddress,
                                                                          settings: [asset])
        }
    }

    func setFavorite(by accountAddress: String, assetId: String, isFavorite: Bool) -> Observable<Bool> {

        return assetsBalanceSettingsRepository
            .settings(by: accountAddress)
            .flatMap { [weak self] (settings) -> Observable<Bool> in

                guard let owner = self else { return Observable.never() }

                let sortedSettings = settings.sorted(by: { $0.sortLevel < $1.sortLevel })

                guard var asset = settings.first(where: { $0.assetId == assetId }) else { return Observable.never() }

                if isFavorite {
                    guard let topFavorite = sortedSettings.first(where: { $0.isFavorite == true }) else { return Observable.never() }
                    asset.sortLevel = topFavorite.sortLevel - 0.005
                } else {
                    guard let topNotFavorite = sortedSettings.first(where: { $0.isFavorite == true }) else { return Observable.never() }
                    asset.sortLevel = topNotFavorite.sortLevel + 0.005
                }
                asset.isFavorite = isFavorite

                return owner.assetsBalanceSettingsRepository.saveSettings(by: accountAddress,
                                                                          settings: [asset])
        }
    }

    func setHidden(by accountAddress: String, assetId: String, isHidden: Bool) -> Observable<Bool> {
        return assetsBalanceSettingsRepository
            .settings(by: accountAddress, ids: [assetId])
            .flatMap { [weak self] (settings) -> Observable<Bool> in

                guard let owner = self else { return Observable.never() }
                guard var asset = settings[assetId] else { return Observable.never() }

                asset.isHidden = isHidden

                return owner.assetsBalanceSettingsRepository.saveSettings(by: accountAddress,
                                                                          settings: [asset])
        }
    }
}


extension AssetsBalanceSettingsInteractor {

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
