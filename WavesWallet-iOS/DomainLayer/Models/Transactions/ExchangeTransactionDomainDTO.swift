//
//  TransactionExchangeNode.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO {

    struct ExchangeTransaction: Decodable {
        struct Order: Decodable {
            let id: String
            let sender: String
            let senderPublicKey: String
            let matcherPublicKey: String
            let assetPair: AssetPair
            let orderType: String
            let price: Int64
            let amount: Int64
            let timestamp: Int64
            let expiration: Int64
            let matcherFee: Int64
            let signature: String
        }

        struct AssetPair: Decodable {
            let amountAsset: String
            let priceAsset: String?
        }
        
        let type: Int
        let id: String
        let sender: String
        let senderPublicKey: String
        let fee: Int64
        let timestamp: Int64
        let height: Int64

        let signature: String
        let order1: Order
        let order2: Order
        let price: Int64
        let amount: Int64
        let buyMatcherFee: Int64
        let sellMatcherFee: Int64
        var modified: Date
    }
}
