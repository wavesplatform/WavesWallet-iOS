//
//  OrderBookApi.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/17/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension API.DTO {
    
    struct OrderBook: Decodable {
        
        struct Pair: Decodable {
            let amountAsset: String
            let priceAsset: String
        }
        
        struct Value: Decodable {
            let amount: Int64
            let price: Int64
        }

        let date: Date
        let pair: Pair
        let bids: [Value]
        let asks: [Value]
        
        private enum CodingKeys: String, CodingKey {
            case date = "timestamp"
            case pair, bids, asks
        }
    }
}
