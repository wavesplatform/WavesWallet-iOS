//
//  WidgetSettingsInizializationUseCase.swift
//  DomainLayer
//
//  Created by rprokofev on 12.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDK

public class WidgetSettingsInizializationUseCase: WidgetSettingsInizializationUseCaseProtocol {
    
    private let repositories: RepositoriesFactoryProtocol
    private let useCases: UseCasesFactoryProtocol
    
    init(repositories: RepositoriesFactoryProtocol, useCases: UseCasesFactoryProtocol) {
        self.repositories = repositories
        self.useCases = useCases
    }
    
    public func settings() -> Observable<DomainLayer.DTO.MarketPulseSettings> {
        
        return repositories
            .widgetSettingsStorage
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
        
        return repositories
            .environmentRepository
            .walletEnvironment()
            .flatMap { [weak self] (walletEnviroment) -> Observable<[DomainLayer.DTO.Asset]> in
                
                guard let self = self else { return Observable.never() }
                let assets = walletEnviroment.generalAssets.prefix(DomainLayer.DTO.Widget.minCountAssets)
                return self.useCases.assets.assets(by: assets.map { $0.assetId }, accountAddress: "")
            }
            .flatMap { [weak self] (assets) -> Observable<DomainLayer.DTO.MarketPulseSettings> in
                
                guard let self = self else { return Observable.never() }
                
                return self
                    .useCases
                    .correctionPairsUseCase
                    .correction(pairs: assets.map { DomainLayer.DTO.CorrectionPairs.Pair.init(amountAsset: $0.id,
                                                                                              priceAsset: WavesSDKConstants.wavesAssetId) })
                    .flatMap({ (pairsAfterCorrection) -> Observable<[DomainLayer.DTO.CorrectionPairs.Pair]> in
                        
                        
                        //TODO: Remove
                        return self.repositories
                            .dexPairsPriceRepository
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
            }
    }
}
