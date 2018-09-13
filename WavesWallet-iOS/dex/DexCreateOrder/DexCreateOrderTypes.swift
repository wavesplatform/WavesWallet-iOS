//
//  DexSellBuyTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/8/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum DexCreateOrder {
    enum DTO {}
    enum ViewModel {}
}

extension DexCreateOrder.ViewModel {
    
    enum ExpirationTime: Int {
        case expiration5m = 5
        case expiration30m = 30
        case expiration1h = 60
        case expiration1d = 1440
        case expiration1w = 10080
        case expiration30d = 43200
    }
}

extension DexCreateOrder.ViewModel.ExpirationTime {
    
    var text: String {
        switch self {
        case .expiration5m:
            return "5" + " " + Localizable.DexCreateOrder.Button.minutes
            
        case .expiration30m:
            return "30" + " " + Localizable.DexCreateOrder.Button.minutes
            
        case .expiration1h:
            return "1" + " " + Localizable.DexCreateOrder.Button.hour
            
        case .expiration1d:
            return "1" + " " + Localizable.DexCreateOrder.Button.day
        
        case .expiration1w:
            return "1" + " " + Localizable.DexCreateOrder.Button.week
            
        case .expiration30d:
            return "30" + " " + Localizable.DexCreateOrder.Button.days
        }
    }
}

extension DexCreateOrder.DTO {
  
    enum OrderType {
        case sell
        case buy
    }
    
    struct Input {
        let amountAsset: Dex.DTO.Asset
        let priceAsset: Dex.DTO.Asset
        let type: OrderType
        let price: Money
    }
    
    struct Balance {
        let totalMoney: Money
    }
}
