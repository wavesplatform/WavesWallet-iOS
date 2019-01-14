//
//  Transaction.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 09.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension API.DTO {

    struct Pair: Decodable {
        let amountAsset: String
        let priceAsset: String
    }

    enum OrderType: String, Decodable {
        case sell
        case buy
    }
    
    struct Order: Decodable {
        let id: String
        let senderPublicKey: String
        let matcherPublicKey: String
        let assetPair: Pair
        let orderType: OrderType
        let price: Double
        let sender: String
        let amount: Double
        let timestamp: Date
        let expiration: Date
        let matcherFee: Double
        let signature: String
    }

    struct ExchangeTransaction: Decodable {
        let id: String
        let timestamp: Date
        let height: Int64
        let type: Int
        let fee: Double
        let sender: String
        let senderPublicKey: String
        let buyMatcherFee: Double
        let sellMatcherFee: Double
        let price: Double
        let amount: Double
        let order1: Order
        let order2: Order
    }
}

extension API.DTO.ExchangeTransaction {
    
    var orderType: API.DTO.OrderType {
        let order = order1.timestamp > order2.timestamp ? order1 : order2
        return order.orderType
    }
}
