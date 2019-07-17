//
//  OrderMatcherQueries.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDKExtensions
import Extensions

public extension DomainLayer.Query {
    
    enum Dex {
        
        public struct CreateOrder {
            public let wallet: DomainLayer.DTO.SignedWallet
            public let matcherPublicKey: PublicKeyAccount
            public let amountAsset: String
            public let priceAsset: String
            public let amount: Int64
            public let price: Int64
            public let orderType: DomainLayer.DTO.Dex.OrderType
            public let matcherFee: Int64
            public let timestamp: Int64
            public let expiration: Int64
            public let matcherFeeAsset: String
            
            public init(wallet: DomainLayer.DTO.SignedWallet, matcherPublicKey: PublicKeyAccount, amountAsset: String, priceAsset: String, amount: Int64, price: Int64, orderType: DomainLayer.DTO.Dex.OrderType, matcherFee: Int64, timestamp: Int64, expiration: Int64, matcherFeeAsset: String) {
                self.wallet = wallet
                self.matcherPublicKey = matcherPublicKey
                self.amountAsset = amountAsset
                self.priceAsset = priceAsset
                self.amount = amount
                self.price = price
                self.orderType = orderType
                self.matcherFee = matcherFee
                self.timestamp = timestamp
                self.expiration = expiration
                self.matcherFeeAsset = matcherFeeAsset
            }
        }
        
        public struct CancelOrder {
            public let wallet: DomainLayer.DTO.SignedWallet
            public let orderId: String
            public let amountAsset: String
            public let priceAsset: String

            public init(wallet: DomainLayer.DTO.SignedWallet, orderId: String, amountAsset: String, priceAsset: String) {
                self.wallet = wallet
                self.orderId = orderId
                self.amountAsset = amountAsset
                self.priceAsset = priceAsset
            }
        }
    }
}
