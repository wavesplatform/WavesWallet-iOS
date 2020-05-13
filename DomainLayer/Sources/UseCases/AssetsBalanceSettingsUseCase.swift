//
//  AssetSettingsInteractor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 29/11/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDK
import WavesSDKExtensions

private enum Constants {
    static let sortLevelNotFound: Float = -1
}

final class AssetsBalanceSettingsUseCase: AssetsBalanceSettingsUseCaseProtocol {
    private let assetsBalanceSettingsRepository: AssetsBalanceSettingsRepositoryProtocol
    private let environmentRepository: EnvironmentRepositoryProtocol
    private let authorizationInteractor: AuthorizationUseCaseProtocol

    init(assetsBalanceSettingsRepositoryLocal: AssetsBalanceSettingsRepositoryProtocol,
         environmentRepository: EnvironmentRepositoryProtocol,
         authorizationInteractor: AuthorizationUseCaseProtocol) {
        assetsBalanceSettingsRepository = assetsBalanceSettingsRepositoryLocal
        self.environmentRepository = environmentRepository
        self.authorizationInteractor = authorizationInteractor
    }

    func settings(by accountAddress: String,
                  assets: [Asset]) -> Observable<[AssetBalanceSettings]> {
        return environmentRepository
            .walletEnvironment()
            .flatMap { [weak self] (environment) -> Observable<[AssetBalanceSettings]> in

                guard let self = self else { return Observable.empty() }

                let ids = assets.map { $0.id }

                let settings = self
                    .ifNeedCreateDeffaultSettings(accountAddress: accountAddress,
                                                  enviroment: environment)
                    .flatMapLatest { [weak self] settings -> Observable<[AssetBalanceSettings]> in

                        guard let self = self else { return Observable.never() }

                        return self.assetSettings(settings: settings,
                                                  assets: assets,
                                                  ids: ids,
                                                  accountAddress: accountAddress,
                                                  environment: environment)
                    }
                    .flatMapLatest { [weak self] settings -> Observable<Bool> in

                        guard let self = self else { return Observable.never() }
                        return self
                            .assetsBalanceSettingsRepository
                            .saveSettings(by: accountAddress, settings: settings)
                    }
                    .flatMapLatest { [weak self] (_) -> Observable<[AssetBalanceSettings]> in
                        
                        guard let self = self else { return Observable.never() }
                        return self
                            .assetsBalanceSettingsRepository
                            .listenerSettings(by: accountAddress, ids: ids)
                            .map { $0.sorted(by: { $0.sortLevel < $1.sortLevel }) }
                    }

                return settings
            }
    }

    func setFavorite(by accountAddress: String, assetId: String, isFavorite: Bool) -> Observable<Bool> {
        return assetsBalanceSettingsRepository
            .settings(by: accountAddress)
            .flatMap { [weak self] (settings) -> Observable<Bool> in

                guard let self = self else { return Observable.never() }

                let sortedSettings = settings.sorted(by: { $0.sortLevel < $1.sortLevel })

                guard var asset = settings.first(where: { $0.assetId == assetId }) else { return Observable.never() }

                if asset.isFavorite == isFavorite {
                    return Observable.just(true)
                }

                var newSettings = sortedSettings.filter { $0.isFavorite && $0.assetId != assetId }
                let otherList = sortedSettings.filter { $0.isFavorite == false && $0.assetId != assetId }

                asset.isFavorite = isFavorite
                asset.isHidden = false

                newSettings.append(asset)
                newSettings.append(contentsOf: otherList)

                for index in 0 ..< newSettings.count {
                    newSettings[index].sortLevel = Float(index)
                }

                return self.assetsBalanceSettingsRepository.saveSettings(by: accountAddress,
                                                                         settings: newSettings)
            }
    }

    func updateAssetsSettings(by accountAddress: String, settings: [AssetBalanceSettings]) -> Observable<Bool> {
        return assetsBalanceSettingsRepository.saveSettings(by: accountAddress, settings: settings)
    }
}

