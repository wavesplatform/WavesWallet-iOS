//
//  WidgetSettingsUseCase.swift
//  DomainLayer
//
//  Created by rprokofev on 12.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDK

public class WidgetSettingsUseCase: WidgetSettingsUseCaseProtocol {
    
    private let repositories: RepositoriesFactoryProtocol
    private let useCases: UseCasesFactoryProtocol
    
    init(repositories: RepositoriesFactoryProtocol, useCases: UseCasesFactoryProtocol) {
        self.repositories = repositories
        self.useCases = useCases
    }
    
    //TODO: Remove Loading Assets
    public func settings() -> Observable<DomainLayer.DTO.Widget.Settings> {
        
        return useCases
            .widgetSettingsInizialization
            .settings()
            .flatMap({ [weak self] (settings) -> Observable<DomainLayer.DTO.Widget.Settings> in
                
                guard let self = self else { return Observable.never() }
                
                return self
                    .useCases
                    .assets
                    .assets(by: settings.assets.map { $0.id }, accountAddress: "")
                    .map { DomainLayer.DTO.Widget.Settings.init(assets: $0,
                                                                style: settings.styleWidget,
                                                                interval: settings.intervalWidget) }
            })
    }
    
    public func changeInterval(_ interval: DomainLayer.DTO.Widget.Interval) -> Observable<Bool> {
        
        return useCases
            .widgetSettingsInizialization
            .settings()
            .flatMap({ [weak self] (settings) -> Observable<Bool> in
                
                guard let self = self else { return Observable.never() }
                
                let newSettings = DomainLayer.DTO.MarketPulseSettings(isDarkStyle: settings.isDarkStyle,
                                                                      interval: interval.marketPulseInterval,
                                                                      assets: settings.assets)
                return self
                    .repositories
                    .widgetSettingsStorage
                    .saveSettings(newSettings)
                    .map { _ in return true }
            })
    }
    
    public func changeStyle(_ style: DomainLayer.DTO.Widget.Style) -> Observable<Bool> {
        
        return useCases
            .widgetSettingsInizialization
            .settings()
            .flatMap({ [weak self] (settings) -> Observable<Bool> in
                
                guard let self = self else { return Observable.never() }
                
                let newSettings = DomainLayer.DTO.MarketPulseSettings(isDarkStyle: style == .dark,
                                                                      interval: settings.interval,
                                                                      assets: settings.assets)
                return self
                    .repositories
                    .widgetSettingsStorage
                    .saveSettings(newSettings)
                    .map { _ in return true }
            })
    }
    
    public func removeAsset(_ asset: DomainLayer.DTO.Asset) -> Observable<Bool> {
        
        return useCases
            .widgetSettingsInizialization
            .settings()
            .flatMap({ [weak self] (settings) -> Observable<Bool> in
                
                guard let self = self else { return Observable.never() }
                
                let newAssets = settings.assets.filter { $0.id != asset.id }
                
                let newSettings = DomainLayer.DTO.MarketPulseSettings(isDarkStyle: settings.isDarkStyle,
                                                                      interval: settings.interval,
                                                                      assets: newAssets)
                return self
                    .repositories
                    .widgetSettingsStorage
                    .saveSettings(newSettings)
                    .map { _ in return true }
            })
    }
    
    public func saveSettings(_ settings: DomainLayer.DTO.Widget.Settings) -> Observable<DomainLayer.DTO.Widget.Settings> {
        
        return self
            .useCases
            .correctionPairsUseCase
            .correction(pairs: settings
                .assets
                .map { .init(amountAsset: $0.id, priceAsset: WavesSDKConstants.wavesAssetId) })
            .map({ (pairs) -> DomainLayer.DTO.MarketPulseSettings in
             
                let assets: [DomainLayer.DTO.MarketPulseSettings.Asset] = settings
                    .assets
                    .enumerated()
                    .map({ (element) -> DomainLayer.DTO.MarketPulseSettings.Asset in
                        let asset = element.element
                        let pair = pairs[element.offset]
                        
                        return .init(id: asset.id,
                                     name: asset.displayName,
                                     icon: asset.iconLogo,
                                     amountAsset: pair.amountAsset,
                                     priceAsset: pair.priceAsset)
                    })
                
                return DomainLayer.DTO.MarketPulseSettings.init(isDarkStyle: settings.isDarkStyle,
                                                                interval: settings.interval.marketPulseInterval,
                                                                assets: assets)
            })
            .flatMap({ [weak self] (marketPulseSettings) -> Observable<DomainLayer.DTO.Widget.Settings> in
                guard let self = self else { return Observable.never() }
                
                return self
                    .repositories
                    .widgetSettingsStorage
                    .saveSettings(marketPulseSettings)
                    .map { _ in settings }
            })
    }
    
    public func sortAssets(_ sortMap: [String: Int]) -> Observable<Bool> {
        
        return useCases
            .widgetSettingsInizialization
            .settings()
            .flatMap({ [weak self] (settings) -> Observable<Bool> in
                
                guard let self = self else { return Observable.never() }
                
                let newAssets = settings.assets.sorted(by: { (sortMap[$0.id] ?? 0) < (sortMap[$1.id] ?? 0) })
                
                let newSettings = DomainLayer.DTO.MarketPulseSettings(isDarkStyle: settings.isDarkStyle,
                                                                      interval: settings.interval,
                                                                      assets: newAssets)
                return self
                    .repositories
                    .widgetSettingsStorage
                    .saveSettings(newSettings)
                    .map { _ in return true }
            })
    }
}


fileprivate extension DomainLayer.DTO.Widget.Interval {
    
    var marketPulseInterval: DomainLayer.DTO.MarketPulseSettings.Interval {
        
        switch self {
        case .m1:
            return .m1
            
        case .m5:
            return .m5
            
        case .m10:
            return .m10
            
        case .manually:
            return .manually
        }
    }
    
}

fileprivate extension DomainLayer.DTO.Widget.Settings {
    
    var isDarkStyle: Bool {
        return self.style == .dark
    }
    
    var marketPulseSettings: DomainLayer.DTO.MarketPulseSettings {
        
        return .init(isDarkStyle: isDarkStyle,
                     interval: interval.marketPulseInterval,
                     assets: [])
    }
}

fileprivate extension DomainLayer.DTO.MarketPulseSettings {
    
    var styleWidget: DomainLayer.DTO.Widget.Style {
        if isDarkStyle {
            return .dark
        } else {
            return .classic
        }
    }
    
    var intervalWidget: DomainLayer.DTO.Widget.Interval {
        switch self.interval {
        case .m1:
            return .m1
        
        case .m5:
            return .m5
            
        case .m10:
            return .m10
        
        case .manually:
            return .manually
        }
    }
}
