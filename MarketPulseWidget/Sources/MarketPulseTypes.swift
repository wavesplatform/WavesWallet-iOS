//
//  MarketPulseExtension.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 24.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import Extensions
import WavesSDK
import DomainLayer

enum MarketPulse {
    static let minimumCountAssets = 2
    static let usdAssetId = "Ft8X1v1LTa1ABafufpaCWyVj8KkaxUWE6xBhW6sNFJck"
    static let eurAssetId = "Gtb1WRznfchDnTh37ezoDTJ4wcoKaRsKqKjJjy7nm2zU"
        
    enum Currency: String {
        case usd
        case eur
        
        var title: String {
            switch self {
            case .eur:
                return "EUR"
                
            case .usd:
                return "USD"
            }
        }
        
        var ticker: String {
            switch self {
                
            case .eur:
                return "€"
            case .usd:
                return "$"
            }
        }
    }
    
    enum DTO {}
    enum ViewModel { }
    
    enum Event {
        case readyView
        case refresh
        case changeCurrency(Currency)
        case setAssets([DTO.Asset])
        case setSettings(DTO.Settings)
        case setChachedAssets([DTO.Asset])
    }
    
    struct State: Mutating {
        enum Action {
            case none
            case update
            case didFailUpdate(NetworkError)
        }
        
        var hasLoadSettings: Bool
        var hasLoadChachedAsset: Bool
        var isNeedRefreshing: Bool
        var action: Action
        var models: [ViewModel.Row]
        var assets: [DTO.Asset]
        var currency: Currency
        var isDarkMode: Bool
        var updateInterval: DomainLayer.DTO.MarketPulseSettings.Interval
    }
}

extension MarketPulse.DTO {
    
    struct Asset {
        let id: String
        let name: String
        let icon: AssetLogo.Icon
        let firstPrice: Double
        let lastPrice: Double
        let volume: Double
        let volumeWaves: Double
        let quoteVolume: Double
        let amountAsset: String
    }
    
    struct UIAsset {
        let icon: AssetLogo.Icon
        let name: String
        let price: Double
        let percent: Double
        let currency: MarketPulse.Currency
        let isDarkMode: Bool
    }
    
    struct Settings {
        let currency: MarketPulse.Currency
        let isDarkMode: Bool
        let inverval: DomainLayer.DTO.MarketPulseSettings.Interval
    }
}

extension MarketPulse.ViewModel {
    
    enum Row {
        case model(MarketPulse.DTO.UIAsset)
    }
}

extension MarketPulse.State: Equatable {
    static func == (lhs: MarketPulse.State, rhs: MarketPulse.State) -> Bool {
        return lhs.isNeedRefreshing == rhs.isNeedRefreshing &&
            lhs.hasLoadSettings == rhs.hasLoadSettings &&
            lhs.hasLoadChachedAsset == rhs.hasLoadChachedAsset
    }
}
