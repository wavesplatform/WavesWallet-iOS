//
//  AssetSettingsInteractor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 29/11/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDKExtension
import WavesSDKCrypto

private enum Constants {
    static let sortLevelNotFound: Float = -1
    static let step: Float = 0.005
}

protocol AssetsBalanceSettingsInteractorProtocol {

    func settings(by accountAddress: String, assets: [DomainLayer.DTO.Asset]) -> Observable<[DomainLayer.DTO.AssetBalanceSettings]>
    func move(by accountAddress: String, assetId: String, underAssetId: String) -> Observable<Bool>
    func move(by accountAddress: String, assetId: String, overAssetId: String) -> Observable<Bool>
    func setFavorite(by accountAddress: String, assetId: String, isFavorite: Bool) -> Observable<Bool>
    func setHidden(by accountAddress: String, assetId: String, isHidden: Bool) -> Observable<Bool>
}

final class AssetsBalanceSettingsInteractor: AssetsBalanceSettingsInteractorProtocol {

    private let assetsBalanceSettingsRepository: AssetsBalanceSettingsRepositoryProtocol
    private let environmentRepository: EnvironmentRepositoryProtocol
    private let authorizationInteractor: AuthorizationInteractorProtocol

    init(assetsBalanceSettingsRepositoryLocal: AssetsBalanceSettingsRepositoryProtocol,
         environmentRepository: EnvironmentRepositoryProtocol,
         authorizationInteractor: AuthorizationInteractorProtocol) {
        
        self.assetsBalanceSettingsRepository = assetsBalanceSettingsRepositoryLocal
        self.environmentRepository = environmentRepository
        self.authorizationInteractor = authorizationInteractor
    }

    func settings(by accountAddress: String, assets: [DomainLayer.DTO.Asset]) -> Observable<[DomainLayer.DTO.AssetBalanceSettings]> {

        return authorizationInteractor.authorizedWallet()
            .flatMap({ [weak self] (wallet) -> Observable<[DomainLayer.DTO.AssetBalanceSettings]> in
               
                guard let self = self else { return Observable.empty() }
                
                return self.environmentRepository.accountEnvironment(accountAddress: wallet.address)
                    .flatMap({ [weak self] (environment) -> Observable<[DomainLayer.DTO.AssetBalanceSettings]> in
                       
                        guard let self = self else { return Observable.empty() }
                        let ids = assets.map { $0.id }

                        let settings = self.assetSettings(assets: assets,
                                                           ids: ids,
                                                           accountAddress: accountAddress,
                                                           environment: environment)
                        .flatMapLatest { [weak self] (settings) -> Observable<Bool> in
                            
                            guard let self = self else { return Observable.never() }
                            return self
                                .assetsBalanceSettingsRepository
                                .saveSettings(by: accountAddress, settings: settings)
                        }
                        .flatMapLatest { [weak self] (settings) -> Observable<[DomainLayer.DTO.AssetBalanceSettings]> in
                            
                            guard let self = self else { return Observable.never() }
                            return self
                                .assetsBalanceSettingsRepository
                                .listenerSettings(by: accountAddress, ids: ids)
                                .map { $0.sorted(by: { $0.sortLevel < $1.sortLevel }) }
                        }
                        
                        return settings
                        
                    })
        })
    }
    
    func move(by accountAddress: String, assetId: String, underAssetId: String) -> Observable<Bool> {

        return assetsBalanceSettingsRepository
            .settings(by: accountAddress, ids: [assetId, underAssetId])
            .flatMapLatest { [weak self] (settingsMap) -> Observable<Bool> in
                guard let self = self else { return Observable.never() }
                guard var asset = settingsMap[assetId] else { return Observable.never() }
                guard let underAsset = settingsMap[underAssetId] else { return Observable.never() }

                asset.sortLevel = underAsset.sortLevel + Constants.step

                return self.assetsBalanceSettingsRepository.saveSettings(by: accountAddress,
                                                                          settings: [asset])
            }
    }

