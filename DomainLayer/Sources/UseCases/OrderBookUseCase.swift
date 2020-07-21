//
//  OrderBookUseCase.swift
//  InternalDomainLayer
//
//  Created by Pavel Gubin on 08.07.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDK

final class OrderBookUseCase: OrderBookUseCaseProtocol {
    private let orderBookRepository: DexOrderBookRepositoryProtocol
    private let assetsRepository: AssetsRepositoryProtocol
    private let authorizationInteractor: AuthorizationUseCaseProtocol
    private let serverEnvironment: ServerEnvironmentRepository

    init(orderBookRepository: DexOrderBookRepositoryProtocol,
         assetsRepository: AssetsRepositoryProtocol,
         authorizationInteractor: AuthorizationUseCaseProtocol,
         serverEnvironment: ServerEnvironmentRepository) {
        self.orderBookRepository = orderBookRepository
        self.assetsRepository = assetsRepository
        self.authorizationInteractor = authorizationInteractor
        self.serverEnvironment = serverEnvironment
    }

    func orderSettingsFee() -> Observable<DomainLayer.DTO.Dex.SmartSettingsOrderFee> {
        let serverEnvironment = self.serverEnvironment.serverEnvironment()
        let authorizedWallet = authorizationInteractor.authorizedWallet()

        return Observable.zip(authorizedWallet,
                              serverEnvironment)
            .flatMap { [weak self] wallet, serverEnvironment -> Observable<DomainLayer.DTO.Dex.SmartSettingsOrderFee> in

                guard let self = self else { return Observable.empty() }

                return self
                    .orderBookRepository
                    .orderSettingsFee(serverEnvironment: serverEnvironment)

                    .flatMap { [weak self] (baseSettings) -> Observable<DomainLayer.DTO.Dex.SmartSettingsOrderFee> in
                        guard let self = self else { return Observable.empty() }

                        return self.assetsRepository.assets(ids: baseSettings.feeAssets.map { $0.assetId },
                                                            accountAddress: wallet.address)
                            .map { $0.compactMap { $0 } }
                            .map { [weak self] (assets) -> DomainLayer.DTO.Dex.SmartSettingsOrderFee in

                                guard let self = self else {
                                    return DomainLayer.DTO.Dex.SmartSettingsOrderFee(baseFee: 0, feeAssets: [])
                                }
                            
                                return self.mapAssetsToSmartSettings(assets: assets,
                                                                     baseSettings: baseSettings)
                            }
                    }
            }
    }

    private func mapAssetsToSmartSettings(
        assets: [Asset],
        baseSettings: DomainLayer.DTO.Dex.SettingsOrderFee) -> DomainLayer.DTO.Dex.SmartSettingsOrderFee {
        var sortedAssets = assets.sorted(by: { $0.displayName < $1.displayName })

        if let index = sortedAssets.firstIndex(where: { $0.id == WavesSDKConstants.wavesAssetId }) {
            let wavesAsset = sortedAssets[index]
            sortedAssets.remove(at: index)
            sortedAssets.insert(wavesAsset, at: 0)
        }

        let feeAssets = sortedAssets.map { (asset) -> DomainLayer.DTO.Dex.SmartSettingsOrderFee.Asset in

            let rate = baseSettings.feeAssets.first(where: { $0.assetId == asset.id })?.rate ?? 0
            return DomainLayer.DTO.Dex.SmartSettingsOrderFee.Asset(rate: rate, asset: asset.dexAsset)
        }

        return DomainLayer.DTO.Dex.SmartSettingsOrderFee(baseFee: baseSettings.baseFee, feeAssets: feeAssets)
    }
}
