//
//  OrderMatcherQueries.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.Query {
    
    enum Dex {
        
        struct CreateOrder {
            let wallet: DomainLayer.DTO.SignedWallet
            let matcherPublicKey: PublicKeyAccount
            let amountAsset: String
            let priceAsset: String
            let amount: Int64
            let price: Int64
            let orderType: DomainLayer.DTO.Dex.OrderType
            let matcherFee: Int64
            let timestamp: Int64 = Date().millisecondsSince1970
            let expiration: Int64
        }
        
        struct CancelOrder {
            let wallet: DomainLayer.DTO.SignedWallet
            let orderId: String
            let amountAsset: String
            let priceAsset: String
        }
    }
}