private extension AssetsBalanceSettingsUseCase {
    func assetSettings(settings: [AssetBalanceSettings],
                       assets: [Asset],
                       ids _: [String],
                       accountAddress _: String,
                       environment: WalletEnvironment) -> Observable<[AssetBalanceSettings]> {
        let spamIds = assets.reduce(into: [String: Bool]()) { $0[$1.id] = $1.isSpam }

        let mapSettings: [String: AssetBalanceSettings] = settings.reduce(into: [:]) { $0[$1.assetId] = $1 }

        let sortedSettings = mapSettings
            .reduce(into: [AssetBalanceSettings]()) { $0.append($1.value) }
            .filter { $0.sortLevel != Constants.sortLevelNotFound }
            .sorted(by: { $0.sortLevel < $1.sortLevel })

        let withoutSettingsAssets = assets.reduce(into: [Asset]()) { result, asset in
            if let settings = mapSettings[asset.id] {
                if settings.sortLevel == Constants.sortLevelNotFound {
                    result.append(asset)
                } else if settings.isFavorite, spamIds[settings.assetId] == true {
                    result.append(asset)
                }
            } else {
                result.append(asset)
            }
        }

        let maxSortLevel = sortedSettings
            .sorted(by: { $0.sortLevel > $1.sortLevel }).first?.sortLevel ?? Constants
            .sortLevelNotFound

        let withoutSettingsAssetsSorted = sortAssets(assets: withoutSettingsAssets, enviroment: environment)
            .enumerated()
            .map { element -> AssetBalanceSettings in

                let index = Float(element.offset + 1)
                let asset = element.element

                return AssetBalanceSettings(assetId: asset.id,
                                                            sortLevel: maxSortLevel + index,
                                                            isHidden: false,
                                                            isFavorite: asset.isInitialFavorite)
            }

        var settings = [AssetBalanceSettings]()
        settings.append(contentsOf: sortedSettings)
        settings.append(contentsOf: withoutSettingsAssetsSorted)

        return Observable.just(settings)
    }

    func sortAssets(assets: [Asset], enviroment: WalletEnvironment) -> [Asset] {
        let favoriteAssets = assets.filter { $0.isInitialFavorite }.sorted(by: { $0.isWaves && !$1.isWaves })
        let secondsAssets = assets.filter { !$0.isInitialFavorite }

        let generalBalances = enviroment.generalAssets

        let sorted = secondsAssets.sorted { (assetFirst, assetSecond) -> Bool in

            let isGeneralFirst = assetFirst.isGeneral
            let isGeneralSecond = assetSecond.isGeneral

            if isGeneralFirst == true, isGeneralSecond == true {
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
        return favoriteAssets + sorted
    }

    func ifNeedCreateDeffaultSettings(accountAddress: String,
                                      enviroment: WalletEnvironment) -> Observable<[AssetBalanceSettings]> {
        return assetsBalanceSettingsRepository
            .settings(by: accountAddress)
            .flatMap { [weak self] settings -> Observable<[AssetBalanceSettings]> in

                guard let self = self else { return Observable.never() }

                if !settings.isEmpty {
                    return Observable.just(settings)
                }

                let assets = enviroment
                    .generalAssets
                    .enumerated()
                    .map { AssetBalanceSettings(assetId: $0.element.assetId,
                                                                sortLevel: Float($0.offset),
                                                                isHidden: false,
                                                                isFavorite: $0.element.assetId == WavesSDKConstants.wavesAssetId)
                    }

                return self.assetsBalanceSettingsRepository
                    .saveSettings(by: accountAddress,
                                  settings: assets)
                    .map { _ in assets }
            }
    }
}

private extension Asset {
    var isInitialFavorite: Bool {
        return isWaves || (isMyWavesToken && !isSpam)
    }
}
