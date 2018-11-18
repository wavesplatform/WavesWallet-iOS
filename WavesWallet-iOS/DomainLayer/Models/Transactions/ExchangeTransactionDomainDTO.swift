//
//  TransactionExchangeNode.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO {

    struct ExchangeTransaction: Mutating {

        struct Order: Mutating {

            enum Kind {
                case sell
                case buy
            }

            let id: String
            let sender: String
            let senderPublicKey: String
            let matcherPublicKey: String
            var assetPair: AssetPair
            let orderType: Kind
            let price: Int64
            let amount: Int64
            let timestamp: Int64
            let expiration: Int64
            let matcherFee: Int64
            let signature: String?
        }

        struct AssetPair: Decodable, Mutating {
            var amountAsset: String
            var priceAsset: String
        }
        
        let type: Int
        let id: String
        let sender: String
        let senderPublicKey: String
        let fee: Int64
        let timestamp: Int64
        let height: Int64

        let signature: String?
        var order1: Order
        var order2: Order
        let price: Int64
        let amount: Int64
        let buyMatcherFee: Int64
        let sellMatcherFee: Int64
        var modified: Date
        var status: TransactionStatus
    }
}
