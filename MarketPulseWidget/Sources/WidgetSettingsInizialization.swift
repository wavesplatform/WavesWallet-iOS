//
//  WidgetSettingsInizialization.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 27.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import DataLayer
import DomainLayer
import Foundation
import RxSwift
import WavesSDK
import WavesSDKCrypto

class WidgetSettingsInizialization: WidgetSettingsInizializationUseCaseProtocol {
    private let widgetSettingsStorage: WidgetSettingsRepositoryProtocol = WidgetSettingsRepositoryStorage()
    private lazy var matcherRepository: WidgetMatcherRepositoryRemote = WidgetMatcherRepositoryRemote(environmentRepository: environmentRepository)
    private lazy var pairsPriceRepository = WidgetPairsPriceRepositoryRemote(environmentRepository: environmentRepository)
    private lazy var assetsRepository: WidgetAssetsRepositoryProtocol = WidgetAssetsRepositoryRemote(environmentRepository: environmentRepository)
    private let environmentRepository: EnvironmentRepositoryProtocol
    
    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }

    func settings() -> Observable<DomainLayer.DTO.MarketPulseSettings> {
        widgetSettingsStorage
            .settings()
            .flatMap { [weak self] settings -> Observable<DomainLayer.DTO.MarketPulseSettings> in

                guard let self = self else { return Observable.never() }

                if let settings = settings {
                    return Observable.just(settings)
                }

                return self.initial()
            }
    }

    private func initial() -> Observable<DomainLayer.DTO.MarketPulseSettings> {
        return environmentRepository.walletEnvironment()
            .flatMap { [weak self] environment -> Observable<DomainLayer.DTO.MarketPulseSettings> in

                guard let self = self else { return Observable.never() }
                let assets = environment.generalAssets.prefix(DomainLayer.DTO.Widget.defaultCountAssets)

                let assetsIdentifiers = assets.map { $0.assetId }
                return self.assetsRepository.assets(by: assetsIdentifiers)
                    .flatMap { [weak self] assets -> Observable<DomainLayer.DTO.MarketPulseSettings> in
                        guard let self = self else { return Observable.never() }

                        // обратить внимание!!!!!!!!
                        let pairs = assets.map {
                            DomainLayer.DTO.CorrectionPairs.Pair(amountAsset: $0.id, priceAsset: WavesSDKConstants.wavesAssetId)
                        }

                        return self
                            .correction(pairs: pairs)
                            .flatMap { pairsAfterCorrection -> Observable<[DomainLayer.DTO.CorrectionPairs.Pair]> in
                                // TODO: Remove
                                self.pairsPriceRepository
                                    .searchPairs(.init(kind: .pairs(pairsAfterCorrection.map { .init(amountAsset: $0.amountAsset,
                                                                                                     priceAsset: $0.priceAsset)
                                                                                                     })))
                                    .map { _ -> [DomainLayer.DTO.CorrectionPairs.Pair] in

                                        pairsAfterCorrection
                                    }
                            }
                            .map { pairs -> DomainLayer.DTO.MarketPulseSettings in

                                let marketPulseAssets: [DomainLayer.DTO.MarketPulseSettings.Asset] = assets.enumerated()
                                    .map { element -> DomainLayer.DTO.MarketPulseSettings.Asset in

                                        let asset = element.element
                                        let pair = pairs[element.offset]

                                        return .init(id: asset.id,
                                                     name: asset.displayName,
                                                     icon: asset.iconLogo,
                                                     amountAsset: pair.amountAsset,
                                                     priceAsset: pair.priceAsset)
                                    }
                                return DomainLayer.DTO.MarketPulseSettings(isDarkStyle: false,
                                                                           interval: .m10,
                                                                           assets: marketPulseAssets)
                            }
                    }
            }
    }
}

private extension WidgetSettingsInizialization {
    func correction(pairs: [DomainLayer.DTO.CorrectionPairs.Pair]) -> Observable<[DomainLayer.DTO.CorrectionPairs.Pair]> {
        let pairs = matcherRepository
            .settingsIdsPairs()
            .flatMap { pricePairs -> Observable<[DomainLayer.DTO.CorrectionPairs.Pair]> in
                let result = CorrectionPairsUseCaseLogic.mapCorrectPairs(settingsIdsPairs: pricePairs, pairs: pairs)
                return Observable.just(result)
            }

        return pairs
    }
}
