//
//  AnalyticManager+Dex.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 3/22/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

extension AnalyticManager.Event {
    
    enum Dex {
        
        private static let key = "Pair"
        
        /* Нажата кнопка «Buy» на экране просмотра пары. */
        case buyTap(amountAsset: String, priceAsset: String)
        
        /* Нажата кнопка «Okay» на экране созданного ордера. */
        case buyOrderSuccess(amountAsset: String, priceAsset: String)
        
        /* Нажата кнопка «Sell» на экране просмотра пары. */
        case sellTap(amountAsset: String, priceAsset: String)
        
        /* Нажата кнопка «Okay» на экране созданного ордера. */
        case sellOrderSuccess(amountAsset: String, priceAsset: String)
        
        var name: String {
            switch self {
            case .buyTap:
                return "DEX Buy Tap"
                
            case .buyOrderSuccess:
                return "DEX Buy Order Success"
                
            case .sellTap:
                return "DEX Sell Tap"
                
            case .sellOrderSuccess:
                return "DEX Sell Order Success"
            }
        }
        
        var params: [String : String] {
            switch self {
            case .buyTap(let amountAsset, let priceAsset):
                return [Dex.key: amountAsset + "/" + priceAsset]
                
            case .buyOrderSuccess(let amountAsset, let priceAsset):
                return [Dex.key: amountAsset + "/" + priceAsset]
                
            case .sellTap(let amountAsset, let priceAsset):
                return [Dex.key: amountAsset + "/" + priceAsset]
                
            case .sellOrderSuccess(let amountAsset, let priceAsset):
                return [Dex.key: amountAsset + "/" + priceAsset]
            }
        }
    }
    
}
