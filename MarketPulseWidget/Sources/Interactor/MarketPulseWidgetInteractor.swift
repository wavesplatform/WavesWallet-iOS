//
//  MarketPulseWidgetInteractor.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 24.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDK
import DomainLayer
import DataLayer
import WavesSDKExtensions
import Extensions

protocol MarketPulseWidgetInteractorProtocol {
    func assets() -> Observable<[MarketPulse.DTO.Asset]>
    func chachedAssets() -> Observable<[MarketPulse.DTO.Asset]>
    func settings() -> Observable<MarketPulse.DTO.Settings>
}

final class MarketPulseWidgetInteractor: MarketPulseWidgetInteractorProtocol {
  
    private let widgetSettingsRepository: MarketPulseWidgetSettingsRepositoryProtocol = MarketPulseWidgetSettingsRepositoryMock()
    
    private let dbRepository: MarketPulseDataBaseRepositoryProtocol = MarketPulseDataBaseRepository()
    
    func settings() -> Observable<MarketPulse.DTO.Settings> {
        
        return Observable.zip(WidgetSettings.rx.currency(),
                              widgetSettingsRepository.settings())
            .flatMap({ (currency, marketPulseSettings) -> Observable<MarketPulse.DTO.Settings> in
                return Observable.just(MarketPulse.DTO.Settings(currency: currency,
                                                                isDarkMode: marketPulseSettings.isDarkStyle,
                                                                inverval: marketPulseSettings.interval))
            })
    }
    
    func chachedAssets() -> Observable<[MarketPulse.DTO.Asset]> {
        return dbRepository.chachedAssets()
    }
    
    func assets() -> Observable<[MarketPulse.DTO.Asset]> {
        
        return widgetSettingsRepository.settings()
            .flatMap({ [weak self] (settings) -> Observable<[MarketPulse.DTO.Asset]> in
                
                guard let self = self else { return Observable.empty() }
                
                var assets = settings.assets
                
                let iconStyle = DomainLayer.DTO.MarketPulseSettings.Asset.IconStyle(icon: .init(assetId: "",
                                                                                                name: "",
                                                                                                url: nil),
                                                                                    isSponsored: false,
                                                                                    hasScript: false)
                
                assets.append(.init(id: MarketPulse.usdAssetId,
                                    name: "",
                                    iconStyle: iconStyle,
                                    amountAsset: WavesSDKConstants.wavesAssetId,
                                    priceAsset: MarketPulse.usdAssetId))
                
                assets.append(.init(id: MarketPulse.eurAssetId,
                                    name: "",
                                    iconStyle: iconStyle,
                                    amountAsset: WavesSDKConstants.wavesAssetId,
                                    priceAsset: MarketPulse.eurAssetId))
                
                return self.loadAssets(assets: assets)
            })
    }
    
    private func loadAssets(assets: [DomainLayer.DTO.MarketPulseSettings.Asset]) -> Observable<[MarketPulse.DTO.Asset]> {
      
        return WavesSDK.shared.services
            .dataServices
            .pairsPriceDataService
            .pairsPrice(query: .init(pairs: assets.map { model in
                return DataService.Query.PairsPrice.Pair(amountAssetId: model.amountAsset,
                                                         priceAssetId: model.priceAsset)
            }))
            .flatMap { [weak self] (models) -> Observable<[MarketPulse.DTO.Asset]> in
                
                guard let self = self else { return Observable.empty() }
                
                var pairs: [MarketPulse.DTO.Asset] = []
                
                for (index, model) in models.enumerated() {
                    let asset = assets[index]
                    
                    pairs.append(MarketPulse.DTO.Asset(id: asset.id,
                                                       name: asset.name,
                                                       icon: asset.iconStyle.icon,
                                                       hasScript: asset.iconStyle.hasScript,
                                                       isSponsored: asset.iconStyle.isSponsored,
                                                       firstPrice: model.firstPrice,
                                                       lastPrice: model.lastPrice,
                                                       volume: model.volume,
                                                       volumeWaves: model.volumeWaves ?? 0,
                                                       quoteVolume: model.quoteVolume ?? 0,
                                                       amountAsset: asset.amountAsset))
                }
                
                return self.dbRepository.saveAsssets(assets: pairs)
                    .flatMap({ (_) -> Observable<[MarketPulse.DTO.Asset]> in
                        return Observable.just(pairs)
                    })
        }
    }
}
