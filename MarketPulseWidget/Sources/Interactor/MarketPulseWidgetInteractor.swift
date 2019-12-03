//
//  MarketPulseWidgetInteractor.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 24.07.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDK
import DomainLayer
import WavesSDKExtensions
import Extensions

private enum Constants {
    static let exchangeTxLimit: Int = 5
}

protocol MarketPulseWidgetInteractorProtocol {
    func assets() -> Observable<[MarketPulse.DTO.Asset]>
    func chachedAssets() -> Observable<[MarketPulse.DTO.Asset]>
    func settings() -> Observable<MarketPulse.DTO.Settings>
}

final class MarketPulseWidgetInteractor: MarketPulseWidgetInteractorProtocol {
  
    private let widgetSettingsRepository: WidgetSettingsInizializationUseCaseProtocol = WidgetSettingsInizialization()
    private let pairsPriceRepository: WidgetPairsPriceRepositoryProtocol = WidgetPairsPriceRepositoryRemote()
    private let dbRepository: MarketPulseDataBaseRepositoryProtocol = MarketPulseDataBaseRepository()
            
    init() {
        _ = setupLayers()
    }
    
    static var shared: MarketPulseWidgetInteractor = MarketPulseWidgetInteractor()
    
    private func setupLayers() -> Bool {
    
        guard let googleServiceInfoPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
            return false
        }
        
        guard let appsflyerInfoPath = Bundle.main.path(forResource: "Appsflyer-Info", ofType: "plist") else {
            return false
        }
        
        guard let amplitudeInfoPath = Bundle.main.path(forResource: "Amplitude-Info", ofType: "plist") else {
            return false
        }

        Address.walletEnvironment = WidgetSettings.environment

        WidgetAnalyticManagerInitialization.setup(resources: .init(googleServiceInfo: googleServiceInfoPath,
            appsflyerInfo: appsflyerInfoPath,
            amplitudeInfo: amplitudeInfoPath))
        
        return true
    }
    
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
                
                let iconStyle = AssetLogo.Icon.init(assetId: "",
                                                    name: "",
                                                    url: nil,
                                                    isSponsored: false,
                                                    hasScript: false)
                
                assets.append(.init(id: MarketPulse.usdAssetId,
                                    name: "",
                                    icon: iconStyle,
                                    amountAsset: WavesSDKConstants.wavesAssetId,
                                    priceAsset: MarketPulse.usdAssetId))

                assets.append(.init(id: MarketPulse.eurAssetId,
                                    name: "",
                                    icon: iconStyle,
                                    amountAsset: WavesSDKConstants.wavesAssetId,
                                    priceAsset: MarketPulse.eurAssetId))
                
                return self.loadAssets(assets: assets)
            })
    }
    
    private func loadAssets(assets: [DomainLayer.DTO.MarketPulseSettings.Asset]) -> Observable<[MarketPulse.DTO.Asset]> {
        
        let query = assets.map { DomainLayer.Query.Dex.SearchPairs.Pair.init(amountAsset: $0.amountAsset,
                                                                             priceAsset: $0.priceAsset) }
        
        let ratesQuery = MarketPulse.Query.Rates.init(pair: assets.flatMap { [.init(amountAssetId: $0.id, priceAssetId: MarketPulse.usdAssetId),
                                                                              .init(amountAssetId: $0.id, priceAssetId: MarketPulse.eurAssetId)] })

        return Observable.zip(pairsPriceRepository.searchPairs(.init(kind: .pairs(query))),
                              pairsPriceRepository.ratePairs(ratesQuery))
            .flatMap { [weak self] (searchResult, ratePairs) -> Observable<[MarketPulse.DTO.Asset]> in

                guard let self = self else { return Observable.empty() }
                                
                var pairs: [MarketPulse.DTO.Asset] = []
            
                let prices = ratePairs.reduce(into: [String: [String: MarketPulse.DTO.Rate]].init(), {
                    var map = $0[$1.priceAssetId] ?? [String: MarketPulse.DTO.Rate].init()
                    
                    map[$1.amountAssetId] = $1
                    $0[$1.priceAssetId] = map
                })
                
                for (index, model) in searchResult.pairs.enumerated() {
                                        
                    let asset = assets[index]
                   
                    var rates: [String: Double] = .init()
                    rates[MarketPulse.usdAssetId] = prices[MarketPulse.usdAssetId]?[asset.id]?.rate ?? 0
                    rates[MarketPulse.eurAssetId] = prices[MarketPulse.eurAssetId]?[asset.id]?.rate ?? 0
                    
                    pairs.append(MarketPulse.DTO.Asset(id: asset.id,
                                                       name: asset.name,
                                                       icon: asset.icon,
                                                       rates: rates,
                                                       firstPrice: model?.firstPrice ?? 0,
                                                       lastPrice: model?.lastPrice ?? 0,
                                                       amountAsset: asset.amountAsset))
                }
                
                return self.dbRepository.saveAsssets(assets: pairs)
                    .flatMap({ (_) -> Observable<[MarketPulse.DTO.Asset]> in
                        return Observable.just(pairs)
                    })
            }
    }
}

private struct AuthorizationInteractorLocalizableImp: AuthorizationInteractorLocalizableProtocol {
    
    var fallbackTitle: String {
        return ""
    }
    
    var cancelTitle: String {
        return ""
    }
    
    var readFromkeychain: String {
        return ""
    }
    
    var saveInkeychain: String {
        return ""
    }
}
