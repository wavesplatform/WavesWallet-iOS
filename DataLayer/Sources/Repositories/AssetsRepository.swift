//
//  AssetsRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 04/08/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import CSV
import DomainLayer
import Extensions
import Foundation
import Moya
import RxSwift
import WavesSDK
import WavesSDKExtensions

private enum Constants {
    static let searchAssetsLimit: Int = 100
    static let vostokAssetDescription = "Waves Enterprise System Token."
    static let vostokAssetId = "Vostok"
}

final class AssetsRepository: AssetsRepositoryProtocol {
    private let wavesSDKServices: WavesSDKServices

    private let environmentRepository: EnvironmentRepositoryProtocol

    private let spamAssetsRepository: SpamAssetsRepositoryProtocol

    private let accountSettingsRepository: AccountSettingsRepositoryProtocol

    private let serverEnvironmentRepository: ServerEnvironmentRepository

    init(spamAssetsRepository: SpamAssetsRepositoryProtocol,
         accountSettingsRepository: AccountSettingsRepositoryProtocol,
         environmentRepository: EnvironmentRepositoryProtocol,
         serverEnvironmentRepository: ServerEnvironmentRepository,
         wavesSDKServices: WavesSDKServices) {
        self.wavesSDKServices = wavesSDKServices
        self.spamAssetsRepository = spamAssetsRepository
        self.accountSettingsRepository = accountSettingsRepository
        self.environmentRepository = environmentRepository
        self.serverEnvironmentRepository = serverEnvironmentRepository
    }

    func assets(ids: [String],
                accountAddress: String) -> Observable<[Asset?]> {
        return serverEnvironmentRepository
            .serverEnvironment()
            .flatMap { [weak self] serverEnvironment -> Observable<[Asset?]> in

                guard let self = self else { return Observable.never() }

                let wavesServices = self.wavesSDKServices.wavesServices(environment: serverEnvironment)

                let walletEnvironment = self.environmentRepository.walletEnvironment()

                let spamAssets = self.spamAssets(accountAddress: accountAddress)

                let assetsList = wavesServices.dataServices.assetsDataService.assets(ids: ids)

                return Observable.zip(assetsList, spamAssets, walletEnvironment)
                    .map { assets, spamAssets, walletEnvironment -> [Asset?] in

                        let map = walletEnvironment.hashMapAssets()
                        let mapGeneralAssets = walletEnvironment.hashMapGeneralAssets()

                        print("ids \(ids)")
                        let spamIds = spamAssets.reduce(into: [String: Bool]()) { $0[$1] = true }
                        
                        return assets.map { asset -> Asset? in

                            guard let asset = asset else { return nil }

                            return Asset(asset: asset,
                                         info: map[asset.id],
                                         isSpam: spamIds[asset.id] == true,
                                         isMyWavesToken: asset.sender == accountAddress,
                                         isGeneral: mapGeneralAssets[asset.id] != nil)
                        }
                    }
            }
    }

    func searchAssets(search: String,
                      accountAddress: String) -> Observable<[Asset]> {
        return serverEnvironmentRepository
            .serverEnvironment()
            .flatMap { [weak self] serverEnvironment -> Observable<[Asset]> in

                guard let self = self else { return Observable.never() }

                let wavesServices = self.wavesSDKServices
                    .wavesServices(environment: serverEnvironment)

                let walletEnvironment = self.environmentRepository.walletEnvironment()

                let spamAssets = self.spamAssets(accountAddress: accountAddress)

                let assetsList =
                    wavesServices
                        .dataServices
                        .assetsDataService
                        .searchAssets(search: search, limit: Constants.searchAssetsLimit)

                return Observable.zip(assetsList, spamAssets, walletEnvironment)
                    .map { assets, spamAssets, walletEnvironment -> [Asset] in

                        let map = walletEnvironment.hashMapAssets()
                        let mapGeneralAssets = walletEnvironment.hashMapGeneralAssets()
                        let spamIds = Set(spamAssets)

                        return assets.map { Asset(asset: $0,
                                                  info: map[$0.id],
                                                  isSpam: spamIds.contains($0.id),
                                                  isMyWavesToken: $0.sender == accountAddress,
                                                  isGeneral: mapGeneralAssets[$0.id] != nil) }
                    }
            }
    }

