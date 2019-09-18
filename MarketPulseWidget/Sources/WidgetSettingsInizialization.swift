//
//  WidgetSettingsInizialization.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 27.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer
import RxSwift
import WavesSDK
import WavesSDKCrypto


class WidgetSettingsInizialization: WidgetSettingsInizializationUseCaseProtocol {
    
    private let widgetSettingsStorage: WidgetSettingsRepositoryProtocol = WidgetSettingsRepositoryStorage()
    private let matcherRepository: MatcherRepositoryProtocol = MatcherRepositoryLocal(matcherRepositoryRemote: WidgetMatcherRepositoryRemote())
    private let pairsPriceRepository: WidgetPairsPriceRepositoryProtocol = WidgetPairsPriceRepositoryRemote()
    private let assetsRepository: WidgetAssetsRepositoryProtocol = WidgetAssetsRepositoryRemote()
    
    func settings() -> Observable<DomainLayer.DTO.MarketPulseSettings> {
        
        return widgetSettingsStorage
            .settings()
            .flatMap({ [weak self] settings -> Observable<DomainLayer.DTO.MarketPulseSettings> in
                
                guard let self = self else { return Observable.never() }
                
                if let settings = settings {
                    return Observable.just(settings)
                }
                
                return self.initial()
            })
    }
    
    private func initial() -> Observable<DomainLayer.DTO.MarketPulseSettings> {
        
        let walletEnvironment = WalletEnvironment.Mainnet
        let assets = walletEnvironment.generalAssets.prefix(DomainLayer.DTO.Widget.defaultCountAssets)

        return assetsRepository.assets(by: assets.map { $0.assetId })
            .flatMap({ [weak self] (assets) -> Observable<DomainLayer.DTO.MarketPulseSettings> in
                guard let self = self else { return Observable.never() }
                
                return self
                    .correction(pairs: assets.map { DomainLayer.DTO.CorrectionPairs.Pair.init(amountAsset: $0.id,
                                                                                              priceAsset: WavesSDKConstants.wavesAssetId) })
                    .flatMap({ (pairsAfterCorrection) -> Observable<[DomainLayer.DTO.CorrectionPairs.Pair]> in
                        
                        
                        //TODO: Remove
                        return self.pairsPriceRepository
                            .searchPairs(.init(kind: .pairs(pairsAfterCorrection.map { .init(amountAsset: $0.amountAsset,
                                                                                             priceAsset: $0.priceAsset) })))
                            .map({ (pairs) -> [DomainLayer.DTO.CorrectionPairs.Pair] in
                                
                                return pairsAfterCorrection
                            })
                        
                    })
                    .map({ (pairs) -> DomainLayer.DTO.MarketPulseSettings in
                        
                        let marketPulseAssets: [DomainLayer.DTO.MarketPulseSettings.Asset] = assets.enumerated()
                            .map({ (element) -> DomainLayer.DTO.MarketPulseSettings.Asset in
                                
                                let asset = element.element
                                let pair = pairs[element.offset]
                                
                                return .init(id: asset.id,
                                             name: asset.displayName,
                                             icon: asset.iconLogo,
                                             amountAsset: pair.amountAsset,
                                             priceAsset: pair.priceAsset)
                                
                            })
                        return DomainLayer.DTO.MarketPulseSettings(isDarkStyle: false,
                                                                   interval: .m10,
                                                                   assets: marketPulseAssets)
                    })
            })
    }
}

private extension WidgetSettingsInizialization {
    func correction(pairs: [DomainLayer.DTO.CorrectionPairs.Pair]) -> Observable<[DomainLayer.DTO.CorrectionPairs.Pair]> {
        let pairs = matcherRepository
            .settingsIdsPairs()
            .flatMap { (pricePairs) -> Observable<[DomainLayer.DTO.CorrectionPairs.Pair]> in
                
                let result = CorrectionPairsUseCaseLogic.mapCorrectPairs(settingsIdsPairs: pricePairs, pairs: pairs)
                
                return Observable.just(result)
        }
        
        return pairs

    }
}
