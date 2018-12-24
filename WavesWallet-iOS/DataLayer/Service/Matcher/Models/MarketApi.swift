//
//  MarketApi.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/23/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension API.DTO {
    
    struct Market: Decodable {
        struct AssetInfo: Decodable {
            let decimals: Int
        }
        
        let amountAsset: String
        let amountAssetName: String
        let amountAssetInfo: AssetInfo
        
        let priceAsset: String
        let priceAssetName: String
        let priceAssetInfo: AssetInfo
    }
    
    struct MarketResponse: Decodable {        
        let markets: [Market]
    }
   
}
