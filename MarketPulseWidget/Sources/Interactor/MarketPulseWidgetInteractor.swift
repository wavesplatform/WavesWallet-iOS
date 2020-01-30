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
    private let assetsRepository: WidgetAssetsRepositoryProtocol = WidgetAssetsRepositoryRemote()

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
                            
                return self.loadAssets(assets: settings.assets)
            })
    }
    
    private func loadAssets(assets: [DomainLayer.DTO.MarketPulseSettings.Asset]) -> Observable<[MarketPulse.DTO.Asset]> {
        
        let earlyDate = Calendar.current.date(byAdding: .hour,
                                              value: -24,
                                              to: Date()) ?? Date()
        
        let roundEarlyDate = Date(timeIntervalSince1970: ceil(earlyDate.timeIntervalSince1970 / 60.0) * 60.0)
        
                    
        let ratesQuery = MarketPulse.Query.Rates.init(pair: assets.flatMap { [.init(amountAssetId: $0.id, priceAssetId: MarketPulse.usdAssetId),
                                                                              .init(amountAssetId: $0.id, priceAssetId: MarketPulse.eurAssetId)] },
                                                      timestamp: nil)

        let ratesQueryYesterday = MarketPulse.Query.Rates.init(pair: assets.flatMap { [.init(amountAssetId: $0.id, priceAssetId: MarketPulse.usdAssetId),
                                                                              .init(amountAssetId: $0.id, priceAssetId: MarketPulse.eurAssetId)] },
                                                      timestamp: roundEarlyDate)
        
        let assetsQuery = assetsRepository.assets(by: assets.map { $0.id })
        
        return Observable.zip(pairsPriceRepository.ratePairs(ratesQueryYesterday),
                              pairsPriceRepository.ratePairs(ratesQuery),
                              assetsQuery)
            .flatMap { (yesterdayRates, nowRates, assetsRemote) -> Observable<[MarketPulse.DTO.Asset]> in
                       
                let iconsMap = assetsRemote.reduce(into: [String: AssetLogo.Icon].init(), {
                    $0[$1.id] = $1.iconLogo
                })
                
                let yesterdayRatesMap = yesterdayRates.reduce(into: [String: [String: MarketPulse.DTO.Rate]].init(), {
                    var map = $0[$1.priceAssetId] ?? [String: MarketPulse.DTO.Rate].init()

                    map[$1.amountAssetId] = $1
                    $0[$1.priceAssetId] = map
                })
                
                let nowRatesMap = nowRates.reduce(into: [String: [String: MarketPulse.DTO.Rate]].init(), {
                    var map = $0[$1.priceAssetId] ?? [String: MarketPulse.DTO.Rate].init()

                    map[$1.amountAssetId] = $1
                    $0[$1.priceAssetId] = map
                })
                                
                let newAssets = assets.map { asset -> MarketPulse.DTO.Asset in
                    
                    var rates: [String: Double] = .init()
                    rates[MarketPulse.usdAssetId] = nowRatesMap[MarketPulse.usdAssetId]?[asset.id]?.rate ?? 0
                    rates[MarketPulse.eurAssetId] = nowRatesMap[MarketPulse.eurAssetId]?[asset.id]?.rate ?? 0
                    
                    var firstPrice: [String: Double] = .init()
                    firstPrice[MarketPulse.usdAssetId] = yesterdayRatesMap[MarketPulse.usdAssetId]?[asset.id]?.rate ?? 0
                    firstPrice[MarketPulse.eurAssetId] = yesterdayRatesMap[MarketPulse.eurAssetId]?[asset.id]?.rate ?? 0
                    
                    let icon = iconsMap[asset.id] ?? asset.icon
                    
                    return MarketPulse.DTO.Asset(id: asset.id,
                                                 name: asset.name,
                                                 icon: icon,
                                                 rates: rates,
                                                 firstPrice: firstPrice,
                                                 lastPrice: rates,
                                                 amountAsset: asset.amountAsset)
                }

                return self
                    .dbRepository
                    .saveAsssets(assets: newAssets)
                    .flatMap({ (_) -> Observable<[MarketPulse.DTO.Asset]> in
                        return Observable.just(newAssets)
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