    func isSmartAsset(assetId: String, accountAddress _: String) -> Observable<Bool> {
        return serverEnvironmentRepository
            .serverEnvironment()
            .flatMap { [weak self] serverEnvironment -> Observable<Bool> in

                guard let self = self else { return Observable.never() }

                if assetId == WavesSDKConstants.wavesAssetId {
                    return Observable.just(false)
                }

                let wavesServices = self.wavesSDKServices
                    .wavesServices(environment: serverEnvironment)

                return wavesServices
                    .nodeServices
                    .assetsNodeService
                    .assetDetails(assetId: assetId)
                    .map { $0.scripted == true }
            }
    }
}

fileprivate extension AssetsRepository {
    func spamAssets(accountAddress: String) -> Observable<[SpamAssetId]> {
        return accountSettingsRepository.accountSettings(accountAddress: accountAddress)
            .flatMap { [weak self] settings -> Observable<[SpamAssetId]> in

                guard let self = self else { return Observable.never() }

                if settings?.isEnabledSpam ?? true {
                    return self.spamAssetsRepository.spamAssets(accountAddress: accountAddress)
                } else {
                    return Observable.just([])
                }
            }
    }
}

fileprivate extension WalletEnvironment {
    func hashMapAssets() -> [String: WalletEnvironment.AssetInfo] {
        var allAssets = generalAssets
        if let additionalAssets = assets {
            allAssets.append(contentsOf: additionalAssets)
        }

        return allAssets.reduce([String: WalletEnvironment.AssetInfo]()) { map, info -> [String: WalletEnvironment.AssetInfo] in
            var new = map
            new[info.assetId] = info
            return new
        }
    }

    func hashMapGeneralAssets() -> [String: WalletEnvironment.AssetInfo] {
        let allAssets = generalAssets

        return allAssets.reduce([String: WalletEnvironment.AssetInfo]()) { map, info -> [String: WalletEnvironment.AssetInfo] in
            var new = map
            new[info.assetId] = info
            return new
        }
    }
}

fileprivate extension Asset {
    init(asset: DataService.DTO.Asset, info: WalletEnvironment.AssetInfo?, isSpam: Bool, isMyWavesToken: Bool, isGeneral: Bool) {
        var isWaves = false
        var isFiat = false
        let isGateway = info?.isGateway ?? false
        var name = asset.name
        var description = asset.description

        // TODO: Current code need move to AssetsInteractor!
        if let info = info {
            if info.assetId == WavesSDKConstants.wavesAssetId {
                isWaves = true
            }

            if info.gatewayId == Constants.vostokAssetId {
                description = Constants.vostokAssetDescription
            }
            name = info.displayName
            isFiat = info.isFiat
        }
        let isWavesToken = isFiat == false && isGateway == false && isWaves == false

        self.init(id: asset.id,
                  gatewayId: info?.gatewayId,
                  wavesId: info?.wavesId,
                  name: name,
                  precision: asset.precision,
                  description: description,
                  height: asset.height,
                  timestamp: asset.timestamp,
                  sender: asset.sender,
                  quantity: asset.quantity,
                  ticker: asset.ticker,
                  isReusable: asset.reissuable,
                  isSpam: isSpam,
                  isFiat: isFiat,
                  isGeneral: isGeneral,
                  isMyWavesToken: isMyWavesToken,
                  isWavesToken: isWavesToken,
                  isGateway: isGateway,
                  isWaves: isWaves,
                  modified: Date(),
                  addressRegEx: info?.addressRegEx ?? "",
                  iconLogoUrl: info?.iconUrls?.default,
                  hasScript: asset.hasScript,
                  minSponsoredFee: asset.minSponsoredFee ?? 0,
                  gatewayType: info?.gatewayType,
                  isStablecoin: info?.isStablecoin ?? false,
                  isQualified: info?.isQualified ?? false,
                  isExistInExternalSource: info?.isExistInExternalSource ?? false)
    }
}