    func move(by accountAddress: String, assetId: String, overAssetId: String) -> Observable<Bool> {

        return assetsBalanceSettingsRepository
            .settings(by: accountAddress, ids: [assetId, overAssetId])
            .flatMap { [weak self] (settingsMap) -> Observable<Bool> in
                guard let self = self else { return Observable.never() }
                guard var asset = settingsMap[assetId] else { return Observable.never() }
                guard let overAssetId = settingsMap[overAssetId] else { return Observable.never() }

                asset.sortLevel = overAssetId.sortLevel - Constants.step

                return self.assetsBalanceSettingsRepository.saveSettings(by: accountAddress,
                                                                         settings: [asset])
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

                if isFavorite {
                    if let topFavorite = sortedSettings.first(where: { $0.isFavorite == true }) {
                        asset.sortLevel = topFavorite.sortLevel + Constants.step
                    }
                    else {
                        asset.sortLevel = Constants.step
                    }
                } else {
                    if let topNotFavorite = sortedSettings.first(where: { $0.isFavorite == false }) {
                        asset.sortLevel = topNotFavorite.sortLevel - Constants.step
                    }
                    else {
                        asset.sortLevel = Constants.step
                    }
                }
                asset.isFavorite = isFavorite
                asset.isHidden = false

                return self.assetsBalanceSettingsRepository.saveSettings(by: accountAddress,
                                                                          settings: [asset])
        }
    }

    func setHidden(by accountAddress: String, assetId: String, isHidden: Bool) -> Observable<Bool> {
        return assetsBalanceSettingsRepository
            .settings(by: accountAddress, ids: [assetId])
            .flatMap { [weak self] (settings) -> Observable<Bool> in

                guard let self = self else { return Observable.never() }
                guard var asset = settings[assetId] else { return Observable.never() }

                asset.isHidden = isHidden
                asset.isFavorite = false

                return self.assetsBalanceSettingsRepository.saveSettings(by: accountAddress,
                                                                         settings: [asset])
        }
    }
}


private extension AssetsBalanceSettingsInteractor {
    
    func assetSettings(assets: [DomainLayer.DTO.Asset], ids: [String], accountAddress: String, environment: Environment) -> Observable<[DomainLayer.DTO.AssetBalanceSettings]> {
        
        let spamIds = assets.reduce(into: [String: Bool](), {$0[$1.id] = $1.isSpam })

        return assetsBalanceSettingsRepository.settings(by: accountAddress, ids: ids)
            .flatMapLatest({ [weak self] (mapSettings) -> Observable<[DomainLayer.DTO.AssetBalanceSettings]> in
                guard let self = self else { return Observable.empty() }
                
                let sortedSettings = mapSettings
                    .reduce(into: [DomainLayer.DTO.AssetBalanceSettings](), { $0.append($1.value) })
                    .filter({ $0.sortLevel != Constants.sortLevelNotFound })
                    .sorted(by: { $0.sortLevel < $1.sortLevel })
                
                let withoutSettingsAssets = assets.reduce(into: [DomainLayer.DTO.Asset](), { (result, asset) in
                    if let settings = mapSettings[asset.id] {
                        if settings.sortLevel == Constants.sortLevelNotFound {
                            result.append(asset)
                        }
                        else if settings.isFavorite && spamIds[settings.assetId] == true {
                            result.append(asset)
                        }
                    } else {
                        result.append(asset)
                    }
                })
                
                let withoutSettingsAssetsSorted = self
                    .sortAssets(assets: withoutSettingsAssets, enviroment: environment)
                    .map { (asset) -> DomainLayer.DTO.AssetBalanceSettings in
                        
                        return DomainLayer.DTO.AssetBalanceSettings(assetId: asset.id,
                                                                    sortLevel: Constants.sortLevelNotFound,
                                                                    isHidden: false,
                                                                    isFavorite: asset.isInitialFavorite)
                }
                
                var settings = [DomainLayer.DTO.AssetBalanceSettings]()
                settings.append(contentsOf: sortedSettings)
                settings.append(contentsOf: withoutSettingsAssetsSorted)
                
                settings = settings
                    .enumerated()
                    .map { (element) -> DomainLayer.DTO.AssetBalanceSettings in
                        let settings = element.element
                        let level = Float(element.offset)
                        let isFavorite = settings.isFavorite && spamIds[settings.assetId] == false
                        return DomainLayer.DTO.AssetBalanceSettings(assetId: settings.assetId,
                                                                    sortLevel: level,
                                                                    isHidden: settings.isHidden,
                                                                    isFavorite: isFavorite)
                }
                
                return Observable.just(settings)
            })
    }
    
    func sortAssets(assets: [DomainLayer.DTO.Asset], enviroment: Environment) -> [DomainLayer.DTO.Asset] {

        let favoriteAssets = assets.filter { $0.isInitialFavorite }.sorted(by: { $0.isWaves && !$1.isWaves })
        let secondsAssets = assets.filter { !$0.isInitialFavorite }
    
        let generalBalances = enviroment.generalAssets

        let sorted = secondsAssets.sorted { (assetFirst, assetSecond) -> Bool in
            
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
        return favoriteAssets + sorted
    }
}

private extension DomainLayer.DTO.Asset {
    var isInitialFavorite: Bool {
        return isWaves || (isMyWavesToken && !isSpam)
    }
}
