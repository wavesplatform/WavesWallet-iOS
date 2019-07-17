//
//  TransactionExchangeNode.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Extensions

public extension DomainLayer.DTO {

    struct ExchangeTransaction: Mutating {

       public struct Order: Mutating {

            public enum Kind {
                case sell
                case buy
            }

            public let id: String
            public let sender: String
            public let senderPublicKey: String
            public let matcherPublicKey: String
            public var assetPair: AssetPair
            public let orderType: Kind
            public let price: Int64
            public let amount: Int64
            public let timestamp: Date
            public let expiration: Int64
            public let matcherFee: Int64
            public let signature: String?
            public let matcherFeeAssetId: String?
        
            public init(id: String, sender: String, senderPublicKey: String, matcherPublicKey: String, assetPair: AssetPair, orderType: Kind, price: Int64, amount: Int64, timestamp: Date, expiration: Int64, matcherFee: Int64, signature: String?, matcherFeeAssetId: String?) {
                self.id = id
                self.sender = sender
                self.senderPublicKey = senderPublicKey
                self.matcherPublicKey = matcherPublicKey
                self.assetPair = assetPair
                self.orderType = orderType
                self.price = price
                self.amount = amount
                self.timestamp = timestamp
                self.expiration = expiration
                self.matcherFee = matcherFee
                self.signature = signature
                self.matcherFeeAssetId = matcherFeeAssetId
            }
        }

        public struct AssetPair: Decodable, Mutating {
            public var amountAsset: String
            public var priceAsset: String

            public init(amountAsset: String, priceAsset: String) {
                self.amountAsset = amountAsset
                self.priceAsset = priceAsset
            }
        }
        
        public let type: Int
        public let id: String
        public let sender: String
        public let senderPublicKey: String
        public let fee: Int64
        public let timestamp: Date
        public let height: Int64

        public let signature: String?
        public let proofs: [String]?
        public var order1: Order
        public var order2: Order
        public let price: Int64
        public let amount: Int64
        public let buyMatcherFee: Int64
        public let sellMatcherFee: Int64
        public var modified: Date
        public var status: TransactionStatus
        public let version: Int
        
        public init(type: Int, id: String, sender: String, senderPublicKey: String, fee: Int64, timestamp: Date, height: Int64, signature: String?, proofs: [String]?, order1: Order, order2: Order, price: Int64, amount: Int64, buyMatcherFee: Int64, sellMatcherFee: Int64, modified: Date, status: TransactionStatus, version: Int) {
            self.type = type
            self.id = id
            self.sender = sender
            self.senderPublicKey = senderPublicKey
            self.fee = fee
            self.timestamp = timestamp
            self.height = height
            self.signature = signature
            self.proofs = proofs
            self.order1 = order1
            self.order2 = order2
            self.price = price
            self.amount = amount
            self.buyMatcherFee = buyMatcherFee
            self.sellMatcherFee = sellMatcherFee
            self.modified = modified
            self.status = status
            self.version = version
        }
    }
}
